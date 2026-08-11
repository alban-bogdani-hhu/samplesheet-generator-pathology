# ---------------------------------------------------------------------------
# Shiny UI.
# ---------------------------------------------------------------------------

app_ui <- function() {
  bslib::page_sidebar(
    title = "SampleSheet Generator - WES (Pathologie)",
    
    sidebar = bslib::sidebar(
      width = 430,
      shiny::textInput("run_name", "RunName (optional)",
                       placeholder = "z. B. 20260729_LH..."),
      shiny::hr(),
      shiny::textInput("sample_id", "Sample_ID",
                       placeholder = "z. B. 1234-26_3-N"),
      shiny::selectInput("index_name", "Index", choices = NULL),
      shiny::actionButton("add", "Probe hinzufügen",
                          class = "btn-primary", width = "100%"),
      shiny::hr(),
      shiny::helpText(
        shiny::textOutput("count_text", inline = TRUE))
    ),
    
    bslib::card(
      bslib::card_header("Proben im aktuellen Lauf"),
      DT::DTOutput("samples"),
      shiny::actionButton("remove_selected", "Ausgewählte Zeile entfernen",
                          class = "btn-outline-danger btn-sm")
    ),
    
    bslib::card(
      bslib::card_header("Prüfung"),
      shiny::uiOutput("validation_msgs")
    )
  )
}