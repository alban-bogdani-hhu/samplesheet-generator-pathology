test_that("validate_sample_id accepts a normal pathology ID", {
  expect_equal(validate_sample_id("1234-26_3-N"), character(0))
})

test_that("validate_sample_id accepts valid but non-pathology IDs", {
  # a control sample name -- valid for Illumina, not the pathology pattern
  expect_equal(validate_sample_id("NA12878"), character(0))
  expect_equal(validate_sample_id("Control_1"), character(0))
})

test_that("validate_sample_id rejects illegal characters", {
  expect_length(validate_sample_id("has space"), 1)
  expect_length(validate_sample_id("dot.name"), 1)
  expect_length(validate_sample_id("slash/name"), 1)
})

test_that("validate_sample_id rejects bad separator placement", {
  expect_length(validate_sample_id("-leading"), 1)
  expect_length(validate_sample_id("trailing-"), 1)
  expect_length(validate_sample_id("double__sep"), 1)
  expect_length(validate_sample_id("mixed-_sep"), 1)
})

test_that("validate_sample_id enforces length and reserved words", {
  long <- paste(rep("A", CONFIG$id_max_nchar + 1), collapse = "")
  expect_length(validate_sample_id(long), 1)
  
  expect_length(validate_sample_id("undetermined"), 1)  # reserved
  expect_length(validate_sample_id("UNDETERMINED"), 1)  # case-insensitive
})

test_that("validate_sample_id rejects empty and non-scalar input", {
  expect_length(validate_sample_id(""), 1)
  expect_length(validate_sample_id(NA_character_), 1)
  expect_length(validate_sample_id(c("a", "b")), 1)
})

test_that("validate_sample_id can report multiple problems at once", {
  # too long AND illegal char -> at least 2 messages
  long_bad <- paste0(paste(rep("A", CONFIG$id_max_nchar), collapse = ""), " x")
  expect_gte(length(validate_sample_id(long_bad)), 2)
})



test_that("check_id_pattern passes a conforming ID", {
  expect_equal(check_id_pattern("1234-26_3-N"), character(0))
  expect_equal(check_id_pattern("123-26_1-T"),  character(0))
})

test_that("check_id_pattern warns on a non-conforming ID", {
  expect_length(check_id_pattern("NA12878"), 1)
  expect_length(check_id_pattern("1234-26_3-X"), 1)   # X not N/T
  expect_match(check_id_pattern("weird"), "does not match")
})

test_that("check_id_pattern is silent when mode is off", {
  cfg <- CONFIG
  cfg$id_pattern_mode <- "off"
  expect_equal(check_id_pattern("anything-goes", cfg), character(0))
})

test_that("check_id_pattern says nothing about empty input", {
  # empties are validate_sample_id's job
  expect_equal(check_id_pattern(""), character(0))
  expect_equal(check_id_pattern(NA_character_), character(0))
})
