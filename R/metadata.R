
extra_fields <- c("Repository", "biocViews", "RemoteType", "RemoteUrl")

get_package_metadata <- function(lib.loc, priority) {
  pkgs <- installed.packages(
    lib.loc = lib.loc,
    priority = priority,
    fields = extra_fields
  )

  sources <- get_package_sources(pkgs)

  pkgs <- cbind(pkgs[, c("Package", "Version"), drop = FALSE], sources)

  rownames(pkgs) <- NULL
  as.data.frame(pkgs, stringsAsFactors = FALSE)
}

#' Check where a package was installed from
#'
#' @param pkgs The matrix of parsed DESCRIPTION files,
#'   out of `installed.packages`.
#' @return Two columns, source and link
#'
#' @keywords internal

get_package_sources <- function(pkgs) {
  source <- rep(NA, nrow(pkgs))
  link <- rep(NA, nrow(pkgs))

  ## CRAN
  cran <- vapply(pkgs[, "Repository"], identical, TRUE, y = "CRAN")
  source[cran] <- "cran"

  ## R-Forge
  rforge <- vapply(pkgs[, "Repository"], identical, TRUE, y = "R-Forge")
  source[rforge] <- "rforge"

  ## BioC
  bioc <- ! vapply(pkgs[, "biocViews" ], is.na, TRUE)
  source[bioc] <- "bioc"

  ## Packages installed from URLs via devtools::install_url or
  ## remotes::install_url
  url <-
    vapply(pkgs[, "RemoteType"], identical, TRUE, y = "url") &
    ! vapply(pkgs[, "RemoteUrl"], is.na, TRUE)
  source[url] <- "url"
  link[url] <- pkgs[url, "RemoteUrl"]

  cbind(Source = source, Link = link)
}
