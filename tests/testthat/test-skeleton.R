test_that("frozen index table is present and complete", {
  path <- proj_file(CONFIG$index_table)
  expect_true(file.exists(path))
  
  tbl <- read.csv(path, comment.char = "#", stringsAsFactors = FALSE)
  expect_equal(nrow(tbl), 96)
  expect_true(all(c("index_name", CONFIG$i7_column, CONFIG$i5_column)
                  %in% names(tbl)))
  expect_equal(anyDuplicated(tbl$index_name), 0L)
})

test_that("WES template is present and ends at the data header", {
  path <- proj_file(CONFIG$template)
  expect_true(file.exists(path))
  
  raw   <- readChar(path, file.size(path), useBytes = TRUE)
  lines <- strsplit(raw, "\r\n", fixed = TRUE)[[1]]
  
  expect_true(any(grepl(CONFIG$runname_token, lines, fixed = TRUE)))
  expect_equal(lines[length(lines)], "Sample_ID,index,index2,Sample_Project")
})

test_that("reference fixture is CRLF and anonymized", {
  path <- testthat::test_path("fixtures", "reference-samplesheet.csv")
  expect_true(file.exists(path))
  
  raw <- readChar(path, file.size(path), useBytes = TRUE)
  expect_true(grepl("\r\n", raw, fixed = TRUE))
  
  ids <- regmatches(raw, gregexpr("[0-9]{4}-[0-9]{2}_", raw))[[1]]
  expect_true(all(grepl("^000", ids)))
})