# ---------------------------------------------------------------------------
# Index table: load the frozen IDT UD index table and resolve index names.
# ---------------------------------------------------------------------------

#' Load the frozen index table.
#'
#' Reads data/udp_indexes.csv, skipping the provenance header (lines starting
#' with "#"). Validates STRUCTURE against config -- not vendor-specific values,
#' so a future table with more rows or a different index set still passes as
#' long as it carries the configured columns (see DECISIONS.md, reversibility).
#'
#' Deep vendor-file validation (orientation math, pair uniqueness) lives in
#' data-raw/freeze_index_table.R, which runs when the CSV is created. Index
#' LENGTH is checked later against the template's cycle count, not here.
#'
#' @param path Path to the frozen index CSV.
#' @return data.frame with at least index_name + the configured i7/i5 columns.
load_index_table <- function(path = CONFIG$index_table) {
  if (!file.exists(path)) {
    stop("Index table not found at: ", path,
         "\nExpected the frozen table produced by data-raw/freeze_index_table.R.",
         call. = FALSE)
  }

  tbl <- utils::read.csv(
    path, comment.char = "#", stringsAsFactors = FALSE,
    colClasses = "character"
  )

  required <- c("index_name", CONFIG$i7_column, CONFIG$i5_column)
  missing  <- setdiff(required, names(tbl))
  if (length(missing)) {
    stop("Index table is missing required column(s): ",
         paste(missing, collapse = ", "),
         "\nFound: ", paste(names(tbl), collapse = ", "),
         call. = FALSE)
  }

  if (nrow(tbl) == 0L) {
    stop("Index table has no rows: ", path, call. = FALSE)
  }

  if (anyDuplicated(tbl$index_name)) {
    dupes <- unique(tbl$index_name[duplicated(tbl$index_name)])
    stop("Index table has duplicate index names: ",
         paste(dupes, collapse = ", "), call. = FALSE)
  }

  tbl
}

available_indexes <- function(tbl, used = character(0)) {
  stop("not implemented -- Phase 1")
}

#' Resolve one index name to its sample-sheet sequences.
#'
#' @return list(i7 = <chr>, i5 = <chr>). Errors if the name is unknown --
#'   an unknown index must never pass silently.
resolve_index <- function(tbl, index_name) {
  stop("not implemented -- Phase 1")
}
