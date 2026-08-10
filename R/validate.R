# ---------------------------------------------------------------------------
# Validation. Two tiers (D-005):
#   hard  -- Illumina rules; a violation fails at BCL Convert anyway -> block
#   soft  -- Pathology Sample_ID pattern; inferred, not confirmed    -> warn
# Phase 2 -- NOT YET IMPLEMENTED.
# ---------------------------------------------------------------------------

#' Check a single Sample_ID against Illumina's rules.
#'
#' Rules: 1-70 characters; alphanumeric plus "-" and "_"; an alphanumeric
#' character on both sides of every separator; not a reserved word.
#'
#' @return character(0) if valid, otherwise a vector of messages.
validate_sample_id <- function(id, cfg = CONFIG) {
  stop("not implemented -- Phase 2")
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
