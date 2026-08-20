# Architecture — SampleSheet Generator (WES, Pathology)

Audience: Kai (domain owner) and any future developer. This document explains
what the app is, how it is built, how the pieces connect, and the reasoning
behind the decisions most likely to be questioned.

For *using* the app, see `USER_GUIDE.md`. For *installing* it, see
`docs/INSTALL.md`. For the full decision log, see `docs/DECISIONS.md`.

---

## 1. What it is

A local R Shiny app that produces an Illumina v2 `SampleSheet.csv` for a
NovaSeq X Plus WES run. The pathologist enters each sample and picks its index;
the app resolves the index to its barcode sequences, validates the whole run,
and exports a correctly formatted sheet. It replaces a manual process
(handwritten note → Excel).

The app runs entirely offline on a Windows PC. All packages are bundled with it.

---

## 2. Design principles

1. **Correctness is proven, not assumed.** Every claim about the output format
   is backed by a test against a real reference sheet, not by reading
   documentation.
2. **The engine is separate from the interface.** All correctness-critical
   logic lives in pure functions that know nothing about Shiny. The UI only
   *drives* those functions. This is why the engine can be proven correct
   independently of the interface.
3. **Reversibility where there is evidence of change.** Decisions likely to
   change (index orientation, the WGS variant, the RunName rule) live in one
   config file and are one edit to reverse. Everything else is hardcoded until
   there is a reason.
4. **Minimal dependencies.** Every package must install offline on a lab PC, so
   the dependency set is deliberately small.

---

## 3. Layout

```
app.R                    entry point: loads R/, launches the app
R/
  config.R               all reversible settings (CONFIG list)
  indexes.R              load the index table, resolve names, list available
  samplesheet.R          render template, build rows, write CRLF file
  validate.R             per-ID and run-level validation
  ui.R                   Shiny layout
  server.R               reactive logic (the orchestrator)
data/
  udp_indexes.csv        frozen IDT UD index table (96 indexes), with checksum
templates/
  wes.csv                fixed sheet sections, {{RUNNAME}} placeholder
data-raw/
  freeze_index_table.R   one-off: builds data/udp_indexes.csv from the vendor xlsx
tests/testthat/          unit tests + the byte-for-byte acceptance test
docs/                    INSTALL, ARCHITECTURE, DECISIONS, USER_GUIDE stays at root
renv/, renv.lock         pinned package versions for reproducible install
DESCRIPTION              declares the (few) dependencies
```

---

## 4. The files, by role

### Reference data (does not change per run)

- **`data/udp_indexes.csv`** — all 96 UDP indexes with their barcode sequences.
  Read at runtime, never computed. A commented header records the source Excel
  file and its checksum, so any sheet traces back to an exact source.
- **`templates/wes.csv`** — the fixed skeleton of a sample sheet (`[Header]`,
  `[Reads]`, `[BCLConvert_Settings]`, down to the data header row). One
  placeholder, `{{RUNNAME}}`. Derived byte-for-byte from a real run. Being a
  file (not hardcoded) means a future WGS variant is a drop-in.

### Logic (pure functions, no Shiny)

- **`R/config.R`** — the `CONFIG` list: the small set of settings expected to
  change (i7/i5 columns, empty-RunName value, filename pattern, ID rules, line
  ending). Every other file reads settings from here.

- **`R/indexes.R`**
  - `load_index_table()` — reads the frozen CSV, validates structure (columns,
    non-empty, unique names), returns a data frame.
  - `resolve_index(name)` — returns the i7/i5 for a UDP name from the configured
    columns; an unknown name is a hard error, never a silent blank.
  - `available_indexes(used)` — the names still free, for the dropdown.

- **`R/samplesheet.R`**
  - `render_template(run_name)` — fills the template; an empty run name becomes
    the literal string `"NA"` (never R's `NA` value).
  - `samplesheet_filename(run_name)` — `<RunName>-samplesheet.csv`, Windows-safe.
  - `build_samplesheet(samples, run_name)` — template + one row per sample.
    Pure assembly; does not validate content.
  - `write_samplesheet(lines, path)` — writes with CRLF endings via a binary
    connection, so line endings are never silently translated.

- **`R/validate.R`**
  - `validate_sample_id(id)` — Illumina's objective rules (length, characters,
    separators, reserved words). Blocking tier.
  - `check_id_pattern(id)` — the pathology naming pattern. Warning tier only.
  - `validate_run(samples)` — whole-pool checks: duplicate IDs, duplicate index
    pairs, index length vs. template cycles. Returns `list(errors, warnings)`.
  - `template_index_cycles()` — reads the expected barcode length from the
    template, so there is a single source of truth.

### The app

- **`R/ui.R`** — `app_ui()`: layout only (fields, dropdown, buttons, table,
  validation panel). No logic.
- **`R/server.R`** — `app_server()`: the orchestrator. Holds the samples in an
  in-memory reactive value (nothing persisted but the export), keeps the
  dropdown in sync, resolves indexes on Add, runs `validate_run` live, gates the
  export button, and on export calls `build_samplesheet` → `write_samplesheet`.
