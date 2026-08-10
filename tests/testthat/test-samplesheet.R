# render_template reads cfg$template (a project-root-relative path). testthat's
# working directory is not reliably the project root, so we hand render_template
# an absolute template path resolved via test_path(), which is correct
# regardless of wd -- the same approach proj_file() uses in test-indexes.R.
test_cfg <- function() {
  cfg <- CONFIG
  cfg$template <- testthat::test_path("..", "..", CONFIG$template)
  cfg
}

test_that("render_template substitutes a provided run name", {
  out <- render_template("20260101_TEST", test_cfg())

  expect_false(any(grepl(CONFIG$runname_token, out, fixed = TRUE)))
  expect_true(any(out == "RunName,20260101_TEST"))
})

test_that("render_template writes the configured literal for empty names", {
  expected <- paste0("RunName,", CONFIG$empty_runname_value)

  for (empty in list(NULL, "", NA_character_)) {
    out <- render_template(empty, test_cfg())
    expect_true(any(out == expected),
                info = paste("failed for:", deparse(empty)))
  }
})

test_that("render_template never emits R's NA in the RunName line", {
  out <- render_template(NA, test_cfg())
  runname_line <- grep("^RunName,", out, value = TRUE)

  expect_length(runname_line, 1)
  expect_equal(runname_line, paste0("RunName,", CONFIG$empty_runname_value))
  expect_false(runname_line == "RunName,")
})

test_that("render_template ends at the data header", {
  out <- render_template("X", test_cfg())
  expect_equal(out[length(out)], "Sample_ID,index,index2,Sample_Project")
})
