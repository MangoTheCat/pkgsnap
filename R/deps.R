
#' Dependency types in R DESCRIPTION files
#' @keywords internal

dep_types <- c("Imports", "Depends", "Suggests", "Enhances", "LinkingTo")

#' 'Hard' dependency types in R DESCRIPTION files
#'
#' A dependency is hard if the depended package is required
#' for installing and/or loading the package.
#'
#' @name dep_types
#' @keywords internal

hard_dep_types <- c("Imports", "Depends", "LinkingTo")

#' Extract and read the DESCRIPTION file from an R package tarball
#'
#' @param package_file Path and name of the tarball.
#' @return A named list of DESCRIPTION fields.
#'
#' @keywords internal
#' @importFrom utils untar

get_description <- function(package_file) {

  pkg <- pkg_from_filename(package_file)

  tmp <- tempfile()
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  untar(
    package_file,
    files = paste(pkg, sep = "/", "DESCRIPTION"),
    exdir = tmp
  )

  desc_file <- file.path(tmp, pkg, "DESCRIPTION")
  as.list(read.dcf(desc_file)[1, ])
}

#' Extract (hard) package dependencies from an R package tarball
#'
#' Hard dependencies include \code{Imports}, \code{Depends} and
#' \code{LinkingTo}.
#'
#' @param package_file Path and name of the tarball.
#' @return A character vector of depended packages. Version numbers
#'   are not included, as we don't need them for the current purposes
#'   of this package.
#'
#' @keywords internal

get_deps <- function(package_file) {

  desc <- get_description(package_file)
  deps_present<- intersect(hard_dep_types, names(desc))

  deps <- desc[deps_present]

  deps_df <- lapply(names(deps), function(x) parse_deps(x, deps[[x]]))

  dep_pkgs <- do.call(rbind, deps_df)$package %||% character()

  drop_internal(dep_pkgs)
}

#' Drop base and recommended packages, and \sQuote{R} from a list
#' of R packages
#'
#' \sQuote{R} can be included in the DESCRIPTION file, as a dependency,
#' but we ignore this right now. We also ignore base and recommended
#' packages, these are supposed to be installed on the system, together
#' with R.
#'
#' @param pkgs Character vector of package names.
#' @return Character vector of filtered package names.
#'
#' @importFrom utils installed.packages
#' @keywords internal

drop_internal <- function(pkgs) {

  internal <- c(
    "R",
    rownames(installed.packages(priority = c("base", "recommended")))
  )

  pkgs <- setdiff(pkgs, internal)
}

#' Parse a DESCRIPTION dependency field
#'
#' @param type Field name, e.g. \code{Imports}.
#' @param deps The value of the field.
#' @return A data frame with three columns: \code{type},
#'   \code{package} and \code{version}.
#'
#' @keywords internal

parse_deps <- function(type, deps) {
  deps <- str_trim(strsplit(deps, ",")[[1]])
  deps <- lapply(strsplit(deps, "\\("), str_trim)
  deps <- lapply(deps, sub, pattern = "\\)$", replacement = "")
  res <- data.frame(
    stringsAsFactors = FALSE,
    type = type,
    package = vapply(deps, "[", "", 1),
    version = vapply(deps, "[", "", 2)
  )
  res [ is.na(res) ] <- "*"
  res
}
