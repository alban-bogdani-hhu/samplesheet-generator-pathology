# ---------------------------------------------------------------------------
# Shiny UI. Phase 3 -- placeholder only.
# ---------------------------------------------------------------------------

app_ui <- function() {
  bslib::page_sidebar(
    title = "SampleSheet Generator - WES (Pathologie)",
    sidebar = bslib::sidebar(
      width = 320,
      shiny::helpText("Skeleton - UI folgt in Phase 3."),
      shiny::textInput("run_name", "RunName (optional)", placeholder = "z. B. 20260729_LH...")
    ),
    bslib::card(
      bslib::card_header("Proben"),
      DT::DTOutput("samples")
    ),
    bslib::card(
      bslib::card_header("Status"),
      shiny::verbatimTextOutput("status")
    )
  )
}
