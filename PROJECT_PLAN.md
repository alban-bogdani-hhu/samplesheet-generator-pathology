# Project Plan — `samplesheet-generator-pathology`

> A local R Shiny app that generates Illumina v2 `SampleSheet.csv` files for the Pathology
> WES runs on the NovaSeq X Plus, replacing manual assembly from a handwritten note.

## Status

| Field | Value |
|---|---|
| Owner | Alban Bogdani |
| Organization | Institut für Humangenetik, UKD |
| Repo | `samplesheet-generator-pathology` |
| Current phase | Phase 2 — Validation (complete) |
| Current branch | `develop` |
| Version | `v0.2.0` |
| Last updated | 2026-08-10 |

## Scope

**In scope (MVP)**

- Interactive entry of samples: Sample_ID typed by the user, index picked from a dropdown.
- Index lookup against the frozen IDT for Illumina UD Index table (Plate A / Set 1).
- Validation of Sample_IDs and index assignment before export.
- Export of a valid Illumina v2 SampleSheet for WES, byte-identical in structure to the
  sheets Pathology produces today.
- Offline operation on a Windows 11 lab PC, launched from RStudio.

**Out of scope (MVP)**

| Item | Why deferred | Tracked as |
|---|---|---|
| Re-import of an exported sheet | Not needed to produce a sheet; needs a reverse index lookup and edge-case decisions | D-009, Phase 5 |
| Persistence (drafts, index-usage history, audit log) | Creates a new store of patient-linked IDs → Datenschutz question, not an engineering one | D-001, O-005 |
| Lane-specific splitting (`Lane` column) | Named by Kai as a later feature; needs an example sheet | O-003 |
| WGS template + alternative barcode tables | Named by Kai as a later feature; WES only for now | O-004 |
| Library metainformation capture | Undefined field set | O-005 |
| Strict Pathology Sample_ID pattern enforcement | Conventions (5.1/5.2/5.5) not yet answered | D-005, O-001 |
| Index sets 2–4 | Only Plate A / Set 1 in use as far as known | O-008 |

## Requirements

### Functional

| ID | Requirement | Acceptance |
|---|---|---|
| F-1 | Add a sample by typing a Sample_ID and selecting an index name | Sample appears in the on-screen table with its i7/i5 sequences resolved |
| F-2 | Index dropdown offers only indexes not yet used in the current run | After assigning `UDP0001`, it is absent from the dropdown |
| F-3 | Remove a sample from the current run | Row disappears; its index returns to the dropdown |
| F-4 | Enter an optional RunName | Empty RunName is written as the literal `NA` (D-002) |
| F-5 | Reject Sample_IDs that violate Illumina's rules | Add is blocked with a clear message (see D-005) |
| F-6 | Warn on Sample_IDs that don't match the Pathology pattern | Row is flagged but still addable |
| F-7 | Reject a duplicate Sample_ID within the run | Add is blocked |
| F-8 | Show a review table before export | Sample_ID ↔ index name ↔ i7 ↔ i5 visible for cross-reading |
| F-9 | Export a v2 SampleSheet as `<RunName>-samplesheet.csv` | File downloads with UTF-8 + CRLF, no trailing blank line |
| F-10 | Reproduce the reference run exactly | **Byte-for-byte** match against `tests/testthat/fixtures/reference-samplesheet.csv` given its 12 Sample_IDs and 12 index names |

### Non-functional

| ID | Requirement | Acceptance |
|---|---|---|
| N-1 | Runs fully offline | No network calls at runtime |
| N-2 | Windows 11 + R + RStudio, launched by opening `app.R` and clicking *Run App* | Verified on a lab PC |
| N-3 | Minimal dependency footprint | Runtime deps: `shiny`, `bslib`, `DT` only (D-007) |
| N-4 | Reproducible environment | `renv.lock` committed; `renv::restore()` works offline from the USB copy |
| N-5 | No patient data in the repository | Only the anonymized fixture is committed (D-012) |
| N-6 | Small run sizes | Designed for ≤96 samples per run (one index plate) |

