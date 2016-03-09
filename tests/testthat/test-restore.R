
context("Restore")

test_that("CRAN packages are fine", {

  skip_on_cran()
  skip_if_offline()

  tmp <- tempfile()
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  withr::with_libpaths(tmp, {
    ## Install
    install.packages("pkgconfig", lib = tmp, quiet = TRUE)
    source("https://bioconductor.org/biocLite.R")
    biocLite("BiocGenerics", lib = tmp, quiet = TRUE, ask = FALSE,
             suppressUpdates = TRUE)

    ## Snapshot
    pkgs <- tempfile()
    snap(to = pkgs, lib.loc = tmp)

    ## Remove
    unlink(tmp, recursive = TRUE)
    dir.create(tmp)

    ## Restore
    restore(from = pkgs, lib = tmp)

    ## Check
    inst <- installed.packages(lib = tmp)
    expect_equal(rownames(inst), c("BiocGenerics", "pkgconfig"))
  })
})


test_that("Packages from URLs are fine", {

  skip_on_cran()
  skip_if_offline()

  tmp <- tempfile()
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  ## Install
  install.packages("pkgconfig", lib = tmp, quiet = TRUE)
  remotes::install_url(
    "https://cran.rstudio.com/src/contrib/sankey_1.0.0.tar.gz",
    lib = tmp,
    quiet = TRUE
  )

  ## Snapshot
  pkgs <- tempfile()
  snap(to = pkgs, lib.loc = tmp)

  ## Remove
  unlink(tmp, recursive = TRUE)
  dir.create(tmp)

  ## Restore
  restore(from = pkgs, lib = tmp)

  ## Check
  inst <- installed.packages(lib = tmp)
  expect_equal(rownames(inst), c("pkgconfig", "sankey"))

})

test_that("Packages from R-Forge are fine", {

  skip_on_cran()
  skip_if_offline()

  tmp <- tempfile()
  dir.create(tmp)
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)

  ## Install
  install.packages("pkgconfig", lib = tmp, quiet = TRUE)
  suppressWarnings(
    install.packages(
      "MSToolkit",
      repos = "http://R-Forge.R-project.org",
      lib = tmp,
      quiet = TRUE
    )
  )

  ## Snapshot
  pkgs <- tempfile()
  snap(to = pkgs, lib.loc = tmp)

  ## Remove
  unlink(tmp, recursive = TRUE)
  dir.create(tmp)

  ## Restore
  restore(from = pkgs, lib = tmp)

  ## Check
  inst <- installed.packages(lib = tmp)
  expect_equal(rownames(inst), c("MSToolkit", "pkgconfig"))

})
