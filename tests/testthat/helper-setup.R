# This project is not loaded as a package, so source R/ explicitly for tests.
# Paths are anchored per-test via test_path(), not the working directory.
for (f in list.files(
  testthat::test_path("..", "..", "R"),
  pattern = "[.]R$", full.names = TRUE
)) {
  source(f)
}

# Shared test config: override CONFIG paths with absolute ones resolved via
# test_path(), so path-reading functions work regardless of working dir.
test_cfg <- function() {
  cfg <- CONFIG
  cfg$template     <- testthat::test_path("..", "..", CONFIG$template)
  cfg$index_table  <- testthat::test_path("..", "..", CONFIG$index_table)
  cfg
}