## Design principles

1. **MVP-first.** Ship the smallest thing that produces a correct sheet. No speculative
   features, no abstraction for cases nobody has asked for.
2. **Correctness is checked, not assumed.** Every claim about the output format is backed by
   a test against a real reference file, not by reading documentation.
3. **Reversibility where there is evidence of change.** Decisions that Kai has already
   signalled may change (WGS template, index table, RunName handling, ID pattern) live in
   `R/config.R` or in `templates/` and are one edit to reverse. Everything else is
   hardcoded until there is a reason. Each entry in `docs/DECISIONS.md` records *how* it
   is reversed.
4. **Boring over clever.** Base R for string assembly and lookup; no dependency added to
   save five lines, because every dependency must install offline on a machine we cannot
   debug remotely.
5. **Fail loudly, early, and in the UI.** Prevent the error at input time (dropdown excludes
   used indexes) rather than reporting it at export time.

## Architecture summary

- **Stack:** R, Shiny, bslib (UI), DT (tables). No tidyverse.
- **Data sources:** `data/udp_indexes.csv` (frozen vendor table, 96 indexes);
  `templates/wes.csv` (fixed sheet sections).
- **Key components:** index lookup → validation → sheet writer → Shiny UI around them.
- **State:** in-memory only for the session; the exported CSV is the only artifact.
- **Deployment:** project folder + `renv` library copied via USB to lab PCs; opened in
  RStudio and launched from `app.R`.

### Output assembly

```
templates/wes.csv          data/udp_indexes.csv
 (Header/Reads/Settings)     (UDP name -> i7, i5)
        |                            |
        +---------- build -----------+
                     |
              validate (2-tier)
                     |
        <RunName>-samplesheet.csv   (UTF-8, CRLF)
```

## Component → file mapping

| Component / feature | File | Purpose |
|---|---|---|
| App entry point | `app.R` | Sources `R/`, launches the Shiny app |
| Configuration | `R/config.R` | All reversible settings in one list |
| Index table | `R/indexes.R` | Load and query the frozen UDP table |
| Validation | `R/validate.R` | Two-tier Sample_ID + run-level checks |
| Sheet assembly | `R/samplesheet.R` | Template + rows → CSV text, CRLF writer |
| UI | `R/ui.R` | bslib layout |
| Server logic | `R/server.R` | Reactive state, add/remove, export |
| Frozen index data | `data/udp_indexes.csv` | 96 UDP indexes with provenance header |
| Sheet template (WES) | `templates/wes.csv` | Fixed `[Header]`/`[Reads]`/`[BCLConvert_Settings]` |
| Index table provenance | `data-raw/freeze_index_table.R` | Regenerates `data/udp_indexes.csv` from the vendor .xlsx |
| Reference fixture | `tests/testthat/fixtures/reference-samplesheet.csv` | Anonymized real run for the byte-for-byte test |
| Decision log | `docs/DECISIONS.md` | Decisions, reasons, and how to reverse them |

## Risks & assumptions

| Risk / assumption | Impact if wrong | Mitigation / check |
|---|---|---|
| i5 must be in **forward** orientation for NovaSeq X Plus v2 sheets | Every sample demultiplexes to zero reads — a wasted flow cell | Verified 12/12 against the real run; asserted in the byte-for-byte test (D-003) |
| Line endings must be CRLF | Sheet may be rejected or parsed oddly | Binary connection with explicit `\r\n`; byte-for-byte test catches it |
| Sample_ID is typed by hand with no source of truth to check against | A typo assigns a patient's exome to the wrong accession number | Format validation + review table before export; **this risk cannot be fully removed in the MVP** (O-001) |
| Fixed sections are truly constant across runs | Generated sheets would silently differ from real ones | Kai: *"sehen exakt gleich aus, außer andere Sample IDs und Barcodes"*; template file makes a change one edit |
| `NA` written as R's logical `NA` rather than the string `"NA"` | Header field silently becomes empty — the exact thing Kai asked to avoid | Literal string from config; explicit test on the header line (D-002) |
| Only Plate A / Set 1 is in use | Unknown index names cannot be resolved | Table is config-referenced; unknown index is a hard error, never a silent pass |
| Offline install of `renv` packages on Windows 11 | App will not start in the lab | Same USB pattern already proven in `novaseq-primary-data-dashboard`; placeholder app is a dependency smoke test |

