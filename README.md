# IT3081 – Statistical Modelling: Group Assignment

**Registered topic:** Online Retail Transaction Analysis
**Consultancy title:** Customer Repurchase and Value Prediction for a UK Online Retailer
**Dataset:** [Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii) (UCI ML Repository)

**Client scenario:** A UK-based online gift wholesaler wants to know which customers will
return, how much those customers are worth, and where it should spend its retention budget.

Full brief: [SM-Project.pdf](SM-Project.pdf)

**Stack: plain R scripts.** An earlier Python version of this project is kept for reference
in [legacy-python/](legacy-python/) but is not part of the submission.

## Project design

- **Cutoff date:** 9 September 2011 — features are built only from transactions before
  this date, targets from the 90 days after it (prevents data leakage).
- **Targets:** `Repurchase` (binary, classification) and `FutureSpend` (continuous, regression).
- **Features:** RFM (Recency, Frequency, Monetary), tenure, avg basket value, distinct
  products purchased, cancellation rate, country (UK vs international), Q4-acquisition flag.

## Repo structure

```
data/
  raw/            Original UCI files (gitignored — see Setup)
  processed/      Cleaned invoice-line data and the customer-level model table
notebooks/        One R script per task, run in order
R/                Reusable functions (cleaning.R, features.R)
reports/
  figures/        Exported charts for the write-up
references/       Literature review comparison table, citation list
legacy-python/    Earlier Python version (not part of the submission)
```

## Notebooks (map to tasks in the brief)

| Notebook | Task |
|---|---|
| `00_data_cleaning.R` | Load raw data, fix quality issues, build customer-level table |
| `01_descriptive_analysis.R` | Task 3 — Dataset understanding & descriptive analysis |
| `02_statistical_inference.R` | Task 4 — Hypothesis tests (t-test, chi-square, ANOVA) |
| `03_predictive_modelling.R` | Task 5 — Logistic/LASSO/elastic net, Gamma GLM |
| `04_pca_evaluation.R` | Task 7 — PCA on customer × product matrix |
| `05_bayesian_methods.R` | Task 8 — Naive Bayes, hierarchical regression, BG/NBD |
| `06_time_series.R` | Task 9 — Weekly revenue decomposition |

Tasks 1, 2, 6, 10, 11, 12 (problem framing, literature review, experimental design
write-up, innovation proposal, expert validation, final recommendations) are written
components — see `references/` and the final report, not notebooks.

## Setup

Install R (4.x) and RStudio, then from the project root:

```r
source("packages.R")   # installs every package used across the notebooks, once
```

The raw dataset is downloaded to `data/raw/` (gitignored — too large for git). If missing:

```bash
curl -L -o data/raw/online_retail_ii.zip "https://archive.ics.uci.edu/static/public/502/online+retail+ii.zip"
cd data/raw && unzip -o online_retail_ii.zip
```

Run a script by opening it in RStudio and running it line by line (Ctrl/Cmd+Enter per
line, or Cmd+Shift+Enter / Ctrl+Shift+Enter to run the whole file), or from a terminal
with `Rscript notebooks/00_data_cleaning.R`. Run `00_data_cleaning.R` first — it creates
the files in `data/processed/` that every other script reads.

## Team

| Member | Student ID | Branch | Notebooks | Tasks |
|---|---|---|---|---|
| A | IT24102584 | `a-data-eda` | `00_data_cleaning`, `01_descriptive_analysis` | 3 |
| B | IT24103124 | `b-inference-pca` | `02_statistical_inference`, `04_pca_evaluation` | 4, 6, 7 |
| C | IT24102616 | `c-modelling-bayes` | `03_predictive_modelling`, `05_bayesian_methods` | 5, 8 |
| D | IT24103989 | `d-timeseries-research` | `06_time_series` (+ written Tasks 1, 2, 10, 11) | 1, 2, 9, 10, 11 |
| All | | `main` | Final recommendations, slides, viva prep | 12 |

`05_bayesian_methods` (C) and the second half of `04_pca_evaluation` (B) depend on the
feature set finalised in `03_predictive_modelling`, so start those after C's notebook is merged.
