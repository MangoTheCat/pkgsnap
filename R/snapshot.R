
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
#' @return A two columns data frame, invisibly if it was
#'   written to a file.
#'
#' @export
#' @importFrom utils installed.packages write.csv
#' @examples
#' snap(to = tmp <- tempfile())
#'
#' head(read.csv(tmp))

snap <- function(to = "packages.csv") {
  pkgs <- installed.packages(priority = NA_character_)
  pkgs <- pkgs[, c("Package", "Version"), drop = FALSE]
  rownames(pkgs) <- NULL
  pkgs <- as.data.frame(pkgs, stringsAsFactors = FALSE)

  if (!is.null(to)) {
    write.csv(pkgs, file = to, row.names = FALSE)
    invisible(pkgs)
  } else {
    pkgs
  }
}
