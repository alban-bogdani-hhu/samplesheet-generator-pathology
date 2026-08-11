# Changelog

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/); versioning is semantic.

## [0.3.0] - 2026-08-10

### Added
- Interactive Shiny UI (`R/ui.R`, `R/server.R`) covering the full flow:
  - Enter a Sample_ID and pick an index; the sample is added with its i7/i5
    resolved immediately and stored in the exact shape the generator expects.
  - Searchable `selectizeInput` index dropdown (D-014): filter 96 indexes by
    UDP name or by sequence, with the matching bases highlighted.
  - Used indexes are excluded from the dropdown (D-010); removing a sample
    returns its index to the list.
  - Live two-tier validation with three-state signalling: pristine (green),
    exportable-with-warnings (yellow + note), blocked (red).
  - Optional RunName field; empty RunName exports as `NA` (D-002).
  - Gated export: the download button is disabled via `shinyjs` (D-013) when
    there are no samples or any errors, and the download handler re-validates
    as a backstop, so no invalid sheet can ever be written.
  - Exported file name follows `<RunName>-samplesheet.csv` (D-004).

### Changed
- `shinyjs` added as a runtime dependency, solely for export-button gating
  (D-013) — an acceptable, safety-motivated exception to the minimal-dependency
  rule (D-007).

### Verified
- End-to-end: the reference run, entered through the UI, exports a file
  byte-identical to `tests/testthat/fixtures/reference-samplesheet.csv` — the
  UI path produces the same output the tested core does.

## [0.2.0] - 2026-08-10

### Added
- Validation layer (`R/validate.R`), two tiers per D-005:
  - `validate_sample_id()` — Illumina's hard rules (length, allowed characters,
    separator placement, reserved words); blocking tier.
  - `check_id_pattern()` — soft warning against the Pathology naming pattern,
    switchable via `id_pattern_mode` (`warn` / `off`), never blocking.
  - `validate_run()` — cross-row checks: duplicate Sample_ID, duplicate index
    pair (reported by the samples sharing it), and index length vs. the
    template's `Index1Cycles` / `Index2Cycles`.
  - `template_index_cycles()` — derives expected index length from the template,
    so the template is the single source of truth (no hardcoded 10).
- Tests for every rule, including reserved words, separator edge cases, and the
  multi-problem aggregation path.

### Notes
- Validation is implemented but not yet wired into export; the Shiny server
  (Phase 3) will gate export on `validate_run` — errors block, warnings do not.

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