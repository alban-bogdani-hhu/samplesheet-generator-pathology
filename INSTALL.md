# Installation

Two audiences: **development** (your Windows machine) and **deployment** (offline
install on a lab PC).

---

## 1. Development setup

### Prerequisites

- R (4.3 or newer)
- RStudio or Positron
- Git

### First-time setup

```r
# 1. Open samplesheet-generator-pathology.Rproj in RStudio

# 2. Initialise the environment (creates .Rprofile, renv/ and renv.lock)
install.packages("renv")
renv::init()

# 3. Install the runtime dependencies
install.packages(c("shiny", "bslib", "DT"))

# 4. Snapshot them into the lockfile
renv::snapshot()
```

> `.Rprofile` is intentionally **not** in the repository. `renv::init()` creates it;
> shipping one that activates renv before renv exists would break a fresh clone.

### Verify the skeleton

```r
# Launch -- confirms shiny, bslib and DT all load
shiny::runApp()

# Run the Phase 0 smoke tests
testthat::test_dir("tests/testthat")
```

The placeholder app prints the versions of R and all three packages. That is
deliberate: it is the cheapest possible check that the environment on a lab PC is
complete.

### Development-only packages

`openxlsx` is needed **only** by `data-raw/freeze_index_table.R` and must stay out
of the runtime dependency set (D-007). Install it outside the snapshot, or record
it and remember it is not needed in the lab.

---

## 2. Regenerating the index table (rare)

`data/udp_indexes.csv` is committed and frozen. Regenerate it only when IDT or
Illumina publishes a changed workbook:

```bash
Rscript data-raw/freeze_index_table.R data-raw/IDT_for_Illumina_UD_Indexes.xlsx
```

> The R version of this script has not yet been executed -- the committed CSV was
> produced by the original Python implementation. **Before replacing the CSV,
> diff the new output against the old one** and confirm only the intended rows
> changed. The script validates the vendor file's internal consistency (i7 and i5
> orientation relationships, index lengths, pair uniqueness) and refuses to write
> if anything fails.

---

## 3. Offline deployment to a lab PC

Same pattern as `novaseq-primary-data-dashboard`.

### Prerequisites on the target machine

- Windows 11
- R (same MAJOR.MINOR as development -- `renv` restores are version-sensitive)
- RStudio

### Steps

1. **On the development machine**, make sure the environment is complete and the
   tests pass:

   ```r
   renv::snapshot()
   testthat::test_dir("tests/testthat")
   ```

2. **Copy the whole project folder** -- including `renv/library/` -- to a USB
   stick. Note that `renv/library/` is gitignored, so a `git clone` on the target
   machine is *not* sufficient for an offline install; the folder copy is what
   carries the packages.

3. **On the lab PC**, copy the folder to a local path (not the USB stick itself).

4. Open `samplesheet-generator-pathology.Rproj` in RStudio.

5. If R prompts about renv, run:

   ```r
   renv::restore()
   ```

   With the library already present this should be a no-op or near-instant.

6. Open `app.R` and click **Run App**.

### Verifying the install

Before handing over, confirm on the target machine:

- [ ] The app window opens without errors
- [ ] The status panel shows R and all three package versions
- [ ] `testthat::test_dir("tests/testthat")` passes
- [ ] A test export produces a file with CRLF line endings
      (open in Notepad++: *View → Show Symbol → Show End of Line* shows `CRLF`)

### Updating an installed copy

Replace the project folder and repeat. There is no in-place update mechanism and
no persistent state to migrate (D-001), which is one of the reasons the MVP holds
state in memory only.
