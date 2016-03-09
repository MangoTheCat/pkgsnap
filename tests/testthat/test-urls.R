
context("Download URLs")

test_that("URLs for CRAN packages", {

  skip_on_cran()
  skip_if_offline()

  ## Get latest version of pkgconfig, TODO
  latest <- "2.0.0"

  pkgs <- data.frame(
    stringsAsFactors = FALSE,
    Package = c("pkgconfig", "pkgconfig"),
    Version = c(latest, "1.0.0"),
    Source = c("cran", "cran"),
    Link = c(NA_character_, NA_character_)
  )

  urls <- download_urls(pkgs)
  expect_true(any(
    grepl(paste0("pkgconfig_", latest, ".tar.gz"), urls[[1]], fixed = TRUE)
  ))
  expect_true(any(
    grepl("pkgconfig_1.0.0.tar.gz", urls[[2]], fixed = TRUE)
  ))
})


test_that("URLs for url packages", {

  pkgs <- data.frame(
    stringsAsFactors = FALSE,
    Package = c("pkgconfig", "pkgconfig"),
    Version = c("1.0.0", "2.0.0"),
    Source = c("cran", "url"),
    Link = c(NA_character_, "https://dummy-link.com")
  )

  urls <- download_urls(pkgs)
  expect_true(any(
    grep(paste0("pkgconfig_1.0.0.tar.gz"), urls[[1]], fixed = TRUE)
  ))
  expect_true(any(
    grep("https://dummy-link.com", urls[[2]], fixed = TRUE)
  ))
})
