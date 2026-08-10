test_that("load_index_table reads the frozen table", {
  tbl <- load_index_table(proj_file(CONFIG$index_table))
  
  expect_s3_class(tbl, "data.frame")
  expect_equal(nrow(tbl), 96)
  expect_true(all(c("index_name", CONFIG$i7_column, CONFIG$i5_column)
                  %in% names(tbl)))
  
  # sequences stayed as character, not coerced
  expect_type(tbl[[CONFIG$i7_column]], "character")
})

test_that("load_index_table fails clearly on a missing file", {
  expect_error(
    load_index_table("does/not/exist.csv"),
    "Index table not found"
  )
})

test_that("load_index_table rejects a table missing required columns", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))
  writeLines(c("index_name,something_else", "UDP0001,ACGT"), tmp)
  
  expect_error(load_index_table(tmp), "missing required column")
})

test_that("load_index_table rejects duplicate index names", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))
  writeLines(
    c(paste("index_name", CONFIG$i7_column, CONFIG$i5_column, sep = ","),
      "UDP0001,AAAAAAAAAA,CCCCCCCCCC",
      "UDP0001,GGGGGGGGGG,TTTTTTTTTT"),
    tmp
  )
  expect_error(load_index_table(tmp), "duplicate index names")
})