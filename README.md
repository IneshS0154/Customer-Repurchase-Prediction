# IT3081 – Statistical Modelling: Group Assignment

**Registered topic:** Online Retail Transaction Analysis
**Consultancy title:** Customer Repurchase and Value Prediction for a UK Online Retailer
**Dataset:** [Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii) (UCI ML Repository)

**Client scenario:** A UK-based online gift wholesaler wants to know which customers will
return, how much those customers are worth, and where it should spend its retention budget.

Full brief: [SM-Project.pdf](SM-Project.pdf)

**Stack: hybrid Python + R**, split by task (see table below), not a wholesale choice of
one language. `legacy-python/` and the `_legacy` notebooks keep the original all-Python
versions of Tasks 4 and 9 for reference; they are not part of the submission.

## Project design

- **Cutoff date:** 9 September 2011 — features are built only from transactions before
  this date, targets from the 90 days after it (prevents data leakage).
- **Targets:** `Repurchase` (binary, classification) and `FutureSpend` (continuous, regression).
- **Features:** RFM (Recency, Frequency, Monetary), tenure, avg basket value, distinct
  products purchased, cancellation rate, country (UK vs international), Q4-acquisition flag.

## Repo structure

```
data/
  raw/              Original UCI files (gitignored — see Setup)
  processed/        Cleaned invoice-line data and the customer-level model table
notebooks/
  python/           Tasks 3, 5, 7, 8 (Jupyter notebooks)
  r/                Tasks 4, 9 (plain R scripts)
src/                Python helpers: cleaning.py, features.py
R/                  R helpers: cleaning.R, features.R (same logic, verified to match)
reports/
  figures/          Exported charts for the write-up (r_*.png = from R scripts)
references/         Literature review comparison table, citation list
docs/               Written deliverables (Task 1/2 write-up, etc.)
legacy-python/       Earlier Python-only version of the whole project (not part of the submission)
```

## Notebooks (map to tasks in the brief)

| Notebook | Language | Task |
|---|---|---|
| `python/00_data_cleaning.ipynb` | Python | Load raw data, fix quality issues, build customer-level table |
| `python/01_descriptive_analysis.ipynb` | Python | Task 3 — Dataset understanding & descriptive analysis |
| `r/02_statistical_inference.R` | **R** | Task 4 — Hypothesis tests (Welch t-test, chi-square, Levene, Welch ANOVA) |
| `python/03_predictive_modelling.ipynb` | Python | Task 5 — Logistic/LASSO/elastic net, Gamma GLM |
| `python/04_pca_evaluation.ipynb` | Python | Task 7 — PCA on customer × product matrix |
| `python/05_bayesian_methods.ipynb` | Python | Task 8 — Naive Bayes, hierarchical regression |
| `r/06_time_series.R` | **R** | Task 9 — Decomposition, stationarity, ARIMA/SARIMA |

Why this split: Tasks 4 and 9 are R's strongest natural fit (`rstatix`/`car`/`effectsize`
for inference, `forecast`/`tseries` for time series), are self-contained, and were low-risk
to rebuild. Tasks 3, 5, 7, 8 stay in Python because they carry real, already-debugged
engineering (VIF/Box-Tidwell/Cook's-distance checks, PyMC's hierarchical model) that isn't
worth re-risking by porting.

Tasks 1, 2, 6, 10, 11, 12 (problem framing, literature review, experimental design
write-up, innovation proposal, expert validation, final recommendations) are written
components — see `references/`, `docs/`, and the final report, not notebooks.

## Setup

**Python:**
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**R** (needs R 4.x; RStudio recommended so "Knit"/rendering has a working pandoc):
```r
source("packages.R")
```

The raw dataset is downloaded to `data/raw/` (gitignored — too large for git). If missing:

```bash
curl -L -o data/raw/online_retail_ii.zip "https://archive.ics.uci.edu/static/public/502/online+retail+ii.zip"
cd data/raw && unzip -o online_retail_ii.zip
```

Run `notebooks/python/00_data_cleaning.ipynb` first — every other script/notebook (both
Python and R) reads its output from `data/processed/`. Run an R script from the project
root, e.g. `Rscript notebooks/r/02_statistical_inference.R` (not from inside `notebooks/r/`).

## Team

| Member | Student ID | Branch | Notebooks | Tasks |
|---|---|---|---|---|
| A | IT24102584 | `a-data-eda` | `python/00_data_cleaning`, `python/01_descriptive_analysis` | 3 |
| B | IT24103124 | `b-inference-pca` | `r/02_statistical_inference`, `python/04_pca_evaluation` | 4, 6, 7 |
| C | IT24102616 | `c-modelling-bayes` | `python/03_predictive_modelling`, `python/05_bayesian_methods` | 5, 8 |
| D | IT24103989 | `d-timeseries-research` | `r/06_time_series` (+ written Tasks 1, 2, 10, 11) | 1, 2, 9, 10, 11 |
| All | | `main` | Final recommendations, slides, viva prep | 12 |
