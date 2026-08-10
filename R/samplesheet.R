# ---------------------------------------------------------------------------
# Sheet assembly and writing.
# Phase 1 -- NOT YET IMPLEMENTED.
#
# CRLF WARNING: R translates line endings on text connections. Writing with
# writeLines() on a default connection produces the wrong bytes on at least one
# platform. Use a binary connection and explicit CONFIG$line_ending.
#
# NA WARNING: CONFIG$empty_runname_value is the STRING "NA", never R's logical
# NA. Do not let it pass through anything that treats NA as missing.
# ---------------------------------------------------------------------------

#' Render the fixed sections from the template, substituting RunName.
#'
#' Reads templates/wes.csv and replaces the {{RUNNAME}} placeholder. An empty
#' or missing run name is written as the literal string configured in
#' CONFIG$empty_runname_value -- "NA" per Kai's request (D-002).
#'
#' IMPORTANT (D-002): that value is the character string "NA", never R's logical
#' NA. This function guards against R's NA reaching the output: is.na() catches
#' it and it is replaced by the configured string, so the header can never
#' silently become "RunName," with an empty field.
#'
#' @param run_name Character scalar, or NULL/NA/"" for the empty case.
#' @param cfg      Config list.
#' @return Character vector of template lines, {{RUNNAME}} substituted.
render_template <- function(run_name = NULL, cfg = CONFIG) {
  path <- cfg$template
  if (!file.exists(path)) {
    stop("Sheet template not found at: ", path, call. = FALSE)
  }
  
  # Read raw so we control line handling ourselves (see write_samplesheet).
  raw   <- readChar(path, file.size(path), useBytes = TRUE)
  lines <- strsplit(raw, "\r\n", fixed = TRUE)[[1]]
  
  # Normalise the run name to a single character value.
  # NULL, NA (logical or character), or "" all become the configured literal.
  if (is.null(run_name) || length(run_name) == 0L ||
      is.na(run_name) || !nzchar(run_name)) {
    run_name <- cfg$empty_runname_value
  } else if (length(run_name) != 1L) {
    stop("run_name must be a single value.", call. = FALSE)
  }
  
  gsub(cfg$runname_token, run_name, lines, fixed = TRUE)
}

#' Build the complete sheet as a character vector of lines.
#'
#' @param samples data.frame(sample_id, index_name, i7, i5, sample_project)
build_samplesheet <- function(samples, run_name = NULL, cfg = CONFIG) {
  stop("not implemented -- Phase 1")
}

#' Write lines to disk with CRLF endings and no trailing blank line.
write_samplesheet <- function(lines, path, cfg = CONFIG) {
  stop("not implemented -- Phase 1")
}

#' Export filename for a run (D-004).
#'
#' Builds "<RunName>-samplesheet.csv", matching Pathology's existing convention
#' (lowercase, hyphen). The run name is sanitised to Windows-safe characters,
#' since it is free text and may contain characters illegal in filenames.
#'
#' Empty/NULL/NA run name -> the configured empty value ("NA", D-002), giving
#' "NA-samplesheet.csv": deliberately visible as unfinished, since a human must
#' still fill the run name in.
#'
#' @param run_name Character scalar, or NULL/NA/"" for the empty case.
#' @param cfg      Config list.
#' @return A single filename string.
samplesheet_filename <- function(run_name = NULL, cfg = CONFIG) {
  if (is.null(run_name) || length(run_name) == 0L ||
      is.na(run_name) || !nzchar(run_name)) {
    run_name <- cfg$empty_runname_value
  } else if (length(run_name) != 1L) {
    stop("run_name must be a single value.", call. = FALSE)
  }
  
  safe <- gsub(cfg$filename_safe_chars, "", run_name)
  if (!nzchar(safe)) {
    # Run name was all illegal characters -> fall back to the empty literal.
    safe <- cfg$empty_runname_value
  }
  
  sprintf(cfg$filename_pattern, safe)
}
