# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versioning is semantic.

## [0.0.1] - 2026-08-07

### Added
- Repository skeleton: folder structure, `.Rproj`, `.gitignore`, MIT license.
- `PROJECT_PLAN.md` -- scope, requirements with acceptance criteria, phases.
- `docs/DECISIONS.md` -- D-001..D-012 and open items O-001..O-009.
- `data/udp_indexes.csv` -- frozen IDT for Illumina UD index table (Plate A / Set 1,
  96 indexes) with provenance header, plus `data-raw/freeze_index_table.R`.
- `templates/wes.csv` -- fixed sheet sections, derived from the reference run.
- Anonymized reference sample sheet as a test fixture, with the recovered index names.
- Placeholder Shiny app that doubles as a dependency smoke test.
