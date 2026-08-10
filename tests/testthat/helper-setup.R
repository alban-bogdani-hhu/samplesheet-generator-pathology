# testthat auto-sources helper-*.R before running tests.
# This project isn't loaded as a package, so we source R/ explicitly here.
for (f in list.files(
  testthat::test_path("..", "..", "R"),
  pattern = "[.]R$", full.names = TRUE
)) {
  source(f)
}