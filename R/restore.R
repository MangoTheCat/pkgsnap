
#' Restore (=install) certain CRAN package versions
#'
#' Functions that were not installed from CRAN will not be restored,
#' they will be ignored with a warning. The pkgsnap package itself is
#' also ignored as it must be installed to run this function.
#'
#' @param from Name of a file created by \code{\link{snap}}.
#'   Alternatively a data frame with columns \code{Package} and
#'   \code{Version}.
#' @param R If TRUE the target version of R must match.
#' Otherwise it will only give a warning.
#' @param ... Additional arguments, passed to \code{install.packages}.
#'
#' @export
#' @importFrom utils install.packages read.csv

restore <- function(from = "packages.csv", R = TRUE, ...) {

  if (is.character(from)) {
    pkgs <- read.csv(from, stringsAsFactors = FALSE)

  } else {
    pkgs <- from
  }
  
  # Check the R version and remove from the list
  pkgs <- check_R_core(pkgs, R)
  
  # Remove this package (pkgsnap) from the list
  pkgs <- pkgs[pkgs$Package!="pkgsnap", ]

  # Don't try to install packages that have an unknown source
  unknown_source_rows <- is.na(pkgs$Source)
  if (any(unknown_source_rows)) {
    warning(
      "Source repository is unknown for ",
      paste(pkgs$Package[unknown_source_rows], collapse = ", ")
    )
  }
  pkgs <- pkgs[!unknown_source_rows, ]

  ## Download and return the downloaded file names
  pkg_files <- pkg_download(pkgs, dest_dir = tempdir())

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

#' Check listed R version against installed
#'
#' @param pkgs data.frame read from the csv file.
#' @param R If TRUE it will error when the R versions mismatch.
#' Otherwise it will just give a warning.
#' @return The same data.frame with the R package removed.
#'
#' @keywords internal
#' 
check_R_core <- function(pkgs, R) {
  
  # Find the row containing R
  ir <- which(pkgs$Package == "R")
  
  if (length(ir) == 1) {
    # The R version on this installation
    coreVersion <- paste(R.version$major, R.version$minor, sep = ".")
    pkgsVersion <- pkgs$Version[ir]
    
    if(pkgsVersion != coreVersion) {
      if (R) {
        stop("Packages were installed with R ", pkgsVersion,
             ", you have ", coreVersion, ". Call with R = FALSE",
             " to override.")
      } else {
        warning("Packages were installed with R ", pkgsVersion,
                ", you have ", coreVersion, ".")
      }
    }
    # Remove from the manifest
    pkgs <- pkgs[-ir, ]
    
  } else {
    warning("No R version listed with package list.")
  }
  
  pkgs
}
