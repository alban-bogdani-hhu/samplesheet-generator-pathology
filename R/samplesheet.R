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
#' @return character vector of lines, up to and including the
#'   "Sample_ID,index,index2,Sample_Project" header row.
render_template <- function(run_name = NULL, cfg = CONFIG) {
  stop("not implemented -- Phase 1")
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

#' Export filename for a run (D-004). Sanitizes for Windows.
samplesheet_filename <- function(run_name = NULL, cfg = CONFIG) {
  stop("not implemented -- Phase 1")
}
