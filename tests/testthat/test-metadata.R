
context("Getting package metadata")

test_that("works well for CRAN packages", {

  skip_on_cran()
  skip_if_offline()

  tmp <- tempfile()
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  
  install.packages("pkgconfig", lib = tmp, quiet = TRUE)
  install.packages("falsy", lib = tmp, quiet = TRUE)

  pkgs <- get_package_metadata(tmp, priority = NA_character_)

  expect_equal(
    pkgs$Source,
    c("cran", "cran")
  )

})

test_that("works for bioc packages", {

  skip_on_cran()
  skip_if_offline()

  tmp <- tempfile()
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  
  install.packages("pkgconfig", lib = tmp, quiet = TRUE)
  suppressWarnings(
    remotes::install_github(
      "Bioconductor-mirror/BiocInstaller",
      lib = tmp,
      quiet = TRUE
    )
  )

  pkgs <- get_package_metadata(tmp, priority = NA_character_)

  expect_equal(
    pkgs$Source,
    c("bioc", "cran")
  )

})