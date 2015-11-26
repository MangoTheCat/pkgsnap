
`%||%` <- function(l, r) {
  if (is.null(l)) r else l
}

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

dir_exists <- function(dir) {
  file.exists(dir) & file.info(dir)$isdir
}


str_trim <- function(x) {
  sub("\\s*$", "", sub("^\\s*", "", x))
}

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

pkg_from_filename <- function(path) {
  sub("_.*$", "", basename(path))
}
