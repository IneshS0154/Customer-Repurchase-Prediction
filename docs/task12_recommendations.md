# Task 12 -- Final Consultancy Recommendations

*Owner: all members. Every recommendation cites the statistical result it rests on (with the notebook or script it came
from), at least one published source, and a column for industry expert feedback.*

> **Expert feedback is pending.** No expert has been consulted yet (Task 11 is incomplete), so the "Expert feedback" column
> reads *Pending* throughout. These recommendations are **provisional** until that column is filled in, and several of
> the quantities below (margin, offer cost, uplift) are placeholders that the consultation is meant to replace.

## 12.1 Summary for senior management

1. **Do not fund blanket retention discounts yet.** The models reliably identify who is likely to buy again, but not
   whether an offer changes that. Depending on the offer's unknown effect, the profitable contact share ranges from 4% to
   82% of customers.
2. **Run a four-month randomised pilot first**, launched outside the Q4 peak, with repurchase as the success measure
   and pre-agreed stop/go rules.
3. **Build the weekly early-warning system in stages.** Start by scoring customers and publishing the dashboard without
   running campaigns, and only run campaigns once the pilot has measured the offer's effect.
4. **Protect the top accounts.** The top 10% of customers bring in 63% of revenue. Give them service contact, not
   discounts, because 81% of the most loyal tier buys again anyway.
5. **Plan Q4 from the calendar, not from a forecast model.** Two years of data cannot yet support a reliable seasonal
   forecast.

## 12.2 Key quantities

| Decision parameter | Recommendation | Basis |
|---|---|---|
| Targeting tier for offers | Tier B (at risk, high value): expected spend above the economic threshold. With placeholder values the threshold is expected 90-day spend > £333, which selects about 44% of customers. Recompute it with the pilot's measured uplift | Notebook 03, C3 |
| Campaign size in the pilot | The whole active base (about 5,250 accounts), 50/50 within each block (detects +3.9 points), or 80/20 if a large control is unacceptable (detects +6.1 points) | Notebook 07 |
| Pilot duration | About 4 months: 2 weeks set-up, 90-day outcome window, 2 weeks analysis | Task 6 |
| Pilot timing | Launch outside October–December (e.g. March, read out in June); repeat before Q4 if it succeeds | Notebook 03 A8: base rates differ by season (32% vs 43%) |
| Success threshold | Repurchase uplift ≥ 4 points, 95% CI excluding 0, **and** incremental margin > offer cost using the confirmed margin | Notebook 07; Task 6 break-even of 2.7–6.3 points |
| Stop / go | Go: roll out tiered offers. Refine: effect positive but below threshold, so test a cheaper or better-targeted offer. Stop: CI includes 0, so no blanket offers | Task 6 |
| Review frequency | Score weekly; monitor drift and performance monthly; retrain quarterly; retrain early if AUC < 0.76; recalibrate only with a validated method | Notebooks 03 and 03b |
| Q4 preparation period | Plan stock and staffing in June–July and build from August, because revenue rises from August/September and peaks in November at about 2.2× a typical off-peak month | Notebook 01 |

## 12.3 Recommendations and evidence

Each row lists the recommendation, the statistical evidence behind it, the literature that supports it, and the expert
feedback, which is pending for every row until Task 11 is completed.

### Strategic

