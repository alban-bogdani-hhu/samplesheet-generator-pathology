# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versioning is semantic.

## [0.1.0] - 2026-08-10

### Added
- Index layer (`R/indexes.R`): `load_index_table()` with structural validation
  against config, `resolve_index()` (config-driven i7/i5 lookup, hard error on
  unknown names), and `available_indexes()` (excludes used indexes, D-010).
- Sheet generator (`R/samplesheet.R`): `render_template()` with the `"NA"`
  empty-RunName handling (D-002), `samplesheet_filename()` with Windows
  sanitisation (D-004), `build_samplesheet()`, and a CRLF-safe
  `write_samplesheet()` that writes bytes verbatim via a binary connection.
- Byte-for-byte acceptance test (F-10): reproduces the anonymized reference
  sample sheet exactly from its sample IDs and index names, proving the
  resolve → build → write chain and the i5 forward orientation (D-003).
- Test infrastructure: `helper-setup.R` sources `R/` and provides `test_cfg()`
  for path-anchored testing.

## [0.0.1] - 2026-08-07

### Added
- Repository skeleton: folder structure, `.Rproj`, `.gitignore`, MIT license.
- `PROJECT_PLAN.md` -- scope, requirements with acceptance criteria, phases.
- `docs/DECISIONS.md` -- D-001..D-012 and open items O-001..O-009.
- `data/udp_indexes.csv` -- frozen IDT for Illumina UD index table (Plate A / Set 1,
  96 indexes) with provenance header, plus `data-raw/freeze_index_table.R`.
- `templates/wes.csv` -- fixed sheet sections, derived from the reference run.
- Anonymized reference sample sheet as a test fixture, with the recovered index names.
- Phase 0 smoke tests and placeholder Shiny app (dependency smoke test).