## Phases

> Check items off as completed; bump version at each phase completion.

### Phase 0 — Environment & repository (`v0.0.1`)
- [x] Repo skeleton, folder structure, `.Rproj`, `.gitignore`
- [x] Baseline docs: README, CHANGELOG, INSTALL, CONTRIBUTING, LICENSE, PROJECT_PLAN, DECISIONS
- [x] Frozen index table `data/udp_indexes.csv` + provenance script
- [x] WES template `templates/wes.csv`
- [x] Reference fixture (anonymized) + testthat harness
- [x] `git init`, `develop` branch, first commit, push to GitHub
- [x] `renv::init()`, lockfile committed
- [x] Placeholder app launches and loads all three runtime deps

### Phase 1 — Core generator (`v0.1.0`)
- [x] `R/indexes.R` — load table, resolve index name → i7/i5, list available names
- [x] `R/samplesheet.R` — render template, append data rows, CRLF writer
- [x] Test: byte-for-byte reproduction of the reference fixture (F-10)
- [x] Test: RunName empty → literal `NA` in the header (F-4)

### Phase 2 — Validation (`v0.2.0`)
- [x] `R/validate.R` — Illumina hard rules (blocking)
- [x] Pathology pattern soft warning, switchable via config
- [x] Run-level checks: duplicate Sample_ID, duplicate index pair, index length vs. cycles
- [x] Tests for each rule, including the reserved-word list

### Phase 3 — Shiny UI (`v0.3.0`)
- [ ] Add / remove sample; dropdown excludes used indexes (F-1..F-3)
- [ ] RunName field, validation messages, review table (F-4, F-8)
- [ ] Download handler with sanitized filename (F-9)

### Phase 4 — MVP release (`v1.0.0`)
- [ ] `USER_GUIDE.md`, `INSTALL.md` finalised for the offline USB install
- [ ] Manual acceptance run with Kai against a real (or anonymized) run
- [ ] Tag, freeze `renv`, hand over

## Outstanding decisions / open items

> Single source of truth: **`docs/DECISIONS.md`** (section *Open items*, `O-nnn`).
> Do not duplicate the list here — it will drift.

## Post-MVP (deferred)

- Re-import an exported sheet to continue editing (recover a session, fix a typo, add a
  RunName after the fact) — D-009
- Lane-specific splitting
- WGS template and alternative barcode tables
- Persistence: index-usage tracking across runs, library metainformation — would also close
  the documentation gap Kai described (*"bisher nirgends"*), pending a Datenschutz decision

## Engineering practices

- **Branches:** `main` ← `develop` ← `feature/<name>`
- **Commits:** Conventional Commits (`feat:` / `fix:` / `docs:` / `refactor:` / `test:` / `chore:`)
- **Versioning:** semantic; phase completion bumps MINOR
- **Tests:** `testthat`; core generator covered by a byte-for-byte reference test, validation
  rules covered individually
- **Dependencies:** pinned via `renv`; `renv.lock` committed

## Plan changelog

- **2026-08-07** — initial plan created (`v0.0.1`). Scope fixed after Kai answered the five
  blocking questions: the app is interactive (Shiny), there is no input file to parse, and
  the fixed sheet sections are constant across runs.
- **2026-08-10** — Phase 1 complete (`v0.1.0`): core generator, byte-for-byte acceptance test.
- **2026-08-10** — Phase 2 complete (`v0.2.0`): two-tier validation, run-level checks,
  template-derived index length. Export wiring deferred to Phase 3 (server owns the gate).