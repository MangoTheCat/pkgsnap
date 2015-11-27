
#' CRAN mirror to use
#'
#' The RStudio mirror is in the Amazon cloud, so most times it has
#' the best response times, and download speed.
#' @keywords internal

cran_mirror <- "http://cran.rstudio.com"

#' Extract the minor version of the running R
#'
#' This is needed to calculate possible R package locations
#' for downloads.
#' @keywords internal

r_minor_version <- function() {
  ver <- R.Version()
  paste0(ver$major, ".", strsplit(ver$minor, ".", fixed = TRUE)[[1]][1])
}

#' What kind of packages to use by default.
#'
#' \code{both} means binaries first, then source packages.
#' @keywords internal

get_pkg_type <- function() {
  "both"
}

#' Get a list of candidate URLs for a certain version of a package
#'
#' @param package Name of the package, e.g. \code{jsonlite}.
#' @param version Version number of the package, as a string, e.g.
#'   \code{1.0.0}.
#' @param type Package type, e.g. \code{binary}, \code{source}, etc.
#'   See the \code{type} argument of \code{utils::install.packages}.
#' @param r_minor The minor R version to search for packages for.
#'   Defaults to the currently running R version.
#' @return Character vector or URLs.
#'
#' @keywords internal

cran_file <- function(package, version, type = get_pkg_type(),
                      r_minor = r_minor_version()) {

  if (type == "both") {
    c(cran_file(package, version, type = "binary", r_minor = r_minor),
      cran_file(package, version, type = "source", r_minor = r_minor))
  } else if (type == "binary") {
    cran_file(package, version, type = .Platform$pkgType, r_minor = r_minor)
  } else if (type == "source") {
    c(sprintf("%s/src/contrib/%s_%s.tar.gz", cran_mirror, package, version),
      sprintf("%s/src/contrib/Archive/%s/%s_%s.tar.gz", cran_mirror,
              package, package, version))
  } else if (type == "win.binary") {
    sprintf("%s/bin/windows/contrib/%s/%s_%s.zip", cran_mirror, r_minor,
            package, version)
  } else if (type == "mac.binary.mavericks") {
    sprintf("%s/bin/macosx/mavericks/contrib/%s/%s_%s.tgz", cran_mirror,
            r_minor, package, version)
  } else if (type == "mac.binary") {
    sprintf("%s/bin/macosx/contrib/%s/%s_%s.tgz", cran_mirror, r_minor,
            package, version)
  } else {
    stop("Unknown package type: ", type, " see ?options.")
  }
}

#' Get download urls for a bunch of packages
#'
#' @param pkgs Character vector of packages, including package
#'   versions, separated by a dash.
#' @return A list of character vectors, a set of URLs for each package.
#'
#' @keywords internal

download_urls <- function(pkgs) {
  pkgtab <- split_pkg_names_versions(pkgs)
  stopifnot(all(pkgtab$version != ""))

  lapply(seq_along(pkgs), function(i) {
    pkg <- pkgtab[i,]
    cran_file(pkg["name"], pkg["version"])
  })
}

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
  res <- vapply(seq_along(pkgs), FUN.VALUE = "", FUN = function(i) {
    url <- urls[[i]]
    for (u in url) {
      dest_file <- file.path(dest_dir, filename_from_url(u, pkgs[i]))
      message("  ", basename(u), "... ", appendLF = FALSE)
      if (res <- try_download(u, dest_file)) break
    }
    message(if (res) " done." else "ERROR.")

    if (!res) {
      warning("Cannot download package ", pkgs[i], call. = FALSE)
      NA_character_

    } else {
      dest_file
    }
  })

  names(res) <- pkgs
  invisible(res)
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
    paste0(sub("-", "_", pkg), ".tar.gz")
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
