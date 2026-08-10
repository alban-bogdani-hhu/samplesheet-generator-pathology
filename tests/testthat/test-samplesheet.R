# render_template reads cfg$template (a project-root-relative path). testthat's
# working directory is not reliably the project root, so we hand render_template
# an absolute template path resolved via test_path(), which is correct
# regardless of wd -- the same approach proj_file() uses in test-indexes.R.

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

test_that("samplesheet_filename builds the D-004 pattern", {
  expect_equal(samplesheet_filename("20260101_LH00535", CONFIG),
               "20260101_LH00535-samplesheet.csv")
})

test_that("samplesheet_filename falls back on empty run name", {
  expected <- sprintf(CONFIG$filename_pattern, CONFIG$empty_runname_value)
  for (empty in list(NULL, "", NA_character_)) {
    expect_equal(samplesheet_filename(empty, CONFIG), expected)
  }
})

test_that("samplesheet_filename strips Windows-illegal characters", {
  # slash, colon, etc. must not survive into a filename
  out <- samplesheet_filename("bad/name:v1", CONFIG)
  expect_false(grepl("[/:]", out))
  expect_match(out, "-samplesheet\\.csv$")
})

# --- build_samplesheet -----------------------------------------------------

test_that("build_samplesheet appends one data row per sample, in order", {
  samples <- data.frame(
    sample_id      = c("A-26_1-T", "B-26_3-N"),
    i7             = c("AAAAAAAAAA", "CCCCCCCCCC"),
    i5             = c("GGGGGGGGGG", "TTTTTTTTTT"),
    sample_project = c("WES_Patho", "WES_Patho"),
    stringsAsFactors = FALSE
  )
  out <- build_samplesheet(samples, "RUN1", test_cfg())
  
  # data header present, then exactly the two rows in input order
  hdr <- which(out == "Sample_ID,index,index2,Sample_Project")
  expect_length(hdr, 1)
  expect_equal(out[hdr + 1], "A-26_1-T,AAAAAAAAAA,GGGGGGGGGG,WES_Patho")
  expect_equal(out[hdr + 2], "B-26_3-N,CCCCCCCCCC,TTTTTTTTTT,WES_Patho")
  expect_equal(length(out), hdr + 2)   # nothing after the last row
})

test_that("build_samplesheet rejects missing columns and empty input", {
  good <- data.frame(sample_id = "A", i7 = "A", i5 = "C",
                     sample_project = "P", stringsAsFactors = FALSE)
  expect_error(build_samplesheet(good[, -2], "R", test_cfg()), "missing column")
  expect_error(build_samplesheet(good[0, ], "R", test_cfg()), "zero samples")
})

# --- write_samplesheet -----------------------------------------------------

test_that("write_samplesheet produces CRLF and no trailing blank line", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))
  
  write_samplesheet(c("line1", "line2", "last"), tmp, CONFIG)
  
  raw <- readChar(tmp, file.size(tmp), useBytes = TRUE)
  expect_equal(raw, "line1\r\nline2\r\nlast\r\n")
  # every line ends CRLF, file ends with exactly one CRLF
  expect_true(endsWith(raw, "\r\n"))
  expect_false(endsWith(raw, "\r\n\r\n"))
})

test_that("write_samplesheet writes bytes verbatim regardless of platform", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))
  write_samplesheet("x", tmp, CONFIG)
  
  # exactly 3 bytes: 'x', CR, LF -- no LF-only, no CRCRLF
  expect_equal(file.size(tmp), 3)
})
