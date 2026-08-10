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

test_that("resolve_index returns the configured i7/i5 for a known name", {
  tbl <- load_index_table(proj_file(CONFIG$index_table))
  res <- resolve_index(tbl, "UDP0001")
  
  expect_named(res, c("i7", "i5"))
  expect_type(res$i7, "character")
  expect_type(res$i5, "character")
  
  # matches the table row directly
  row <- which(tbl$index_name == "UDP0001")
  expect_equal(res$i7, tbl[[CONFIG$i7_column]][row])
  expect_equal(res$i5, tbl[[CONFIG$i5_column]][row])
})

test_that("resolve_index errors on an unknown name", {
  tbl <- load_index_table(proj_file(CONFIG$index_table))
  expect_error(resolve_index(tbl, "UDP9999"), "Unknown index name")
})

test_that("resolve_index rejects non-scalar or empty input", {
  tbl <- load_index_table(proj_file(CONFIG$index_table))
  expect_error(resolve_index(tbl, c("UDP0001", "UDP0002")), "single non-empty")
  expect_error(resolve_index(tbl, ""),   "single non-empty")
  expect_error(resolve_index(tbl, NA_character_), "single non-empty")
})

test_that("available_indexes excludes used names, preserves order", {
  tbl <- load_index_table(proj_file(CONFIG$index_table))
  
  avail <- available_indexes(tbl, used = c("UDP0002", "UDP0001"))
  expect_false(any(c("UDP0001", "UDP0002") %in% avail))
  expect_equal(length(avail), nrow(tbl) - 2L)
  
  # order follows the table, not the 'used' vector
  expect_equal(avail, setdiff(tbl$index_name, c("UDP0002", "UDP0001")))
})

test_that("available_indexes with no used names returns all", {
  tbl <- load_index_table(proj_file(CONFIG$index_table))
  expect_equal(available_indexes(tbl), tbl$index_name)
})

test_that("available_indexes ignores unknown used names", {
  tbl <- load_index_table(proj_file(CONFIG$index_table))
  avail <- available_indexes(tbl, used = c("UDP0001", "NOT_A_REAL_INDEX"))
  expect_equal(length(avail), nrow(tbl) - 1L)
})