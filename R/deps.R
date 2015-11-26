
dep_types <- c("Imports", "Depends", "Suggests", "Enhances", "LinkingTo")

hard_dep_types <- c("Imports", "Depends", "LinkingTo")

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

get_deps <- function(package_file) {

  desc <- get_description(package_file)
  deps_present<- intersect(hard_dep_types, names(desc))

  deps <- desc[deps_present]

  deps_df <- lapply(names(deps), function(x) parse_deps(x, deps[[x]]))

  dep_pkgs <- do.call(rbind, deps_df)$package %||% character()

  drop_internal(dep_pkgs)
}

#' @importFrom utils installed.packages

drop_internal <- function(pkgs) {

  internal <- c(
    "R",
    rownames(installed.packages(priority = c("base", "recommended")))
  )

  pkgs <- setdiff(pkgs, internal)
}

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
