
cran_mirror <- "http://cran.rstudio.com"

r_minor_version <- function() {
  ver <- R.Version()
  paste0(ver$major, ".", strsplit(ver$minor, ".", fixed = TRUE)[[1]][1])
}

get_pkg_type <- function() {
  "both"
}

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

download_urls <- function(pkgs) {
  pkgtab <- split_pkg_names_versions(pkgs)
  stopifnot(all(pkgtab$version != ""))

  lapply(seq_along(pkgs), function(i) {
    pkg <- pkgtab[i,]
    cran_file(pkg["name"], pkg["version"])
  })
}

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

filename_from_url <- function(url, pkg) {
  if (grepl("^https://[^/\\.]*\\.github.com/", url)) {
    paste0(sub("-", "_", pkg), ".tar.gz")
  } else {
    basename(url)
  }
}

#' @importFrom utils download.file

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
