# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

IT3081 (Statistical Modelling) university group assignment. Consultancy-framed analysis of
the UCI **Online Retail II** dataset: predict which customers of a UK online gift wholesaler
will repurchase, and how much they'll spend, then turn that into retention recommendations.
Full brief: [SM-Project.pdf](SM-Project.pdf); project design and task breakdown: [README.md](README.md).

## Commands

```bash
# Setup (once)
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

# Re-download the raw dataset if data/raw/ is empty (gitignored, ~45MB)
curl -L -o data/raw/online_retail_ii.zip "https://archive.ics.uci.edu/static/public/502/online+retail+ii.zip"
cd data/raw && unzip -o online_retail_ii.zip

# Run notebooks
source .venv/bin/activate
jupyter notebook notebooks/
```

There is no test suite, linter, or build step — this is an analysis project. `notebooks/00_data_cleaning.ipynb`
must be run first; every other notebook reads its output from `data/processed/`.

## Architecture

**Data flow:** `data/raw/` (raw UCI xlsx, gitignored) → `src/cleaning.py` (line-level quality
fixes) → `src/features.py` (aggregation to one row per customer) → `data/processed/*.csv`
(gitignored) → consumed independently by each `notebooks/0N_*.ipynb`.

**The cutoff-date design is the central mechanic of the whole project** (`src/features.py`):
`CUTOFF_DATE = 2011-09-09`. Every customer-level feature (RFM, tenure, basket value,
cancellation rate, etc.) is computed only from transactions *before* this date; the two
prediction targets (`Repurchase`, `FutureSpend`) are computed only from the 90 days
*after* it. This split exists to prevent data leakage and is something every notebook
and the final write-up must respect — don't join future-window data back into features.

**`src/` holds the only shared logic** (`cleaning.py` loads/cleans raw invoice lines,
`features.py` builds the customer table via `build_customer_table()`). Everything else —
statistics, modelling, plots — lives inline in the notebooks per task, since each notebook
corresponds to one graded task in the brief and should be independently readable/reviewable
by teammates. Don't move notebook analysis code into `src/` unless it's genuinely reused
across notebooks.

**Notebook-to-task mapping** (see README.md for the full table): `00_data_cleaning` builds
the processed tables; `01`–`06` map to brief Tasks 3, 4, 5, 7, 8, 9 respectively. Tasks 1, 2,
6, 10, 11, 12 are written deliverables (problem framing, lit review, experimental design,
innovation proposal, expert interview, final recommendations) with no corresponding notebook
— `references/literature_review.md` is the stub for Task 2's comparison table.

**Team ownership** (also in README.md): different people own different notebooks/tasks, so
avoid restructuring `src/` function signatures without checking what other notebooks call.
