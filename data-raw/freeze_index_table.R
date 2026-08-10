# ---------------------------------------------------------------------------
# Provenance script for data/udp_indexes.csv  (D-011)
#
# Converts the IDT for Illumina UD Index workbook into the frozen CSV the app
# reads at runtime. Run this ONLY when the vendor file changes -- the output is
# committed, so day-to-day use never touches Excel and `openxlsx` stays out of
# the runtime dependency set.
#
# Usage (from the project root):
#   Rscript data-raw/freeze_index_table.R data-raw/IDT_for_Illumina_UD_Indexes.xlsx
#
# STATUS: ported from the Python version that produced the committed CSV.
#         Not yet executed in R -- verify the output matches data/udp_indexes.csv
#         before replacing it (see INSTALL.md).
# ---------------------------------------------------------------------------

args     <- commandArgs(trailingOnly = TRUE)
xlsx     <- if (length(args) >= 1) args[1] else stop("Usage: freeze_index_table.R <workbook.xlsx>")
out_path <- if (length(args) >= 2) args[2] else "data/udp_indexes.csv"

if (!requireNamespace("openxlsx", quietly = TRUE)) {
  stop("openxlsx is required for this one-off script (not a runtime dependency).")
}

COL <- c(
  name       = "Index Name",
  i7_adapter = "i7 Bases in Adapter",
  i7_ss      = "i7 Bases for Sample Sheet",
  i5_adapter = "i5 Bases in Adapter",
  i5_fwd     = "i5 Bases for Sample Sheet in Forward Orientation",
  i5_rc      = "i5 Bases for Sample Sheet in Reverse Complement Orientation"
)

revcomp <- function(x) {
  vapply(x, function(s) {
    chars <- rev(strsplit(s, "", fixed = TRUE)[[1]])
    paste(chartr("ACGT", "TGCA", chars), collapse = "")
  }, character(1), USE.NAMES = FALSE)
}

# --- read, finding the header row by content, not by position ---------------
sheets <- openxlsx::getSheetNames(xlsx)
if (length(sheets) != 1) {
  message("Workbook has several sheets: ", paste(sheets, collapse = ", "),
          " -- using the first.")
}
raw <- openxlsx::read.xlsx(xlsx, sheet = 1, colNames = FALSE)

hdr <- which(apply(raw, 1, function(r) identical(as.character(r[1]), COL[["name"]])))
if (length(hdr) != 1) stop("Could not locate the header row containing '", COL[["name"]], "'.")

header <- trimws(as.character(unlist(raw[hdr, ])))
missing <- setdiff(unname(COL), header)
if (length(missing)) {
  stop("Workbook is missing expected column(s): ", paste(missing, collapse = ", "))
}

body <- raw[(hdr + 1):nrow(raw), , drop = FALSE]
body <- body[!is.na(body[[1]]) & nzchar(trimws(as.character(body[[1]]))), , drop = FALSE]

pick <- function(key) trimws(as.character(body[[which(header == COL[[key]])]]))

tbl <- data.frame(
  index_name             = pick("name"),
  i7_adapter             = toupper(pick("i7_adapter")),
  i7_sample_sheet        = toupper(pick("i7_ss")),
  i5_adapter             = toupper(pick("i5_adapter")),
  i5_forward             = toupper(pick("i5_fwd")),
  i5_reverse_complement  = toupper(pick("i5_rc")),
  stringsAsFactors = FALSE
)

# --- validate every assumption the app relies on ----------------------------
stopifnot(
  "duplicate index names"       = anyDuplicated(tbl$index_name) == 0L,
  "non-ACGT characters"         = all(grepl("^[ACGT]+$", unlist(tbl[-1]))),
  "inconsistent index lengths"  = length(unique(nchar(unlist(tbl[-1])))) == 1L,
  "i7 sample sheet != revcomp(i7 adapter)" =
    all(tbl$i7_sample_sheet == revcomp(tbl$i7_adapter)),
  "i5 forward != i5 adapter" =
    all(tbl$i5_forward == tbl$i5_adapter),
  "i5 revcomp != revcomp(i5 forward)" =
    all(tbl$i5_reverse_complement == revcomp(tbl$i5_forward)),
  "duplicate (i7, i5) pairs" =
    anyDuplicated(paste(tbl$i7_sample_sheet, tbl$i5_forward)) == 0L
)

# --- write with provenance header -------------------------------------------
src_hash <- if (requireNamespace("tools", quietly = TRUE)) {
  tryCatch(unname(tools::md5sum(xlsx)), error = function(e) "unavailable")
} else "unavailable"

con <- file(out_path, open = "wb")
on.exit(close(con))
hdr_lines <- c(
  "# IDT for Illumina UD Indexes -- frozen lookup table",
  paste0("# source_file: ", basename(xlsx)),
  paste0("# source_md5: ", src_hash),
  paste0("# n_indexes: ", nrow(tbl)),
  paste0("# frozen_on: ", format(Sys.Date())),
  "# NOTE: for NovaSeq X Plus with a v2 sample sheet, use i7_sample_sheet",
  "#       and i5_forward. DRAGEN/BCL Convert reverse-complements i5 itself."
)
writeBin(charToRaw(paste0(paste(hdr_lines, collapse = "\n"), "\n")), con)
writeBin(charToRaw(paste0(paste(names(tbl), collapse = ","), "\n")), con)
writeBin(charToRaw(paste0(
  paste(apply(tbl, 1, paste, collapse = ","), collapse = "\n"), "\n")), con)

message("Wrote ", out_path, " -- ", nrow(tbl), " indexes, all checks passed.")
