
#' Write installed package versions to a file
#'
#' Base and recommended packages are omitted.
#' Packages that were installed from non-CRAN sources are
#' also included, but you won't be able to restore them
#' with \code{\link{restore}}.
#'
#' The output file will have two columns, package name
#' and package version.
#'
#' @param to File to write the package versions to,
#'   defaults to \code{packages.csv}. If it is NULL,
#'   to output file is created and the result is returned
#'   as a data frame.
#' @param lib.loc character vector describing the 
#'   location of R library trees to search through, or 
#'   \code{NULL} for all known trees (see 
#'   \code{\link[base]{.libPaths}}).
#' @param recommended if TRUE then recommended packages
#'   will be included in the snapshot.
#' @return A two columns data frame, invisibly if it was
#'   written to a file.
#'
#' @export
#' @importFrom utils installed.packages write.csv
#' @examples
#' snap(to = tmp <- tempfile())
#'
#' head(read.csv(tmp))

snap <- function(to = "packages.csv", lib.loc = NULL, recommended = FALSE) {
  
  priority <- if (recommended) c( "recommended", NA_character_) else NA_character_ 
  
  pkgs <- get_package_metadata(lib.loc = lib.loc, priority = priority)

  # Add the R version to the top of the list
  pkgs <- add_R_core(pkgs)
  
  if (!is.null(to)) {
    write.csv(pkgs, file = to, row.names = FALSE)
    invisible(pkgs)
  } else {
    pkgs
  }
}

#' Add R version to package inventory
#'
#' @param pkgs data.frame of installed packages with columns Package and Version.
#'
#' @return The same data.frame with the R version listed as "R" and the
#' version in major.minor format (e.g. R 3.2.2).
#'
#' @keywords internal
#' 
add_R_core <- function(pkgs) {
  
  # Check it's in the format we're expecting
  if(length(pkgs) != 4) stop("pkgs does not have 2 columns")
  if(!all(names(pkgs) == c("Package", "Version", "Source", "Link"))) {
    stop("pkgs Col names should be Package, Version, Source, Link")
  }
  
  coreVersion <- paste(R.version$major, R.version$minor, sep = ".")
  
  coreEntry <- data.frame(
    Package = "R",
    Version = coreVersion,
    Source = "R",
    Link = NA_character_,
    stringsAsFactors = FALSE
  )

  rbind(coreEntry, pkgs)
}
