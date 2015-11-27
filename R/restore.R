
#' Restore (=install) certain CRAN package versions
#'
#' Functions that were not installed from CRAN will not be restored,
#' they will be ignored with a warning.
#'
#' @param from Name of a file created by \code{\link{snap}}.
#'   Alternatively a data frame with columns \code{Package} and
#'   \code{Version}.
#' @param ... Additional arguments, passed to \code{install.packages}.
#'
#' @export
#' @importFrom utils install.packages read.csv

restore <- function(from = "packages.csv", ...) {

  if (is.character(from)) {
    pkgs <- read.csv(from, stringsAsFactors = FALSE)

  } else {
    pkgs <- from
  }

  pkg_files <- pkg_download(
    paste(pkgs$Package, sep = "-", pkgs$Version),
    dest_dir = tempdir()
  )
  names(pkg_files) <- pkgs$Package

  ## Ignore non-CRAN packages
  pkg_files <- na.omit(pkg_files)

  deps <- lapply(pkg_files, get_deps)

  deps <- drop_missing_deps(deps)

  order <- install_order(deps)

  message("Installing")
  for (p in pkg_files[order]) {
    message("  ", basename(p), " ... ", appendLF = FALSE)
    install.packages(p, repos = NULL, quiet = TRUE, ...)
    message("done.")
  }
}

#' Drop dependencies that were not included in the snapshot
#'
#' These are probably not needed for the installed functions
#' to work.
#'
#' @param deps A named list of character vectors.
#' @return A (filtered) named list of character vectors.
#'
#' @keywords internal

drop_missing_deps <- function(deps) {
  pkgs <- names(deps)
  lapply(deps, intersect, pkgs)
}

#' Topological order of the packages
#'
#' This is the correct installation order.
#'
#' @param graph A named list of character vectors, interpreted as
#'   an adjacnecy list. If \code{A->B} then package \code{A} depends
#'   on package \code{B}, so package \code{B} must be loaded before
#'   package \code{A}.
#' @return Character vector of package names in an order that
#'   can be used to install them.
#'
#' @keywords internal

install_order <- function(graph) {

  V <- names(graph)
  N <- length(V)

  ## some easy cases
  if (length(graph) <= 1 ||
      sum(sapply(graph, length)) == 0) return(V)

  marked <- 1L; temp_marked <- 2L; unmarked <- 3L
  marks <- structure(rep(unmarked, N), names = V)
  result <- character(N)
  result_ptr <- N

  visit <- function(n) {
    if (marks[n] == temp_marked) {
      stop("Dependency graph not a DAG: ", n, ", internal error")
    }
    if (marks[n] == unmarked) {
      marks[n] <<- temp_marked
      for (m in graph[[n]]) visit(m)
      marks[n] <<- marked
      result[result_ptr] <<- n
      result_ptr <<- result_ptr - 1
    }
  }

  while (any(marks == unmarked)) {
    visit(names(which(marks == unmarked))[1])
  }

  rev(result)
}
