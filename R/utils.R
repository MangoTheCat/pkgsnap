
#' LHS if not \code{NULL}, otherwise RHS
#'
#' @param l LHS.
#' @param r RHS.
#' @return LHS if not \code{NULL}, otherwise RHS.
#'
#' @keywords internal

`%||%` <- function(l, r) {
  if (is.null(l)) r else l
}

#' Create a data frame, more robust than \code{data.frame}
#'
#' It does not create factor columns.
#' It recycles columns to match the longest column.
#'
#' @param ... Data frame columns.
#' @return The constructed data frame.
#'
#' @keywords internal

data_frame <- function(...) {

  args <- list(...)

  ## Replicate arguments if needed
  len <- vapply(args, length, numeric(1))
  stopifnot(length(setdiff(len, 1)) <= 1)
  len <- max(0, max(len))
  args <- lapply(args, function(x) rep(x, length.out = len))

  ## Names
  names <- as.character(names(args))
  length(names) <- length(args)
  names <- ifelse(
    is.na(names) | names == "",
    paste0("V", seq_along(args)),
    names)

  structure(args,
            class = "data.frame",
            names = names,
            row.names = seq_along(args[[1]]))
}

#' Check if a directory exists
#'
#' @param dir Directory to check.
#' @return Logical scalar.
#'
#' @keywords internal

dir_exists <- function(dir) {
  file.exists(dir) & file.info(dir)$isdir
}

#' Trim whitespace from the beginning and end of a string
#'
#' @param x Input string or character vector.
#' @return Trimmed character vector.

str_trim <- function(x) {
  sub("\\s*$", "", sub("^\\s*", "", x))
}

#' Split pkg-version into data frame with pkg and version
#'
#' @param pkgs Character vector of package versions in the
#'   \code{packagename-version} format.
#' @return Data frame with columns \code{name} and \code{version}.
#'
#' @keywords internal

split_pkg_names_versions <- function(pkgs) {

  if (!length(pkgs)) {
    return(data_frame(name = character(), version = character()))
  }

  pkgtab <- data_frame(
    name = sub("-.*$", "", pkgs),
    version = sub("^[^-]*-?", "", pkgs)
  )

  stopifnot(all(!is.na(pkgtab$name)))

  pkgtab
}

#' Extract the package name from a package tarball path or filename
#'
#' @param path The package tarball path(s).
#' @return Package name(s).
#'
#' @keywords internal

pkg_from_filename <- function(path) {
  sub("_.*$", "", basename(path))
}
