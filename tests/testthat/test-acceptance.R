# Acceptance test (F-10): reproduce Kai's real (anonymized) sample sheet
# byte-for-byte from its sample IDs and index names. This is the test that
# proves the whole Phase 1 chain -- resolve -> build -> write -- is correct.
#
# The 12 Sample_ID -> UDP mappings were recovered from the reference sheet's
# index sequences (see tests/testthat/fixtures/README.md).

test_that("the generator reproduces the reference sheet byte-for-byte", {
  ref_path <- testthat::test_path("fixtures", "reference-samplesheet.csv")
  ref_raw  <- readChar(ref_path, file.size(ref_path), useBytes = TRUE)
  
  # Run name recovered from the reference file's [Header].
  run_name <- "20260101_LH00000_0000_B000000LT1"
  
  # The exact samples and their assigned indexes, in the reference's row order.
  assignments <- data.frame(
    sample_id  = c("0000-26_3-N", "0001-26_3-N", "0002-26_3-N",
                   "0003-26_3-N", "0004-26_3-N", "0005-26_3-N",
                   "0000-26_1-T", "0001-26_1-T", "0002-26_1-T",
                   "0003-26_1-T", "0006-26_1-T", "0007-26_1-T"),
    index_name = c("UDP0002", "UDP0003", "UDP0004",
                   "UDP0074", "UDP0088", "UDP0005",
                   "UDP0001", "UDP0009", "UDP0010",
                   "UDP0080", "UDP0094", "UDP0016"),
    stringsAsFactors = FALSE
  )
  
  # Resolve each index name to its i7/i5 via the frozen table (forward i5).
  tbl <- load_index_table(testthat::test_path("..", "..", CONFIG$index_table))
  seqs <- lapply(assignments$index_name, function(n) resolve_index(tbl, n))
  
  samples <- data.frame(
    sample_id      = assignments$sample_id,
    i7             = vapply(seqs, `[[`, character(1), "i7"),
    i5             = vapply(seqs, `[[`, character(1), "i5"),
    sample_project = "WES_Patho",
    stringsAsFactors = FALSE
  )
  
  lines <- build_samplesheet(samples, run_name, test_cfg())
  
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp))
  write_samplesheet(lines, tmp, CONFIG)
  
  out_raw <- readChar(tmp, file.size(tmp), useBytes = TRUE)
  
  expect_identical(out_raw, ref_raw)
})