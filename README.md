# samplesheet-generator-pathology

Local R Shiny app that generates Illumina v2 `SampleSheet.csv` files for the
Pathology WES runs on the NovaSeq X Plus.

Today the sample-to-index assignment lives on a handwritten note and the sheet is
assembled by hand. This app lets the Molekularpathologe enter each sample and pick
its index from a dropdown, then writes a validated sample sheet.

> **Status: `v0.0.1` -- skeleton.** The app launches but has no functionality yet.
> See [`PROJECT_PLAN.md`](PROJECT_PLAN.md) for scope and phases.

## Documentation

| File | Contents |
|---|---|
| [`PROJECT_PLAN.md`](PROJECT_PLAN.md) | Scope, requirements, architecture, phases |
| [`docs/DECISIONS.md`](docs/DECISIONS.md) | Decisions, reasons, how to reverse them, open items |
| [`INSTALL.md`](INSTALL.md) | Development setup and offline install on a lab PC |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Branches, commits, tests |
| [`CHANGELOG.md`](CHANGELOG.md) | Version history |

## Quick start (development)

```r
renv::restore()   # first time
shiny::runApp()   # or open app.R in RStudio and click "Run App"
```

## Repository layout

```
app.R                  entry point -- open in RStudio, "Run App"
R/config.R             all reversible settings in one list
R/indexes.R            index table loading and lookup
R/validate.R           Sample_ID and run-level validation
R/samplesheet.R        template rendering and CRLF writing
R/ui.R, R/server.R     Shiny app
data/udp_indexes.csv   frozen IDT UD index table (96 indexes)
templates/wes.csv      fixed sheet sections for the WES assay
data-raw/              one-off script that regenerates the index table
tests/testthat/        tests, including the byte-for-byte reference test
docs/                  decision log, user guide
```

## Data protection

Sample_IDs are Pathology accession numbers and are **patient-linked**. The app
holds them in memory for the session only and writes nothing to disk except the
sample sheet you export. Only the anonymized reference sheet is committed to this
repository; never commit a real one.