| ID | Recommendation | Statistical evidence | Literature | Expert feedback |
|---|---|---|---|---|
| S1 | Do not fund blanket retention discounts until a randomised pilot has measured the offer's effect | The models predict repurchase under historical conditions, not response to an offer. The prospective profit of targeting depends almost entirely on the assumed uplift: contact share 4%–82% and predicted profit £1.4k–£47k across uplift × margin 1%–8% and costs of £5–£20 (notebook 03, C3; notebook 05 gives the same pattern) | Ascarza (2018); Lemmens & Gupta (2020); Devriendt et al. (2021) | *Pending (Task 11)* |
| S2 | Run the RCBD retention pilot in Task 6 (parameters in 12.2) | Repurchase is detectable: +5 points needs 1,558 per arm (CRD) or about 1,193 (RCBD). Spend is not: +10% needs about 55,000 per arm. Recency × frequency blocks explain 23% of repurchase variance (notebook 07) | Kohavi et al. (2009); Montgomery (2017) | *Pending (Task 11)* |
| S3 | Adopt the early-warning system in Task 10, starting with 6 weeks of shadow scoring | Past behaviour ranks customers well and consistently: repeated CV AUC 0.799 (SD 0.015), top-decile lift 2.09, versus 0.762 and 1.77 for the recency rule (notebook 03, A9). Ranking survives out-of-time testing (AUC 0.797–0.800, notebook 03, A8) | Neslin et al. (2006); Tamaddoni Jahromi et al. (2014); Chou et al. (2022) | *Pending (Task 11)* |
| S4 | Treat the top accounts as a managed portfolio: service contact, not discounts | Top 1% = 30.8% of revenue; top 10% = 62.7% (notebook 01). The most loyal recency × frequency tier repurchases at 81% without any offer (notebook 07) | Ascarza (2018); Gattermann-Itschert & Thonemann (2022) | *Pending (Task 11)* |

### Operational

| ID | Recommendation | Statistical evidence | Literature | Expert feedback |
|---|---|---|---|---|
| O1 | Score customers with the LASSO logistic model, selected under a Brier-score rule declared before the results; treat Ridge as an equally defensible alternative | Mean development Brier over four rolling-origin periods: LASSO 0.2026, Ridge 0.2027 (difference +0.00001, 95% CI [−0.00014, +0.00016]); all candidates tie on AUC to two decimals. Locked and evaluated on Sep–Dec 2011: Brier 0.2005 vs 0.2014 for the full logistic (difference −0.0009 [−0.0012, −0.0005]) (notebook 03b) | Tibshirani (1996); Hoerl & Kennard (1970); Van Calster et al. (2019) | *Pending (Task 11)* |
| O2 | Use model scores to rank customers, but do not use the raw probabilities or £ predictions as calibrated budget inputs across seasons until a recalibration method has been validated | Out-of-time AUC stays at 0.79, but the locked model predicts 0.30 against an actual 0.43 (calibration intercept +0.63); development intercepts ranged from −1.76 to +0.40, and a previous-period intercept correction made the evaluation Brier worse (0.2005 → 0.2063) (notebook 03b) | Van Calster et al. (2019) | *Pending (Task 11)* |
| O3 | Prepare for Q4 from the calendar: plan in June–July, build stock and staffing from August | November revenue £1.43M (2010) and £1.45M (2011), about 2.2× the median off-peak month; the rise starts in August/September (notebook 01). Saturday revenue is essentially zero, so weekend staffing can stay minimal (script 06) | Fildes et al. (2022) | *Pending (Task 11)* |
| O4 | Manage international accounts as a separate segment with order-size-aware account management | International customers' typical order value is 1.68× UK's, 95% CI [1.55, 1.82] (Test 1). It is also far more variable: variance ratio 5.24, bootstrap 95% CI [1.94, 13.39] (Test 3) (script 02) | Gattermann-Itschert & Thonemann (2022); Delacre et al. (2017) | *Pending (Task 11)* |
| O5 | Use "acquired in Q4" as one scoring input, not as a stand-alone targeting lever | Q4-acquired customers repurchase 9.6 points more, 95% CI [6.7, 12.5], but Cramér's V is only 0.09, and the effect may be seasonal rhythm rather than acquisition timing (Test 2, script 02) | Lin et al. (2013); Sullivan & Feinn (2012) | *Pending (Task 11)* |

### Risk management

