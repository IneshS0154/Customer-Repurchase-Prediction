# Executive Summary

**Client question.** A UK online giftware wholesaler wants to know which customers will buy again, how much they are
worth, and where to spend its retention budget.

**Data.** The public UCI *Online Retail II* dataset: 1,067,371 invoice lines from December 2009 to December 2011.
After cleaning, 1,021,252 lines remain. They are summarised into a table of **5,253 identifiable customers**, with
behaviour measured before 9 September 2011 and outcomes measured in the 90 days after. Customer-level findings apply only
to account-holding customers: 22.8% of raw lines (13.6% of revenue) have no customer ID, and that missingness is not random.

**What we found**

| Area | Key result |
|---|---|
| Customer base (Task 3) | Revenue is highly concentrated: the top 10% of customers bring in 62.7%. Only 43.4% of customers bought again in the next 90 days. Demand peaks in November at about 2.2 times a typical month |
| Statistical inference (Task 4) | International customers' typical order value is 1.68 times UK customers' (95% CI 1.55–1.82) and far more variable. Q4-acquired customers repurchase 9.6 points more often (95% CI 6.7–12.5), a small effect. Early spending rate differs only slightly by acquisition cohort (ω² = 0.022) |
| Prediction (Task 5) | Under a Brier-score rule declared in advance and applied over four rolling-origin periods, LASSO logistic regression is selected (Ridge is statistically indistinguishable). Locked and evaluated on a later period, it ranks customers well (AUC 0.79; top 10% repurchase at 2.1 times the average) and beats a "most recent first" rule, but its probability level is miscalibrated across seasons. Log-OLS is selected for spend |
| Advanced methods (Tasks 7–9) | PCA adds nothing to the customer table. Product-level SVD reveals buying themes but barely improves prediction. Bayesian pooling gives stable estimates for 26 small-country markets. Two years of data are too few for a reliable seasonal forecast: the fitted model lost to a naive one |

**The central caveat.** The models predict who will buy under the conditions seen historically. They cannot tell whether a retention
offer changes that. Depending on the offer's unknown effect, the profitable share of customers to contact ranges from
4% to 82%. No £ figure in this report is a deployable profit forecast.

**What we recommend** (Task 12; provisional until the expert consultation in Task 11 is completed)

1. Do not fund blanket retention discounts yet.
2. Run a four-month randomised pilot (Task 6), launched outside the Q4 peak, with repurchase as the success measure and
   pre-agreed stop/go rules.
3. Build the weekly early-warning system (Task 10) in stages: dashboard first, campaigns only once the pilot has measured
   the offer's effect.
4. Protect the top accounts with service contact rather than discounts.
5. Plan Q4 from the calendar, starting in June–July, not from a forecasting model.

**Status of the deliverables.** Tasks 1–10 and 12 are complete in this report. **Task 11 (industry expert validation) has
not yet been carried out**, so it appears as a consultation plan with empty evidence templates. The expert-feedback column
of every recommendation is marked *Pending*.

# About this report

**Team**

| Member | Student ID | Responsible for |
|---|---|---|
| A | IT24102584 | Task 3: data cleaning and descriptive analysis |
| B | IT24103124 | Tasks 4, 6, 7: statistical inference, experimental design, PCA |
| C | IT24102616 | Tasks 5, 8: predictive modelling, Bayesian methods |
| D | IT24103989 | Tasks 1, 2, 9, 10, 11: problem framing, literature review, time series, innovation proposal, expert validation |
| All | | Task 12: final recommendations |

**Reproducibility.** Every number in this report is produced by code in the project repository: Python notebooks in
`notebooks/python/` (00 data cleaning, 01 descriptive analysis, 03 predictive modelling, 04 PCA, 05 Bayesian methods,
07 experimental-design power analysis) and R scripts in `notebooks/r/` (02 statistical inference, 06 time series).
Notebook 00 must be run first. The data split that prevents leakage (features before 9 September 2011, outcomes after it)
is implemented once, in `src/features.py` and `R/features.R`, and used everywhere.

**Use of generative AI.** *[To be confirmed and completed by the group before submission.]* An AI coding assistant
(Claude, by Anthropic, used through Claude Code) was used to help review and implement parts of the analysis code,
check results for errors, and draft sections of this report. The group reviewed all AI-assisted output, reran every
analysis, and remains responsible for the accuracy and originality of the work, as required by the brief's academic
integrity section.

**Placeholder assumptions.** Margin (30%), offer cost (£10) and offer effect (10% of expected spend) are **assumptions**,
not client data. They are labelled wherever they are used and are to be replaced after the expert consultation.
