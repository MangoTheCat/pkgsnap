
extra_fields <- c("Repository", "biocViews")

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

  source[vapply(pkgs[, "Repository"], identical, TRUE, y = "CRAN")] <- "cran"
  source[! vapply(pkgs[, "biocViews" ], is.na, TRUE)] <- "bioc"

  cbind(Source = source, Link = link)
}
