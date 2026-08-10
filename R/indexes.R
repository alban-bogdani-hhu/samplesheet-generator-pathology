# ---------------------------------------------------------------------------
# Index table: load the frozen IDT UD index table and resolve index names.
# Phase 1 -- NOT YET IMPLEMENTED.
# ---------------------------------------------------------------------------

#' Load the frozen index table.
#'
#' @param path Path to data/udp_indexes.csv (commented header lines start with #).
#' @return data.frame with columns index_name, i7_sample_sheet, i5_forward, ...
load_index_table <- function(path = CONFIG$index_table) {
  stop("not implemented -- Phase 1")
}

#' Index names available for assignment.
#'
#' @param tbl   Index table from load_index_table().
#' @param used  Character vector of index names already assigned in this run.
#' @return Character vector of selectable index names (D-010).
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
