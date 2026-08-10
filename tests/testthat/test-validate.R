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

# --- template_index_cycles ------------------------------------------------

test_that("template_index_cycles reads cycles from the template", {
  cyc <- template_index_cycles(test_cfg())
  expect_equal(cyc[["i7"]], 10L)
  expect_equal(cyc[["i5"]], 10L)
})

# --- validate_run ---------------------------------------------------------

# a small valid pool, 10bp indexes, matching the template
.good_pool <- function() {
  data.frame(
    sample_id      = c("1234-26_3-N", "1234-26_1-T"),
    index_name     = c("UDP0001", "UDP0002"),
    i7             = c("AAAAAAAAAA", "CCCCCCCCCC"),
    i5             = c("GGGGGGGGGG", "TTTTTTTTTT"),
    sample_project = "WES_Patho",
    stringsAsFactors = FALSE
  )
}

test_that("validate_run passes a clean pool", {
  res <- validate_run(.good_pool(), test_cfg())
  expect_equal(res$errors, character(0))
  expect_equal(res$warnings, character(0))
})

test_that("validate_run flags duplicate Sample_ID", {
  p <- .good_pool(); p$sample_id[2] <- p$sample_id[1]
  res <- validate_run(p, test_cfg())
  expect_true(any(grepl("Duplicate Sample_ID", res$errors)))
})

test_that("validate_run flags a duplicate index pair", {
  p <- .good_pool(); p$i7[2] <- p$i7[1]; p$i5[2] <- p$i5[1]
  res <- validate_run(p, test_cfg())
  expect_true(any(grepl("Duplicate index pair", res$errors)))
  # names the samples involved
  expect_true(any(grepl("1234-26_3-N", res$errors)))
})

test_that("validate_run flags index length mismatch", {
  p <- .good_pool(); p$i7[1] <- "AAAA"     # 4bp, not 10
  res <- validate_run(p, test_cfg())
  expect_true(any(grepl("i7 length", res$errors)))
})

test_that("validate_run collects per-row ID errors and pattern warnings", {
  p <- .good_pool()
  p$sample_id[1] <- "bad name"       # illegal char -> error
  p$sample_id[2] <- "NA12878"        # valid but off-pattern -> warning
  res <- validate_run(p, test_cfg())
  expect_true(any(grepl("Row 1", res$errors)))
  expect_true(any(grepl("Row 2", res$warnings)))
})

test_that("validate_run handles an empty pool", {
  res <- validate_run(.good_pool()[0, ], test_cfg())
  expect_length(res$errors, 1)
})
