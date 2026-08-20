# Decision Log

Single source of truth for decisions taken, why, and **how to reverse them**.
`PROJECT_PLAN.md` links here rather than duplicating the list.

- **Status:** `Active` · `Superseded by D-nnn` · `Provisional` (decided on incomplete
  information; revisit when the open item closes)
- **Reversible via:** the concrete edit needed. `Architectural` means it is not a flip of a
  setting and needs redesign.

## Decisions

| ID | Decision | Reason | Status | Reversible via |
|---|---|---|---|---|
| D-001 | No persistence in the MVP — state is in-memory, the exported CSV is the only artifact | Sample_IDs are patient-linked. A persistent store on a lab PC creates a new location for patient data → a Datenschutz question, not an engineering one. Not needed to produce a sheet. | Active | Architectural (see O-005) |
| D-002 | Empty RunName is written as the literal string `NA`, the line is never omitted | Kai, 2026-08: *"Am besten die Zeile RunName drinlassen und dahinter ein NA einrichten."* The Molekularpathologe does not always know the run name at creation time. | Active | `R/config.R: empty_runname_value` |
| D-003 | i5 sequences are taken from the **forward orientation** column | NovaSeq X Plus with a v2 sheet: DRAGEN/BCL Convert reverse-complements i5 itself. Verified 12/12 against the real reference run. | Active | `R/config.R: i5_column` |
| D-004 | Export filename is `<RunName>-samplesheet.csv` | Matches the convention of the sheet Kai supplied (lowercase, hyphen) rather than inventing one. Empty RunName → `NA-samplesheet.csv`, which is visibly unfinished — the correct signal when a human still has to complete it. | Active | `R/config.R: filename_pattern` |
| D-005 | Two-tier Sample_ID validation: Illumina's rules **block**, the Pathology pattern **warns** | Illumina's rules are objective and a violation fails at BCL Convert anyway. The Pathology pattern is inferred from one run; conventions (O-001) are unknown, so hard enforcement could reject a legitimate sample (control, repeat, unusual material code) and push users back to Excel. | Active (pattern promotion pending O-001) | `R/config.R: id_pattern_mode` (`warn` → `block`) |
| D-006 | Fixed sheet sections live in `templates/wes.csv`, not hardcoded in R | Kai has already named a WGS variant as a later feature, so a second template is known to be coming. Adding it becomes dropping in a file. | Active | Add `templates/wgs.csv`; `R/config.R: template` |
| D-007 | Runtime dependencies limited to `shiny`, `bslib`, `DT`. No tidyverse. | Everything needed is string assembly, a 96-row lookup and a table. Deployment vendors every package to a USB stick for offline install on machines we cannot debug remotely; each transitive dependency is a thing that can fail there. | Active | Architectural (adding is easy, removing later is not) |
| D-008 | Configuration is an R list in `R/config.R`, not YAML | Avoids a `config`/`yaml` dependency for a file only this app reads — see D-007. Still one file, one edit. | Active | Swap to `config.yml` + `yaml` dep |
| D-009 | Re-import of an exported sheet is deferred to Post-MVP | Not needed to produce a sheet. Its real value is session recovery and fixing one row without re-entering all samples, not the RunName case. Feasible: the reverse lookup `(i7,i5) → UDP` works because all 96 index pairs in the frozen table are unique (verified). | Active | Phase 5 |
| D-010 | The index dropdown offers only indexes not yet used in the current run | BCL Convert fails on duplicate index pairs, so uniqueness is enforced downstream regardless; better to make the error unrepresentable at input time. Validator keeps the check as a backstop. | Active | `R/config.R: exclude_used_indexes` |
| D-011 | `data/udp_indexes.csv` is committed as a frozen artifact; regenerated only by `data-raw/freeze_index_table.R` | Vendor reference data does not change between runs. Keeps `openxlsx` out of the runtime dependency set and makes the table diffable and auditable. File carries the source SHA-256. | Active | Re-run the `data-raw` script |
| D-012 | Only the **anonymized** reference sheet is committed as a test fixture | Real accession numbers in git history are effectively permanent, even in a private repo. | Active | Architectural — never commit real IDs |
| D-013 | Added `shinyjs` as a runtime dependency, solely to disable the export button on invalid runs (no samples / validation errors) | Preventing an invalid clinical export from even starting is the correct gate; the download-handler guard alone still opened the OS save-dialog before refusing. `shinyjs` is small, standard, and installs cleanly offline — an acceptable exception to the minimal-dependency rule (D-007) for a safety-adjacent interaction. | Active | Remove `shinyjs`; revert to handler-guard-only |
| D-014 | Index dropdown is a searchable `selectizeInput`; the label carries UDP name + both sequences so typing any of them filters | Selecting a barcode by eye among 96 rows was slow and error-prone in real use. Search by name or sequence makes assignment fast. No custom JS — built-in selectize search only. | Active | Revert to `selectInput` |
| D-015 | No launcher script; the app is started manually via the .Rproj file | A double-click launcher would depend on each machine's R install path, undermining the goal of one self-contained version everyone installs identically, and adding a machine-dependent failure point to a clinical tool. Routine open is a few clicks weekly; one-time setup needs IT for R/RStudio regardless. | Active | A hosted deployment (Shiny Server) is the robust step-reduction path — a separate, larger decision |


