# ---------------------------------------------------------------------------
# Validation. Two tiers (D-005):
#   hard  -- Illumina rules; a violation fails at BCL Convert anyway -> block
#   soft  -- Pathology Sample_ID pattern; inferred, not confirmed    -> warn
# Phase 2 --IMPLEMENTED.
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

#' Soft check against the Pathology naming pattern (warning tier, D-005).
#'
#' The pattern (cfg$id_pattern) is inferred from one run, not confirmed by Kai
#' (open item O-001), so a mismatch is a WARNING, not a block: a legitimate
#' control or unusual sample must still be addable. When cfg$id_pattern_mode is
#' "off", this returns nothing.
#'
#' Promotion to a hard block is a one-line config change (id_pattern_mode ->
#' "block"), handled by the caller (validate_run), not here -- this function
#' only reports whether the pattern matches.
#'
#' @param id  A single Sample_ID string.
#' @param cfg Config list (id_pattern, id_pattern_mode).
#' @return character(0) if it matches or checking is off; else one message.
check_id_pattern <- function(id, cfg = CONFIG) {
  if (identical(cfg$id_pattern_mode, "off")) {
    return(character(0))
  }
  if (length(id) != 1L || is.na(id) || !nzchar(id)) {
    # Empties are validate_sample_id's job; nothing to say about the pattern.
    return(character(0))
  }
  if (grepl(cfg$id_pattern, id)) {
    return(character(0))
  }
  sprintf("Sample_ID '%s' does not match the expected Pathology pattern.", id)
}

#' Run-level validation across all samples (D-005).
#'
#' Per-ID checks (validate_sample_id, check_id_pattern) run for every row, then
#' cross-row checks that only make sense for the pool as a whole:
#'   - duplicate Sample_ID           (BCL Convert requires unique IDs)  -> error
#'   - duplicate (i7, i5) index pair (a read can't be assigned)         -> error
#'   - index length != template cycles (demux misreads the barcode)     -> error
#'
#' Index length is derived from the template's Index1Cycles / Index2Cycles, so
#' there is one source of truth -- a WES/WGS template with different cycles
#' needs no code change here.
#'
#' @param samples data.frame(sample_id, index_name, i7, i5, sample_project).
#' @param cfg     Config list.
#' @return list(errors = <chr>, warnings = <chr>). errors block; warnings don't.
validate_run <- function(samples, cfg = CONFIG) {
  errors   <- character(0)
  warnings <- character(0)
  
  if (nrow(samples) == 0L) {
    return(list(errors = "No samples to validate.", warnings = character(0)))
  }
  
  # --- per-ID checks, aggregated over rows ---------------------------------
  for (i in seq_len(nrow(samples))) {
    id <- samples$sample_id[i]
    id_errs  <- validate_sample_id(id, cfg)
    if (length(id_errs)) {
      errors <- c(errors, sprintf("Row %d (%s): %s", i, id, id_errs))
    }
    id_warns <- check_id_pattern(id, cfg)
    if (length(id_warns)) {
      warnings <- c(warnings, sprintf("Row %d: %s", i, id_warns))
    }
  }
  
  # --- duplicate Sample_ID -------------------------------------------------
  dup_ids <- unique(samples$sample_id[duplicated(samples$sample_id)])
  if (length(dup_ids)) {
    errors <- c(errors, sprintf(
      "Duplicate Sample_ID: %s", paste(dup_ids, collapse = ", ")))
  }
  
  # --- duplicate index pair ------------------------------------------------
  pairs <- paste(samples$i7, samples$i5, sep = "+")
  dup_pairs <- unique(pairs[duplicated(pairs)])
  if (length(dup_pairs)) {
    # report by the sample IDs sharing each pair, which is what a user can act on
    for (p in dup_pairs) {
      who <- samples$sample_id[pairs == p]
      errors <- c(errors, sprintf(
        "Duplicate index pair used by: %s", paste(who, collapse = ", ")))
    }
  }
  
  # --- index length vs. template cycles ------------------------------------
  cycles <- template_index_cycles(cfg)   # c(i7 = <n>, i5 = <n>)
  bad_i7 <- which(nchar(samples$i7) != cycles[["i7"]])
  bad_i5 <- which(nchar(samples$i5) != cycles[["i5"]])
  if (length(bad_i7)) {
    errors <- c(errors, sprintf(
      "i7 length != Index1Cycles (%d) for: %s",
      cycles[["i7"]], paste(samples$sample_id[bad_i7], collapse = ", ")))
  }
  if (length(bad_i5)) {
    errors <- c(errors, sprintf(
      "i5 length != Index2Cycles (%d) for: %s",
      cycles[["i5"]], paste(samples$sample_id[bad_i5], collapse = ", ")))
  }
  
  list(errors = errors, warnings = warnings)
}

#' Read Index1Cycles / Index2Cycles from the template (single source of truth).
#'
#' @return named integer vector c(i7 = <n>, i5 = <n>).
template_index_cycles <- function(cfg = CONFIG) {
  raw   <- readChar(cfg$template, file.size(cfg$template), useBytes = TRUE)
  lines <- strsplit(raw, "\r\n", fixed = TRUE)[[1]]
  
  pick <- function(key) {
    hit <- grep(paste0("^", key, ","), lines, value = TRUE)
    if (length(hit) != 1L) {
      stop("Template does not contain a single '", key, "' line.", call. = FALSE)
    }
    as.integer(sub(paste0("^", key, ","), "", hit))
  }
  
  c(i7 = pick("Index1Cycles"), i5 = pick("Index2Cycles"))
}
