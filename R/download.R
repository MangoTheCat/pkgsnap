
#' Download R packages (or other files)
#'
#' @param pkgs A character vector of URLs to try.
#' @param dest_dir Destination directory for the downloaded files.
#'   The actual file names are extracted from the URLs.
#' @return Path to the downloaded file, or \code{NA_character_}
#'   if all URLs failed.
#'
#' @keywords internal

pkg_download <- function(pkgs, dest_dir = ".") {
  pkgs <- as.character(pkgs)
  dest_dir <- as.character(dest_dir)

  stopifnot(all(!is.na(pkgs)))

  stopifnot(all(!is.na(dest_dir)), length(dest_dir) == 1)
  stopifnot(dir_exists(dest_dir))

  message("Downloading")
  urls <- download_urls(pkgs)
  result <- vapply(seq_along(pkgs), FUN.VALUE = "", FUN = function(i) {
    url <- urls[[i]]
    if (! length(url)) message("  ", pkgs[i], " Error: no files.")
    res <- FALSE
    for (u in url) {
      dest_file <- file.path(dest_dir, filename_from_url(u, pkgs[i]))
      message("  ", basename(u), "... ", appendLF = FALSE)
      if (res <- try_download(u, dest_file)) break
    }
    if (length(url)) message(if (res) " done." else "ERROR.")

    if (!res) {
      warning("Cannot download package ", pkgs[i], call. = FALSE)
      NA_character_

    } else {
      dest_file
    }
  })

  names(result) <- pkgs
  invisible(result)
}

#' Extract a file name from a package download URL
#'
#' This is usually just the part after the last slash,
#' but for https://github.com/cran/* URLs it is a bit trickier.
#'
#' @param url The URL, a character scalar.
#' @param pkg The name of the package the URL belongs to.
#' @return Character scalar, the file name.
#'
#' @keywords internal

filename_from_url <- function(url, pkg) {
  if (grepl("^https://[^/\\.]*\\.github.com/", url)) {
    paste0(sub("^[a-z]+:", "", sub("-", "_", pkg)), ".tar.gz")
  } else {
    basename(url)
  }
}

#' Try to download a file
#'
#' @param url Download URL.
#' @param dest_file Where to put the downloaded file.
#' @return \code{TRUE} if the download was successful, \code{FALSE}
#'   otherwise.
#'
#' @importFrom utils download.file
#' @keywords internal

try_download <- function(url, dest_file) {

  if (file.exists(dest_file)) return(TRUE)

  resp <- try(
    suppressWarnings(
      download.file(url, destfile = dest_file, quiet = TRUE)
    ),
    silent = TRUE
  )

  if (inherits(resp, "try-error")) {
    unlink(dest_file, recursive = TRUE, force = TRUE)
    FALSE
  } else {
    TRUE
  }
}