| ID | Recommendation | Statistical evidence | Literature | Expert feedback |
|---|---|---|---|---|
| R1 | Treat all £ profit figures as scenarios. Do not set a retention budget from them | Realised-spend profits (e.g. £9.3k for the top 10%) are retrospective and use information not available at decision time. Prospective figures depend on an assumed uplift (notebook 03, A5 and C3; notebook 05) | Verbeke et al. (2012); Lemmens & Gupta (2020) | *Pending (Task 11)* |
| R2 | State plainly that the system covers only identifiable customers, and increase coverage (e.g. encourage account log-in) | 22.8% of raw lines (13.6% of revenue) have no customer ID. The missingness is not random: a model predicts it with AUC 0.80 (notebooks 00, 01) | Rubin (1976); Little (1988) | *Pending (Task 11)* |
| R3 | Use pooled (hierarchical) estimates for thin countries and show them with their uncertainty | 26 of 41 countries have fewer than 10 customers. Pooled estimates are stable across priors (Denmark 52.5%–58.3%), but the between-country spread is uncertain (`sigma_a` 89% interval 0.06–0.99) (notebook 05) | Efron & Morris (1975); Gelman (2006) | *Pending (Task 11)* |
| R4 | Do not deploy a revenue-forecasting model yet; use last year's pattern plus a buffer | With two seasonal cycles, auto.arima cannot fit a seasonal model, and its held-out RMSE (£135k) is worse than a naive forecast (£109k) (script 06) | Hyndman & Khandakar (2008); Makridakis et al. (2022) | *Pending (Task 11)* |
| R5 | Monitor model drift monthly and keep the recency rule running as a benchmark | Base rates ranged from 32% to 58% across the cutoffs tested; the ranking held but calibration did not (notebook 03, A8) | Neslin et al. (2006) | *Pending (Task 11)* |

### Ethical

| ID | Recommendation | Statistical evidence | Literature | Expert feedback |
|---|---|---|---|---|
| E1 | Make the targeting of better prices a documented policy, and report offer rates by country and customer size each quarter | Value-based targeting concentrates offers: mean 90-day spend ranges from £74 to £1,732 across recency × frequency tiers (notebook 07), so small customers would systematically receive fewer offers | *No source in the current review; to be added* | *Pending (Task 11)* |
| E2 | Limit experiment control periods to 90 days, use the same voucher terms for all recipients, and do not re-assign the same customers to control repeatedly | Pilot design (Task 6) | Kohavi et al. (2009) | *Pending (Task 11)* |
| E3 | Confirm the lawful basis for profiling, keep data use to order behaviour and country, and honour objections to marketing profiling | The models need no personal characteristics: all nine features are behavioural or geographic (notebook 03) | *No source in the current review; to be added (e.g. the UK ICO's guidance on profiling for direct marketing)* | *Pending (Task 11)* |

### Future research

| ID | Recommendation | Statistical evidence | Literature | Expert feedback |
|---|---|---|---|---|
| F1 | Once pilot data exist, build uplift models that predict who responds to an offer, not who repurchases | The current models answer the wrong question for targeting (S1) | Devriendt et al. (2021) | *Pending (Task 11)* |
| F2 | Add probabilistic "buy till you die" predictions as features, and test season-aware calibration | The selected expected-spend system under-predicts the Q4 level (mean £294 vs £530) and the probability level shifts by season (notebook 03b) | Fader et al. (2005b); Chou et al. (2022) | *Pending (Task 11)* |
| F3 | Collect at least 3–4 years of weekly history before relying on seasonal forecasts | Two cycles give a near-perfect but meaningless seasonal fit and conflicting stationarity tests (script 06) | Hyndman & Khandakar (2008); Fildes et al. (2022) | *Pending (Task 11)* |
| F4 | Explore product-theme segments (binary customer × product SVD) for product-specific offers | The themes are interpretable (e.g. home décor vs children's items). They add AUC +0.0057, 95% CI [+0.0002, +0.0111]: small for prediction, more useful for segmentation (notebook 04) | Jolliffe & Cadima (2016) | *Pending (Task 11)* |

## 12.4 What these recommendations do not claim

* No recommendation claims that offers **cause** repurchase. That is exactly what the pilot is for.
* No £ profit figure in this report is guaranteed or deployable.
* Customer-level conclusions apply only to account-holding customers with a recorded ID.
* Every recommendation above is provisional until the expert-feedback column is completed (Task 11).

## References (Task 12)

All sources are listed in full in the Task 2 references (`docs/task1_task2_industry_and_research.md`, section 2.9), except
Montgomery (2017), which is listed under Task 6.
