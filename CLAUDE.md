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
# Re-download the raw dataset if data/raw/ is empty (~45MB)
curl -L -o data/raw/online_retail_ii.zip "https://archive.ics.uci.edu/static/public/502/online+retail+ii.zip"
cd data/raw && unzip -o online_retail_ii.zip
```

Run a Python notebook by opening it in Jupyter/VS Code (`notebooks/python/`). Run an R
script from the project root, not from inside `notebooks/r/`:
```bash
Rscript notebooks/r/02_statistical_inference.R
```

The consultancy report is assembled from `docs/*.md` (one file per task, plus `report_front.md`)
and printed to PDF with headless Chrome. Edit the Markdown, never the generated output:
```bash
.venv/bin/python reports/build_report.py     # -> reports/final_report.html and .pdf
```
The section order lives in `SECTIONS` in that script. Numbers in `docs/` are copied from
notebook/script outputs, so re-check them whenever an analysis is rerun.

There is no test suite or linter — this is an analysis project.
`notebooks/python/00_data_cleaning.ipynb` must be run first; every other script/notebook
(Python or R) reads its output from `data/processed/`.

## Architecture

**Data flow:** `data/raw/online_retail_II.xlsx` → `src/cleaning.py::clean_invoice_lines`
→ **extra inline cleaning in cell 8 of `00_data_cleaning.ipynb`** → `src/features.py::build_customer_table`
→ `data/processed/invoice_lines_clean.csv` + `customer_table.csv` → read by every other
notebook *and* by the R scripts. The R scripts do not re-clean. They `read.csv()` the
Python outputs and `source("R/features.R")` only for `CUTOFF_DATE`. `R/cleaning.R` is a
port that no current script calls.

**The cleaning rules live in two places.** `src/cleaning.py` does the base pass
(price ≤ 0, a short `NON_PRODUCT_CODES` set, exact duplicates). Notebook 00 cell 8 then
removes a longer non-product set (adds `S`, `B`, `ADJUST`, `CRUK`, `TEST001/002`,
`GIFT_*` vouchers) and the mistaken-order invoices (`581483`/`C581484`, `541431`/`C541433`,
`556444`). The processed CSVs reflect both passes. `R/cleaning.R`'s list is a third,
different set. If you change a cleaning rule, change it in notebook 00 (and `src/` if it
belongs in the base pass), then re-run 00 so every downstream consumer picks it up.

**Data files are committed despite `.gitignore`.** The raw xlsx/zip and both processed CSVs
were added before the ignore rules and are still tracked. Don't stage changes to them
unless the team means to update the shared data. Opening the xlsx in Excel and re-saving
it shows up as a modification.

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
Don't move analysis code into `src/`/`R/` unless it's genuinely reused. If you change
`CUTOFF_DATE`/`TARGET_WINDOW_DAYS` or feature logic, change both `src/features.py` and
`R/features.R`.

**Path depth matters for `notebooks/python/*.ipynb`:** they're two levels below the
project root, so `sys.path.append('../..')` and `../../data/...` (not `../data/...`).
`notebooks/r/*.R` scripts are written to be run from the project root, so they use plain
`data/...` / `reports/...` paths, not `../`.

**CSV type gotchas when a Python-written CSV is read by an R script:** pandas writes
booleans as the literal strings `"True"`/`"False"`, which R reads as character, not
logical — `IsCancellation` needs `as.logical()` after `read.csv()` in any R script that
reads `invoice_lines_clean.csv`.

**Notebook-to-task mapping** (see README.md for the full table): `00_data_cleaning` builds
the processed tables; `01`, `03`–`05` (Python) map to Tasks 3, 5, 7, 8 (`03b` holds Task 5's formal model selection: rolling-origin
development periods, Brier selection rule, retrospective temporal evaluation; `03` is the exploratory random-split
analysis); `07` (Python) holds the Task 6 power analysis; `02`, `06` (R) map
to Tasks 4, 9. Tasks 1, 2, 6, 10, 11, 12 are written deliverables in `docs/`. **Task 11 (expert
validation) has not happened yet** — `docs/task11_expert_validation.md` is a placeholder;
never write expert feedback into it or into Task 12 without real evidence in `docs/evidence/`.
Margin (30%), offer cost (£10) and uplift (10%) in notebooks 03/05 are labelled placeholders;
profit on realised `FutureSpend` is retrospective only and must not be presented as deployable.

**Team ownership** (also in README.md): different people own different notebooks/tasks, so
avoid restructuring `src/`/`R/` function signatures without checking what other
notebooks/scripts call.