## Open items

| ID | Open question | Blocks | Owner / next step |
|---|---|---|---|
| O-001 | Sample_ID conventions: allowed material codes, allowed suffixes beyond `N`/`T`, repeat/top-up naming (questionnaire 5.1, 5.2, 5.5) | Promoting D-005 from `warn` to `block` | Ask Kai when convenient — not MVP-blocking |
| O-002 | Are there controls in a run (NA12878, HD reference) and how are they named? (5.4) | Same as O-001 | Ask with O-001 |
| O-003 | Lane-specific splitting — needs an example sheet with a `Lane` column | Post-MVP feature | Kai offered to send an example |
| O-004 | WGS: which template and which barcode table | Post-MVP feature | Kai |
| O-005 | Persistence / library metainformation: which fields, and is a patient-linked store on a lab PC acceptable? | D-001 reversal | Datenschutz question first, then Kai |
| O-006 | How many machines need the app, and does Kai's own machine need it too? (The pathologist creates the sheet, Kai may complete it later — but not always.) | `INSTALL.md` scope | Ask Kai before Phase 4 |
| O-007 | Re-import edge cases: unknown index pair (hand-edited file / other index set); re-validate or trust imported Sample_IDs | Phase 5 design | Decide when the parser exists |
| O-008 | Are index sets 2–4 ever used, or sets mixed within a run? (2.5) | Whether the frozen table needs to span plates | Ask with O-001 |
| O-009 | Regulatory requirements — IVDR / accreditation / QM: versioning, logging, four-eyes release? (9.4) | Could add hard requirements late | Ask before Phase 4 |
| O-010 | Inline editing of a row's Sample_ID in the preview table (fix a typo without remove-and-re-add). Scope: Sample_ID column only; edits must write back to the samples() reactiveVal; other columns stay locked to preserve UDP↔sequence integrity. | Nice-to-have, post-MVP | Deferred by Alban, 2026-08 |
| O-011 | Selectable RunDescription in the UI (1.5B / 10B WES Pathologie Lauf) — R-1 | Next release | Kai, 2026-08 |
| O-012 | WGS support: separate template + barcode table (drop-in per D-006) — R-2 | Next release | Kai, reference files pending |
| O-013 | Optional lane splitting: template variant + per-sample Lane column in [BCLConvert_Data] — R-3 | Next release | Kai, reference files pending |
| O-014 | Layout bug: when the sample table grows tall, the "Ausgewählte Zeile entfernen" button (placed after DTOutput inside the card) is overlapped by the scrolling table rows. Reported by Kai. Fix: move the button outside/above the scroll area, or give the table a fixed height with its own scroll. | Bug — fix next release | Kai, 2026-08 |

## Changelog

- **2026-08-07** — D-001 … D-012 recorded; O-001 … O-009 opened. D-002 closed by Kai's answer.
- **2026-08-10** — Phase 0 closed.
- **2026-08-10** — Phase 1 closed (`v0.1.0`). Phase 2 closed (`v0.2.0`): D-005 tiers
  implemented; pattern-to-blocking promotion still pending O-001. Validation-export
  wiring assigned to Phase 3.
  
