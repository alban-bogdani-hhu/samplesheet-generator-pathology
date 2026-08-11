# ---------------------------------------------------------------------------
# Shiny UI.
# ---------------------------------------------------------------------------

app_ui <- function() {
  bslib::page_sidebar(
    title = "SampleSheet Generator - WES (Pathologie)",
    shinyjs::useShinyjs(),
    
    sidebar = bslib::sidebar(
      width = 430,
      shiny::textInput("run_name", "RunName (optional)",
                       placeholder = "z. B. 20260729_LH..."),
      shiny::hr(),
      shiny::textInput("sample_id", "Sample_ID",
                       placeholder = "z. B. 1234-26_3-N"),
      shiny::selectizeInput("index_name", "Index", choices = NULL,
                            options = list(placeholder = "tippen zum Suchen...")),
      shiny::actionButton("add", "Probe hinzufügen",
                          class = "btn-primary", width = "100%"),
      shiny::hr(),
      # Rendered disabled on load so the empty-start state can't open the
      # download dialog; the server's toggleState observer takes over after.
      shinyjs::disabled(
        shiny::downloadButton("export", "SampleSheet exportieren",
                              class = "btn-success", style = "width:100%;")
      ),
      shiny::uiOutput("export_hint"),
      
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