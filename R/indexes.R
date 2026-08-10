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

#' Index names available for assignment in the current run.
#'
#' Returns index names not yet used, preserving table order (UDP0001, UDP0002,
#' ...), so the dropdown reads predictably. Implements D-010: excluding used
#' indexes at the UI makes a duplicate index pair unrepresentable rather than
#' merely caught at validation.
#'
#' Toggled by CONFIG$exclude_used_indexes; when FALSE, all names are returned
#' (the validator remains the backstop against duplicates).
#'
#' @param tbl   Index table from load_index_table().
#' @param used  Character vector of index names already assigned this run.
#' @return Character vector of selectable index names, in table order.
available_indexes <- function(tbl, used = character(0)) {
  all_names <- tbl$index_name
  if (!isTRUE(CONFIG$exclude_used_indexes)) {
    return(all_names)
  }
  setdiff(all_names, used)
}

#' Resolve one index name to its sample-sheet sequences.
#'
#' Looks the name up and returns the i7/i5 for the configured columns
#' (CONFIG$i7_column, CONFIG$i5_column -- forward i5 for NovaSeq X Plus, D-003).
#' An unknown name is a hard error, never a silent empty result: a blank index
#' would send that sample's reads to Undetermined.
#'
#' @param tbl        Index table from load_index_table().
#' @param index_name A single index name (e.g. "UDP0007").
#' @return list(i7 = <chr>, i5 = <chr>).
resolve_index <- function(tbl, index_name) {
  if (length(index_name) != 1L || is.na(index_name) || !nzchar(index_name)) {
    stop("resolve_index() needs a single non-empty index name.", call. = FALSE)
  }
  
  row <- match(index_name, tbl$index_name)
  if (is.na(row)) {
    stop("Unknown index name: ", index_name,
         "\nNot found in the index table.", call. = FALSE)
  }
  
  list(
    i7 = tbl[[CONFIG$i7_column]][row],
    i5 = tbl[[CONFIG$i5_column]][row]
  )
}
