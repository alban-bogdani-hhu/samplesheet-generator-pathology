# ---------------------------------------------------------------------------
# Shiny server.
#
# State is in-memory for the session only (D-001): the sample list lives in a
# reactiveVal and nothing is written to disk except the exported sheet.
#
# Each sample is stored RESOLVED -- sample_id, index_name, i7, i5,
# sample_project -- exactly the shape build_samplesheet() and validate_run()
# expect. Index sequences are resolved once, at Add.
# ---------------------------------------------------------------------------

SAMPLE_PROJECT <- "WES_Patho"   # constant per Kai; becomes config if that changes

app_server <- function(input, output, session) {
  
  index_tbl <- load_index_table()
  
  # The current run's samples. Empty frame with the exact target columns.
  samples <- shiny::reactiveVal(
    data.frame(
      sample_id      = character(0),
      index_name     = character(0),
      i7             = character(0),
      i5             = character(0),
      sample_project = character(0),
      stringsAsFactors = FALSE
    )
  )
  
  # Names already used this run -> excluded from the dropdown (D-010).
  used_names <- shiny::reactive(samples()$index_name)
  
  # Keep the dropdown in sync with available indexes (D-010), searchable.
  # Label carries UDP + both sequences, so typing any of them filters.
  # Value stays the bare UDP name -> resolve_index() unaffected.
  shiny::observe({
    avail <- available_indexes(index_tbl, used_names())
    rows  <- match(avail, index_tbl$index_name)
    
    labels <- sprintf(
      "%s  ·  i7: %s  ·  i5: %s",
      avail,
      index_tbl[[CONFIG$i7_column]][rows],
      index_tbl[[CONFIG$i5_column]][rows]
    )
    choices <- stats::setNames(avail, labels)   # names = shown, values = UDP
    
    shiny::updateSelectizeInput(
      session, "index_name",
      choices  = choices,
      selected = character(0),   # don't auto-pick; force a deliberate choice
      server   = TRUE
    )
  })
  
  # --- Add ------------------------------------------------------------------
  shiny::observeEvent(input$add, {
    id <- trimws(input$sample_id)
    nm <- input$index_name
    
    # Minimal guards here; full validation is live below and gated at export.
    # Just prevent obviously broken adds (empty id, no index selected).
    if (!nzchar(id)) {
      shiny::showNotification("Bitte eine Sample_ID eingeben.", type = "warning")
      return()
    }
    if (is.null(nm) || !nzchar(nm)) {
      shiny::showNotification("Kein Index verfügbar/ausgewählt.", type = "warning")
      return()
    }
    
    seq <- resolve_index(index_tbl, nm)
    
    new_row <- data.frame(
      sample_id      = id,
      index_name     = nm,
      i7             = seq$i7,
      i5             = seq$i5,
      sample_project = SAMPLE_PROJECT,
      stringsAsFactors = FALSE
    )
    samples(rbind(samples(), new_row))
    
    # clear the id field for the next entry; index dropdown updates itself
    shiny::updateTextInput(session, "sample_id", value = "")
  })
  
  # --- Remove selected ------------------------------------------------------
  shiny::observeEvent(input$remove_selected, {
    sel <- input$samples_rows_selected
    if (length(sel)) {
      samples(samples()[-sel, , drop = FALSE])
    }
  })
  
  # --- Live validation ------------------------------------------------------
  # Re-runs whenever the pool changes. Single source of truth for both the
  # messages below and the export gate, so they can never disagree.
  validation <- shiny::reactive({
    df <- samples()
    if (nrow(df) == 0L) {
      return(list(errors = character(0), warnings = character(0)))
    }
    validate_run(df, CONFIG)
  })
  
  # --- Export button gate ---------------------------------------------------
  # Disable the export button whenever there are no samples or any errors, so
  # the download dialog never even opens on an invalid run. The download
  # handler keeps its own guard as a backstop.
  shiny::observe({
    shinyjs::toggleState(
      "export",
      condition = nrow(samples()) > 0L && length(validation()$errors) == 0L
    )
  })
  
  output$validation_msgs <- shiny::renderUI({
    v <- validation()
    
    # pristine: no errors, no warnings, at least one sample
    if (!length(v$errors) && !length(v$warnings)) {
      if (nrow(samples()) > 0L) {
        return(shiny::div(class = "text-success",
                          shiny::tags$b("\u2713 Keine Probleme gefunden.")))
      }
      return(NULL)
    }
    
    err_block <- if (length(v$errors)) {
      shiny::div(
        class = "text-danger",
        shiny::tags$b("Fehler (verhindern den Export):"),
        shiny::tags$ul(lapply(v$errors, shiny::tags$li))
      )
    }
    
    warn_block <- if (length(v$warnings)) {
      shiny::div(
        class = "text-warning",
        shiny::tags$b("Warnungen (Export bleibt möglich):"),
        shiny::tags$ul(lapply(v$warnings, shiny::tags$li))
      )
    }
    
    # shown only when there are warnings but NO errors: the run is exportable
    # despite the warnings. Never shown alongside errors or when pristine.
    export_note <- if (length(v$warnings) && !length(v$errors)) {
      shiny::div(
        class = "text-success",
        shiny::tags$b("Hinweis: Der Lauf kann trotz Warnungen exportiert werden.")
      )
    }
    
    shiny::tagList(err_block, warn_block, export_note)
  })
  
  # --- Export hint ----------------------------------------------------------
  # Text companion to the button's enabled/disabled state: explains WHY export
  # is locked (no samples / errors) or that it's ready.
  output$export_hint <- shiny::renderUI({
    if (nrow(samples()) == 0L) {
      shiny::helpText("Noch keine Proben.")
    } else if (length(validation()$errors)) {
      shiny::helpText(
        shiny::span(class = "text-danger",
                    "Export gesperrt: bitte zuerst die Fehler beheben."))
    } else {
      shiny::helpText(
        shiny::span(class = "text-success", "Bereit zum Export."))
    }
  })
  
  # --- Download handler -----------------------------------------------------
  # The guard here -- not the button -- is the actual gate: even if the button
  # is clicked while errors exist, nothing is written. Validation is enforced
  # at the moment of export, from the same validate_run used everywhere else.
  output$export <- shiny::downloadHandler(
    filename = function() samplesheet_filename(input$run_name, CONFIG),
    content  = function(file) {
      v <- validate_run(samples(), CONFIG)
      if (length(v$errors)) {
        shiny::showNotification(
          "Export gesperrt: es bestehen noch Fehler.", type = "error")
        stop("Export blocked: unresolved validation errors.")
      }
      lines <- build_samplesheet(samples(), input$run_name, CONFIG)
      write_samplesheet(lines, file, CONFIG)
    }
  )
  
  # --- Table ----------------------------------------------------------------
  output$samples <- DT::renderDT(
    {
      df <- samples()
      # friendlier column names for display; underlying data unchanged
      names(df) <- c("Sample_ID", "IndexUDP (nur Vorschau)",
                     "index", "index2", "Sample_Project")
      df
    },
    selection = "single",
    rownames  = FALSE,
    options   = list(dom = "t", paging = FALSE)
  )
  
  output$count_text <- shiny::renderText({
    n <- nrow(samples())
    sprintf("%d Probe%s im Lauf.", n, if (n == 1) "" else "n")
  })
}