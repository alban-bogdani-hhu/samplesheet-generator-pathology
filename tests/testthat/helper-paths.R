# testthat runs with wd = tests/testthat.
# Resolve paths relative to the project root instead.
proj_file <- function(...) {
  file.path(testthat::test_path("..", ".."), ...)
}