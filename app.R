# ---------------------------------------------------------------------------
# SampleSheet Generator (Pathologie, WES) -- entry point.
#
# Start in RStudio: open this file and click "Run App".
# ---------------------------------------------------------------------------

library(shiny)
library(bslib)
library(DT)

for (f in list.files("R", pattern = "[.]R$", full.names = TRUE)) source(f)

shinyApp(ui = app_ui(), server = app_server)
