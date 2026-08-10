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

#' Build the complete sample sheet as a character vector of lines.
#'
#' Renders the fixed template sections (via render_template) and appends one
#' data row per sample. Row order follows the input order of `samples` -- the
#' caller (UI) controls it, and the byte-for-byte test depends on it.
#'
#' Column order is fixed by the template's data header:
#'   Sample_ID, index (=i7), index2 (=i5), Sample_Project
#'
#' @param samples data.frame with columns sample_id, i7, i5, sample_project.
#' @param run_name Character scalar, or NULL/NA/"" for the empty case (D-002).
#' @param cfg      Config list.
#' @return Character vector of all sheet lines (no trailing empty element).
build_samplesheet <- function(samples, run_name = NULL, cfg = CONFIG) {
  required <- c("sample_id", "i7", "i5", "sample_project")
  missing  <- setdiff(required, names(samples))
  if (length(missing)) {
    stop("samples is missing column(s): ", paste(missing, collapse = ", "),
         call. = FALSE)
  }
  if (nrow(samples) == 0L) {
    stop("Cannot build a sample sheet with zero samples.", call. = FALSE)
  }
  
  header <- render_template(run_name, cfg)
  
  data_rows <- paste(
    samples$sample_id,
    samples$i7,
    samples$i5,
    samples$sample_project,
    sep = ","
  )
  
  c(header, data_rows)
}

#' Write sheet lines to disk with CRLF endings and no trailing blank line.
#'
#' CRLF TRAP (see file header): R's text connections translate line endings, so
#' writeLines() on a default connection yields platform-dependent bytes. We open
#' a BINARY connection and write explicit cfg$line_ending ("\r\n") ourselves, so
#' the output is identical on Windows and Linux. The file ends with exactly one
#' line terminator after the last row -- matching Illumina's format and the
#' reference sheet (no extra blank line).
#'
#' @param lines Character vector of sheet lines (from build_samplesheet).
#' @param path  Output file path.
#' @param cfg   Config list.
#' @return `path`, invisibly.
write_samplesheet <- function(lines, path, cfg = CONFIG) {
  # One terminator after every line, including the last; no trailing blank line.
  payload <- paste0(paste(lines, collapse = cfg$line_ending), cfg$line_ending)
  
  con <- file(path, open = "wb")            # binary: no line-ending translation
  on.exit(close(con), add = TRUE)
  writeBin(charToRaw(payload), con)
  
  invisible(path)
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
