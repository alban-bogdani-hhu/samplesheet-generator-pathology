# ---------------------------------------------------------------------------
# Validation. Two tiers (D-005):
#   hard  -- Illumina rules; a violation fails at BCL Convert anyway -> block
#   soft  -- Pathology Sample_ID pattern; inferred, not confirmed    -> warn
# Phase 2 -- NOT YET IMPLEMENTED.
# ---------------------------------------------------------------------------

#' Check a single Sample_ID against Illumina's hard rules (blocking tier, D-005).
#'
#' These are objective BCL Convert / DRAGEN requirements; a violation makes the
#' run fail, so they block. This function deliberately does NOT enforce the
#' Pathology naming convention -- that is the soft tier (check_id_pattern), so a
#' legitimate but unusually-named sample (e.g. a control) is not rejected here.
#'
#' Rules: 1-70 characters; only alphanumeric, "-" and "_"; an alphanumeric
#' character on both sides of every separator (no leading/trailing/adjacent
#' separators); not a reserved word.
#'
#' @param id  A single Sample_ID string.
#' @param cfg Config list (id_max_nchar, id_reserved).
#' @return character(0) if valid; otherwise a character vector of problems.
validate_sample_id <- function(id, cfg = CONFIG) {
  if (length(id) != 1L || is.na(id)) {
    return("Sample_ID must be a single non-missing value.")
  }
  
  problems <- character(0)
  
  if (!nzchar(id)) {
    return("Sample_ID is empty.")
  }
  if (nchar(id) > cfg$id_max_nchar) {
    problems <- c(problems, sprintf(
      "Sample_ID is longer than %d characters.", cfg$id_max_nchar))
  }
  if (grepl("[^A-Za-z0-9_-]", id)) {
    problems <- c(problems,
                  "Sample_ID may only contain letters, digits, '-' and '_'.")
  }
  # An alphanumeric on both sides of every separator: no leading/trailing
  # separator, and no two separators adjacent.
  if (grepl("^[_-]|[_-]$|[_-]{2,}", id)) {
    problems <- c(problems,
                  "Sample_ID must have an alphanumeric character on both sides of every '-' or '_'.")
  }
  if (tolower(id) %in% cfg$id_reserved) {
    problems <- c(problems, sprintf(
      "Sample_ID '%s' is a reserved word.", id))
  }
  
  problems
}

#' Soft check against the Pathology naming pattern.
#'
#' @return character(0) or a single warning message.
check_id_pattern <- function(id, cfg = CONFIG) {
  stop("not implemented -- Phase 2")
}

#' Run-level checks across all rows.
#'
#' Duplicate Sample_ID, duplicate index pair, index length vs. Index1Cycles /
#' Index2Cycles from the template.
#'
#' @return list(errors = <chr>, warnings = <chr>)
validate_run <- function(samples, cfg = CONFIG) {
  stop("not implemented -- Phase 2")
}
