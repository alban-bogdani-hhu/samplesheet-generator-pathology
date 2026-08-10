# Contributing

## Branches

```
main            release-ready, tagged at phase ends
  develop       integration
    feature/<name>
```

## Commits

[Conventional Commits](https://www.conventionalcommits.org/):
`feat:` `fix:` `docs:` `refactor:` `test:` `chore:`

Example: `feat(samplesheet): write CRLF line endings via binary connection`

## Versioning

Semantic. Completing a phase bumps MINOR and updates `CHANGELOG.md` plus the
version line in `PROJECT_PLAN.md`.

## Tests

```r
testthat::test_dir("tests/testthat")
```

Every function in `R/` that touches the output format needs a test. The one that
matters most is the byte-for-byte reproduction of
`tests/testthat/fixtures/reference-samplesheet.csv` -- it catches i5 orientation,
row ordering, line endings and header drift in a single assertion.

## Decisions

Anything non-obvious goes in `docs/DECISIONS.md` with a reason and a
"reversible via" entry. Do not start a second list of open items elsewhere.

## Data protection

Never commit a real sample sheet, a real accession number, or any file containing
patient-linked identifiers. The fixture is anonymized and must stay that way.
