
#' CRAN mirror to use
#'
#' The RStudio mirror is in the Amazon cloud, so most times it has
#' the best response times, and download speed.
#' @keywords internal

default_cran_mirror <- "http://cran.rstudio.com"

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
                      r_minor = r_minor_version(),
                      cran_mirror = default_cran_mirror) {

  if (type == "both") {
    c(cran_file(package, version, type = "binary", r_minor = r_minor, cran_mirror = cran_mirror),
      cran_file(package, version, type = "source", r_minor = r_minor, cran_mirror = cran_mirror))
  } else if (type == "binary") {
    cran_file(package, version, type = .Platform$pkgType, r_minor = r_minor, cran_mirror = cran_mirror)
  } else if (type == "source") {
    c(sprintf("%s/src/contrib/%s_%s.tar.gz", cran_mirror, package, version),
      sprintf("%s/src/contrib/Archive/%s/%s_%s.tar.gz", cran_mirror,
              package, package, version))
  } else if (type == "win.binary") {
    sprintf("%s/bin/windows/contrib/%s/%s_%s.zip", cran_mirror, r_minor,
            package, version)
  } else if (type == "mac.binary.mavericks") {
    ## We try both, for BioC
    sprintf(c("%s/bin/macosx/mavericks/contrib/%s/%s_%s.tgz",
              "%s/bin/macosx/contrib/%s/%s_%s.tgz"),
            cran_mirror, r_minor, package, version)
  } else if (type == "mac.binary") {
    sprintf("%s/bin/macosx/contrib/%s/%s_%s.tgz", cran_mirror, r_minor,
            package, version)
  } else {
    stop("Unknown package type: ", type, " see ?options.")
  }
}

get_bioc_version <- function() {
  get(".BioC_version_associated_with_R_version", asNamespace("tools"))()
}

bioc_file <- function(...) {

  repos <- sprintf(
    c(
      "http://bioconductor.org/packages/%s/bioc",
      "http://bioconductor.org/packages/%s/data/annotation",
      "http://bioconductor.org/packages/%s/data/experiment",
      "http://bioconductor.org/packages/%s/extra"
    ),
    get_bioc_version()
  )

  unname(unlist(
    lapply(repos, function(r) cran_file(..., cran_mirror = r))
  ))
}

#' Get download urls for a bunch of packages
#'
#' @param pkgs Data frame of packages.
#' @return A list of character vectors, a set of URLs for each package.
#'
#' @keywords internal

download_urls <- function(pkgs) {

  lapply(seq_len(nrow(pkgs)), function(i) {

    if (pkgs$Source[i] == "cran") {
      cran_file(pkgs$Package[i], pkgs$Version[i])

    } else if (pkgs$Source[i] == "bioc") {
      bioc_file(pkgs$Package[i], pkgs$Version[i])

    } else if (pkgs$Source[i] == "url") {
      pkgs$Link[i]

    } else {
      warning("Unknown package source: ", pkgs$repo[i])
    }
  })
}
