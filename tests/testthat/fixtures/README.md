# Test fixtures

## `reference-samplesheet.csv`

A **real** NovaSeq X Plus WES sample sheet from Pathology, **anonymized**:

- Accession numbers replaced with sequential placeholders (`0000`-`0007`)
- Instrument serial, run number and flow cell ID masked, structure preserved
- Index sequences are **unchanged** -- they are public vendor data (IDT for
  Illumina UD Indexes) and carry no patient information

It is the reference for the byte-for-byte acceptance test (F-10): given its 12
Sample_IDs and their 12 index names, the app must reproduce this file exactly,
including CRLF line endings and the absence of a trailing blank line.

**Never replace this with a non-anonymized sheet.** Git history is effectively
permanent, including in a private repository (docs/DECISIONS.md, D-012).

Index names recovered from the sequences, for use in the test:

| Sample_ID | Index |
|---|---|
| 0000-26_3-N | UDP0002 |
| 0001-26_3-N | UDP0003 |
| 0002-26_3-N | UDP0004 |
| 0003-26_3-N | UDP0074 |
| 0004-26_3-N | UDP0088 |
| 0005-26_3-N | UDP0005 |
| 0000-26_1-T | UDP0001 |
| 0001-26_1-T | UDP0009 |
| 0002-26_1-T | UDP0010 |
| 0003-26_1-T | UDP0080 |
| 0006-26_1-T | UDP0094 |
| 0007-26_1-T | UDP0016 |
