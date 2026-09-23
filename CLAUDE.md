# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Do not include a Co-Authored-By line in commit messages.

## What this is

IT3081 (Statistical Modelling) university group assignment. Consultancy-framed analysis of
the UCI **Online Retail II** dataset: predict which customers of a UK online gift wholesaler
will repurchase, and how much they'll spend, then turn that into retention recommendations.
Full brief: [SM-Project.pdf](SM-Project.pdf); project design and task breakdown: [README.md](README.md).

**Stack: hybrid Python + R, split by task, not by whole-project choice.** Tasks 4 and 9
(`notebooks/r/`) are R; everything else (`notebooks/python/`) is Python. See README's
notebook table for the full mapping and the reasoning. `legacy-python/` and the two
`_legacy` notebooks under `notebooks/python/` hold the original all-Python versions of
Tasks 4 and 9 for reference — not part of the submission, don't extend them.

## Commands

```bash
# Python setup (once)
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```
```r
# R setup (once) - needs R 4.x
source("packages.R")
```
```bash
# Re-download the raw dataset if data/raw/ is empty (gitignored, ~45MB)
curl -L -o data/raw/online_retail_ii.zip "https://archive.ics.uci.edu/static/public/502/online+retail+ii.zip"
cd data/raw && unzip -o online_retail_ii.zip
```

Run a Python notebook by opening it in Jupyter/VS Code (`notebooks/python/`). Run an R
script from the project root, not from inside `notebooks/r/`:
```bash
Rscript notebooks/r/02_statistical_inference.R
```

There is no test suite, linter, or build step — this is an analysis project.
`notebooks/python/00_data_cleaning.ipynb` must be run first; every other script/notebook
(Python or R) reads its output from `data/processed/`.

## Architecture

**Data flow:** `data/raw/` (raw UCI xlsx, gitignored) → cleaning (`src/cleaning.py` for
Python notebooks, `R/cleaning.R` for R scripts — same logic, ported and verified to
produce identical results) → feature engineering (`src/features.py` / `R/features.R`) →
`data/processed/*.csv` (gitignored) → consumed independently by each notebook/script.

**The cutoff-date design is the central mechanic of the whole project** (`src/features.py`
and `R/features.R`, kept in sync): `CUTOFF_DATE = 2011-09-09`. Every customer-level feature
(RFM, tenure, basket value, cancellation rate, etc.) is computed only from transactions
*before* this date; the two prediction targets (`Repurchase`, `FutureSpend`) are computed
only from the 90 days *after* it. This split exists to prevent data leakage and is
something every notebook/script and the final write-up must respect — don't join
future-window data back into features.

**`src/` and `R/` hold the only shared logic.** Everything else — statistics, modelling,
plots — lives inline in each notebook/script per task, since each one corresponds to one
graded task in the brief and should be independently readable/reviewable by teammates.
Don't move analysis code into `src/`/`R/` unless it's genuinely reused. If you change the
cleaning/feature logic in one language, check whether the same fix is needed in the other
(e.g. `NON_PRODUCT_CODES` must match between `src/cleaning.py` and `R/cleaning.R`).

**Path depth matters for `notebooks/python/*.ipynb`:** they're two levels below the
project root, so `sys.path.append('../..')` and `../../data/...` (not `../data/...`).
`notebooks/r/*.R` scripts are written to be run from the project root, so they use plain
`data/...` / `reports/...` paths, not `../`.

**CSV type gotchas when a Python-written CSV is read by an R script:** pandas writes
booleans as the literal strings `"True"`/`"False"`, which R reads as character, not
logical — `IsCancellation` needs `as.logical()` after `read.csv()` in any R script that
reads `invoice_lines_clean.csv`.

**Notebook-to-task mapping** (see README.md for the full table): `00_data_cleaning` builds
the processed tables; `01`, `03`–`05` (Python) map to Tasks 3, 5, 7, 8; `02`, `06` (R) map
to Tasks 4, 9. Tasks 1, 2, 6, 10, 11, 12 are written deliverables (problem framing, lit
review, experimental design, innovation proposal, expert interview, final recommendations)
with no corresponding notebook — `references/literature_review.md` is the stub for Task
2's comparison table, `docs/` holds the Task 1/2 write-up.

**Team ownership** (also in README.md): different people own different notebooks/tasks, so
avoid restructuring `src/`/`R/` function signatures without checking what other
notebooks/scripts call.
