# This project is not loaded as a package, so source R/ explicitly for tests.
# Paths are anchored per-test via test_path(), not via the working directory.
for (f in list.files(
  testthat::test_path("..", "..", "R"),
  pattern = "[.]R$", full.names = TRUE
)) {
  source(f)
}
