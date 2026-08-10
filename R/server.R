# ---------------------------------------------------------------------------
# Shiny server. Phase 3 -- placeholder only.
#
# State is in-memory for the session (D-001): nothing is written to disk except
# the exported sample sheet.
# ---------------------------------------------------------------------------

app_server <- function(input, output, session) {

  # Placeholder: proves shiny + bslib + DT all load on the target machine.
  output$samples <- DT::renderDT(
    data.frame(
      Sample_ID    = character(0),
      Index        = character(0),
      i7           = character(0),
      i5           = character(0),
      stringsAsFactors = FALSE
    ),
    options = list(dom = "t"), rownames = FALSE
  )

  output$status <- shiny::renderText({
    paste0(
      "Skeleton v0.0.1 - noch keine Funktionalitaet.\n",
      "R ", getRversion(), " | shiny ", utils::packageVersion("shiny"),
      " | bslib ", utils::packageVersion("bslib"),
      " | DT ", utils::packageVersion("DT")
    )
  })
}
