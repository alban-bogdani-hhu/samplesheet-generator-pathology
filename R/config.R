# ---------------------------------------------------------------------------
# Central configuration.
#
# Every setting here corresponds to a decision in docs/DECISIONS.md that we have
# concrete evidence may change. Settings that nobody has a reason to change are
# deliberately NOT here -- see design principle 3 in PROJECT_PLAN.md.
#
# The "D-nnn" tags link back to the decision log.
# ---------------------------------------------------------------------------

CONFIG <- list(

  ## --- Assay / template -----------------------------------------------------
  # D-006: fixed sheet sections live in a template file so a WGS variant is a
  # drop-in rather than a refactor.
  template          = "templates/wes.csv",
  runname_token     = "{{RUNNAME}}",

  ## --- Index table ----------------------------------------------------------
  # D-011: frozen vendor table, regenerated only by data-raw/freeze_index_table.R
  index_table       = "data/udp_indexes.csv",

  # D-003: NovaSeq X Plus + v2 sheet -> i5 in FORWARD orientation.
  # Changing this to "i5_reverse_complement" is how you would support an
  # instrument with the reverse-complement workflow (NextSeq 500/550, etc.).
  i7_column         = "i7_sample_sheet",
  i5_column         = "i5_forward",

  # D-010: hide indexes already assigned in the current run.
  exclude_used_indexes = TRUE,

  ## --- RunName / output -----------------------------------------------------
  # D-002: Kai asked for the line to stay with a literal NA behind it.
  # NOTE: this is the CHARACTER STRING "NA", never R's logical NA.
  empty_runname_value = "NA",

  # D-004: matches the convention of the sheets Pathology produces today.
  filename_pattern    = "%s-samplesheet.csv",

  # Windows-safe filename characters; anything else is stripped.
  filename_safe_chars = "[^A-Za-z0-9._-]",

  ## --- Validation -----------------------------------------------------------
  # D-005: "warn" flags non-conforming IDs but still allows them.
  # Switch to "block" once the Sample_ID conventions are confirmed (O-001).
  id_pattern_mode   = "warn",
  id_pattern        = "^[0-9]{3,4}-[0-9]{2}_[0-9]+-[NT]$",

  # Illumina hard rules (BCL Convert / DRAGEN). These are objective and are
  # always enforced -- they are listed rather than hidden so the rule set is
  # readable in one place.
  id_max_nchar      = 70L,
  id_reserved       = c("all", "default", "none", "unknown",
                        "undetermined", "stats", "reports"),

  ## --- Output format --------------------------------------------------------
  # Illumina sample sheets are CRLF. R translates line endings on text
  # connections, so the writer uses a binary connection -- see R/samplesheet.R.
  line_ending       = "\r\n",
  file_encoding     = "UTF-8"
)