- **`app.R`** — loads packages, sources `R/`, launches.

### Proof

- **`tests/testthat/`** — unit tests for every logic function, and
  `test-acceptance.R`, which reproduces a real anonymized sample sheet
  **byte-for-byte** from its sample IDs and index names. That one test proves
  i5 orientation, index resolution, row order, column order, and line endings
  are all correct at once.

---

## 5. How a run flows

```
   templates/wes.csv                  data/udp_indexes.csv
    (fixed sections)                   (UDP name -> i7/i5)
          |                                    |
          |                            load_index_table()   (at startup)
          |                                    |
          |               available_indexes() / resolve_index()
          |                                    |
          |     R/server.R (orchestrator)      |
          |        pathologist enters          |
          |        Sample_ID + picks index ----+
          |                |
          |                v  (index resolved on Add)
          |        samples()  <- in-memory truth
          |                |
          |                v
          |        validate_run()  <- live on every change
          |          errors  -> red, export button disabled
          |          warnings-> yellow, export still allowed
          |                |
          |        [export clicked, no errors]
          |                |
          +----------------v
                   build_samplesheet()  (template + rows)
                           |
                           v
                   write_samplesheet()  (CRLF bytes)
                           |
                           v
                <RunName>-samplesheet.csv
```

Mental model: `data/` and `templates/` are frozen truth; the `R/` logic
transforms input against that truth; `server.R` wires the logic to buttons and
state; the tests prove the transform; `docs/` records why.

---

## 6. Decisions most likely to be questioned

- **i5 forward orientation.** NovaSeq X Plus with a v2 sheet expects i5 in
  forward orientation; the instrument reverse-complements it. Wrong orientation
  = zero reads for every sample = wasted flow cell. Verified against a real run
  in the acceptance test.

- **CRLF line endings.** Illumina sheets use Windows line endings. R translates
  line endings on ordinary writes, which would produce a right-looking, wrong
  file. The writer emits raw bytes through a binary connection. Asserted by a
  byte-exact test.

- **Empty RunName = literal `"NA"`.** Requested by Kai. Written as the character
  string `"NA"`, guarded against becoming R's `NA` (which could silently become
  an empty field).

- **Two-tier validation.** Illumina's objective rules block; the pathology
  naming pattern only warns. The pattern was inferred from one run, so blocking
  on it could reject a legitimate but unusual sample (a control, a repeat). It
  can be promoted to blocking with a one-line config change once the naming
  conventions are confirmed.

- **No launcher script.** A double-click launcher would depend on each machine's
  R install path, which undermines the goal of one self-contained version
  everyone installs identically, and adds a machine-dependent failure point.
  The routine open is a few clicks once a week; the one-time setup needs IT for
  R/RStudio regardless. If step-reduction becomes important, the robust path is
  a hosted deployment (e.g. Shiny Server), which is a separate, larger decision.

---

## 7. Known limitation (state this plainly)

The Sample_ID is typed by hand and there is **no external source of truth** to
check it against. A Sample_ID that is valid but wrong — for example `_1` typed
instead of `_3` — cannot be caught by any validation. The app narrows the risk
(format checks, live validation, a review table, a gated export) but cannot
eliminate it. This is inherent to the manual process, not a gap in the tool.

---

## 8. Next release — requirements

The following features were requested by Kai for the next release. Requirements
only; implementation is deferred. Kai will provide reference example files.

### R-1 — Selectable RunDescription

`RunDescription` is currently fixed in the template. Make it selectable in the
UI via a dropdown, with (at least) these options:

- `1.5B WES Pathologie Lauf`
- `10B WES Pathologie Lauf`

The chosen value is written into the `RunDescription` line of the exported
sheet. (The two options correspond to different flow cell types.)

### R-2 — WGS template

Add support for WGS runs. WGS uses a **different template** (different header /
settings sections) **and a different index table** than WES. The design already
anticipates this: sheet sections live in `templates/` and the index table is
referenced via config, so WGS is intended as a drop-in — a `templates/wgs.csv`
plus its barcode table, selected via config or a UI choice. Reference files to
be supplied by Kai.

### R-3 — Optional lane splitting

The current template sets `NoLaneSplitting,True` — all samples share the lane.
In rare cases the lab needs **lane splitting**, where different samples in the
same sheet belong to different lanes. This requires:

- a template variant with `NoLaneSplitting` set accordingly, and
- an extra **`Lane`** column in the `[BCLConvert_Data]` section, assigned per
  sample (likely via a dropdown in the UI, similar to index selection).

This is an uncommon case, so it should be an explicit mode rather than the
default. Reference files to be supplied by Kai.

---

### Known bugs (to fix)

- **B-1** — When the sample list is long, the "Ausgewählte Zeile entfernen"
  button overlaps the scrolling table (layout issue). Reported by Kai.

Older deferred items (re-import, inline Sample_ID editing, persistence,
promoting the ID pattern to blocking) remain tracked in `docs/DECISIONS.md`
open items, but are lower priority than R-1..R-3 above.
