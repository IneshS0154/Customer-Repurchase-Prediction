# IT3081 – Statistical Modelling: Group Assignment

**Registered topic:** Online Retail Transaction Analysis
**Consultancy title:** Customer Repurchase and Value Prediction for a UK Online Retailer
**Dataset:** [Online Retail II](https://archive.ics.uci.edu/dataset/502/online+retail+ii) (UCI ML Repository)

**Client scenario:** A UK-based online gift wholesaler wants to know which customers will
return, how much those customers are worth, and where it should spend its retention budget.

Full brief: [SM-Project.pdf](SM-Project.pdf)

## Project design

- **Cutoff date:** 9 September 2011 — features are built only from transactions before
  this date, targets from the 90 days after it (prevents data leakage).
- **Targets:** `repurchase` (binary, classification) and `future_spend` (continuous, regression).
- **Features:** RFM (Recency, Frequency, Monetary), tenure, avg basket value, distinct
  products purchased, cancellation rate, country (UK vs international), Q4-acquisition flag.

## Repo structure

```
data/
  raw/            Original UCI files (gitignored — see Setup)
  processed/      Cleaned invoice-line data and the customer-level model table
notebooks/        One notebook per task (01-09), run in order
src/              Reusable functions (cleaning, feature engineering, evaluation)
reports/
  figures/        Exported charts for the write-up
references/       Literature review comparison table, citation list
```

## Notebooks (map to tasks in the brief)

| Notebook | Task |
|---|---|
| `00_data_cleaning.ipynb` | Load raw data, fix quality issues, build customer-level table |
| `01_descriptive_analysis.ipynb` | Task 3 — Dataset understanding & descriptive analysis |
| `02_statistical_inference.ipynb` | Task 4 — Hypothesis tests (t-test, chi-square, ANOVA) |
| `03_predictive_modelling.ipynb` | Task 5 — Logistic/LASSO/elastic net, Gamma GLM |
| `04_pca_evaluation.ipynb` | Task 7 — PCA on customer × product matrix |
| `05_bayesian_methods.ipynb` | Task 8 — Naive Bayes, hierarchical regression, BG/NBD |
| `06_time_series.ipynb` | Task 9 — Weekly revenue decomposition |

Tasks 1, 2, 6, 10, 11, 12 (problem framing, literature review, experimental design
write-up, innovation proposal, expert validation, final recommendations) are written
components — see `references/` and the final report, not notebooks.

## Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

The raw dataset is downloaded to `data/raw/online_retail_ii.zip` (excluded from git —
too large / redistributable license concerns). If missing, re-download:

```bash
curl -L -o data/raw/online_retail_ii.zip "https://archive.ics.uci.edu/static/public/502/online+retail+ii.zip"
cd data/raw && unzip -o online_retail_ii.zip
```

## Team

| Member | Responsibilities | Tasks |
|---|---|---|
| A | Data cleaning, feature engineering, descriptive analysis, time series | 3, 9 |
| B | Statistical inference, experimental design | 4, 6 |
| C | Predictive modelling, PCA, Bayesian methods | 5, 7, 8 |
| D | Problem framing, literature review, expert interview, innovation proposal | 1, 2, 10, 11 |
| All | Final recommendations, presentation, viva prep | 12 |
