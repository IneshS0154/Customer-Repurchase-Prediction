# Task 6 -- Critical Evaluation of Experimental Design

*Owner: Member B. Numbers come from `notebooks/python/07_experimental_design.ipynb` (sample size, power and blocking) and
from notebooks 03 and 05 where stated. Re-check them if notebook 00 or `src/` changes.*

## 6.1 Why an experiment is needed

Every model in this project predicts **who will repurchase without intervention**. None of them measures **what a
retention offer changes**. The difference matters commercially:

* The repurchase models (Task 5) rank customers well (repeated cross-validation AUC 0.799 ± 0.015; top-decile lift 2.09),
  but the customers they rank highest are mostly those who were going to buy anyway. The top recency-by-frequency tier
  repurchases at 81% with no offer at all (notebook 07).
* The profit calculations in notebooks 03 and 05 depend on an **assumed** uplift. Across plausible values of uplift
  × margin, the recommended contact share ranges from 4% to 82%, and predicted profit from £0.6k to £46k (notebook 03, C3).
  The data cannot narrow this range. Customers were never randomly offered anything, so the offer's effect is not
  identified.
* The literature makes the same point. The highest-risk customers are not necessarily the ones an intervention helps
  (Ascarza, 2018), and retention profit comes from the incremental effect of the offer, not from the churn probability
  (Lemmens & Gupta, 2020; Devriendt et al., 2021). Randomised controlled experiments are the standard way to establish
  that effect (Kohavi et al., 2009).

An experiment is therefore not optional polish. It is the only way to turn the Task 5 ranking into a defensible budget.
The consultancy is not required to run one (brief, Task 6). This section evaluates which design the retailer should use.

## 6.2 The two designs

**Completely Randomised Design (CRD).** Every eligible customer is independently assigned to treatment or control with
the same probability, ignoring any customer characteristic (Montgomery, 2017).

**Randomised Complete Block Design (RCBD).** Customers are first grouped into blocks that are expected to differ in the
outcome. Every treatment appears within every block, and randomisation happens separately inside each block. Differences
between blocks are then removed from the error term (Montgomery, 2017).

Both designs share the same core set-up:

| Element | Specification (both designs) |
|---|---|
| **Experimental unit** | The customer account (`CustomerID`). This is the level at which offers are sent and at which repurchase is recorded. |
| **Treatment arms** | (T) a retention offer, e.g. a £10 voucher on the next order, sent by e-mail. An optional third arm, "contact without discount", would separate the effect of *being contacted* from the effect of *the discount*, but it costs sample size (see 6.4). |
| **Control group** | No contact, business as usual. A concurrent control is essential. The repurchase rate varies strongly by season (32% in the summer 2011 window vs 43% in the Sep–Dec 2011 window, notebook 03 A8), so a before/after comparison would confuse the offer with the season. |
| **Primary outcome** | Repurchase (yes/no) within 90 days of the send date. This is the same definition as the modelling target, so results feed straight back into the models. |
| **Secondary outcomes** | Spend in the 90 days (reported with a confidence interval, not tested as primary; see 6.4); voucher redemption; unsubscribes and complaints. |
| **Analysis** | Difference in repurchase proportions with 95% CI (as in Task 4, Test 2). For the RCBD, a logistic regression with treatment and block effects. The primary outcome, the success threshold and the analysis are fixed **before** the pilot starts. |

### Comparison

| | CRD | RCBD |
|---|---|---|
| **Assignment mechanism** | Simple random assignment of each customer (e.g. a seeded random number per `CustomerID`), with fixed arm proportions | Random assignment separately within each block, with the same arm proportions in every block |
| **Suitable blocking variables** | None used | Recency tier × frequency tier (9 blocks), which are known before the pilot and strongly related to the outcome (repurchase ranges from 14% to 81% across blocks). Alternatives: the Task 5 model-score tier; UK vs international; acquisition quarter (Task 4, Test 2 shows Q4-acquired customers repurchase 9.6 points more) |
| **Advantages** | Simplest to implement, explain and audit. No modelling needed at assignment. Valid inference by construction | Removes between-block variation, so the same power needs about **23% fewer customers** (notebook 07). Guarantees balance on the blocking variables in a small pilot. Gives a treatment effect **per block**, which is exactly what targeting needs (does the offer work better for lapsing customers than for loyal ones?) |
| **Limitations** | Wastes power: the huge variation between loyal and lapsing customers stays in the error term. A small pilot can end up unbalanced by chance | Blocks must be defined before assignment and cannot be changed afterwards. With many blocks, some become small (the old-recency/high-frequency block has only 122 customers). Per-block effects need far more data than the overall effect |
| **Sample size / power** (5-point uplift, 5% two-sided, 80% power) | 1,558 customers per arm | about 1,193 per arm |
| **Seasonality** | Controlled by the concurrent control group, but a pilot run in Q4 measures a Q4 effect only | Same. Calendar time can itself be a blocking factor if sends are staggered over several weeks |
| **Contamination / interference** | Both designs assume one customer's treatment does not affect another's outcome. In a B2B wholesale base that can fail: several buyers at the same shop may hold separate accounts, vouchers can be forwarded, and account managers may treat control accounts differently. Mitigations: single-use codes tied to the account; assignment at the business level where accounts can be linked; keeping sales staff blind to assignment | Same as CRD |
| **Operational feasibility** | High. Needs only a random list and the existing e-mail system | High to moderate. Needs the recency and frequency tiers computed from the order history on the send date, which the Task 10 pipeline would already produce |
| **Ethical considerations** | See 6.5 | See 6.5 |

## 6.3 Which outcome can a pilot realistically detect?

This is the most important practical constraint, and it comes straight from the data (notebook 07).

**Spend cannot be the primary outcome.** 90-day spend has a mean of £530, a standard deviation of £3,148 and a median of £0
(coefficient of variation 5.9). Detecting a 10% rise in mean spend would need about **55,000 customers per arm**, roughly
ten times the entire customer base. Detecting a 20% rise needs about 13,800 per arm. Blocking does not help here, because the
blocks explain only 3.9% of spend variance: it is dominated by a few very large wholesale buyers.

**Repurchase can be the primary outcome:**

| Uplift in repurchase rate | CRD, customers per arm | RCBD, customers per arm (approx.) |
|---|---|---|
| +3 points | 4,314 | 3,303 |
| +5 points | 1,558 | 1,193 |
| +8 points | 611 | 468 |
| +10 points | 391 | 300 |

**What pilots the retailer could actually run can detect** (CRD, 80% power):

| Pilot | Customers in smaller arm | Minimum detectable uplift |
|---|---|---|
| Whole active base, 50/50 | 2,626 | 3.9 points |
| Whole active base, 80% treated / 20% control | 1,050 | 6.1 points |
| Three highest-value blocks only, 50/50 (baseline 69%) | 1,040 | 5.6 points |

**Is that small enough to matter?** Under the placeholder assumptions (30% margin, £10 offer), an extra repurchase is worth
the offer only if the uplift exceeds about **2.7 points** using the mean spend of a repurchaser (£1,223). Using the median
spend (£529) the break-even is about **6.3 points**. Customers nudged back by a voucher are more likely to be small buyers
than large ones, so the realistic break-even lies between the two. A whole-base pilot can therefore detect effects large
enough to be clearly profitable, but not effects near the lower break-even. That is an honest limit of what the data can
support, and it is why the margin and offer cost need to be confirmed with the expert (Task 11).

## 6.4 Implementation challenges

* **Opportunity cost of the control group.** Withholding offers from 20–50% of customers for 90 days means forgoing any
  real effect on them. An 80/20 split reduces that cost but raises the detectable effect from 3.9 to 6.1 points.
* **A third arm is expensive.** Adding "contact without discount" splits the sample three ways (about 1,750 per arm on
  the whole base). That raises the detectable effect for each comparison from 3.9 to 4.8 points, before any correction
  for making two comparisons. It should be added only if separating contact from discount is a priority for management.
* **Timing.** The 90-day outcome window plus about two weeks of set-up means roughly four months from decision to result.
  A pilot started in Q4 would measure the effect of an offer during the Christmas peak, when customers buy anyway. Run the
  first pilot outside October–December (e.g. launch in March, read out in June). If it succeeds, repeat in Q4 before rolling
  out for the peak season.
* **Noncompliance.** Some treated customers will not open the e-mail. The primary analysis should compare arms *as
  assigned* (intention-to-treat), which measures the effect of the policy of sending the offer.
* **Novelty and repeat exposure.** A one-off pilot measures a first-offer effect. Repeated offers can train customers to
  wait for discounts, which a single 90-day pilot cannot detect.

## 6.5 Ethical considerations

* **Fairness of withholding.** The treatment is a discount on optional purchases, not an essential service. Withholding
  it from a randomly chosen control group for 90 days is low-harm, but it should be time-limited and not repeated on the
  same customers indefinitely.
* **Targeting fairness.** Offers targeted by predicted value give better prices to some accounts than others. That is
  common commercial practice, but it should be a deliberate, documented policy, not an accidental by-product of a model.
  Small customers systematically receive fewer offers.
* **Data protection and marketing consent.** The pilot uses existing purchase history and sends marketing e-mails. The
  retailer's data protection lead should confirm the lawful basis for using purchase history to target offers, and the
  marketing-consent rules for e-mailing each type of account, before launch.
* **Transparency.** Voucher terms should be the same for everyone who receives them, and the experiment should not
  mislead customers (e.g. no false scarcity).

## 6.6 Recommendation: a pilot RCBD

| Item | Recommendation |
|---|---|
| Design | RCBD, blocks = recency tier × frequency tier (9 blocks) computed from order history on the send date |
| Arms | Two: £10 offer vs no contact. Add "contact without discount" only if management specifically needs it |
| Allocation | 50/50 within each block, if the retailer can accept withholding the offer from half the base for one quarter; otherwise 80/20, accepting a larger detectable effect (about 6 points) |
| Sample | The whole active base (about 5,250 accounts at current size) |
| Primary outcome | Repurchase within 90 days, analysed as assigned; difference in proportions with 95% CI |
| Timing | Launch outside Q4 (e.g. March), read out after 90 days. Repeat before Q4 if the pilot succeeds |
| Pre-registered success threshold | Uplift ≥ 4 points with the 95% CI excluding 0, **and** incremental margin above the offer cost using the confirmed margin (Task 11) |
| Stop/go | *Go:* threshold met → roll out targeted offers using the per-block effects. *Refine:* effect positive but below threshold → test a cheaper or better-targeted offer. *Stop:* CI includes 0 → do not fund blanket retention offers |

**What the pilot cannot prove.** It measures the average effect of this offer, at this time of year, on this customer base.
It does not validate the predictive models themselves, and a null result means *this* offer did not work, not that
retention activity cannot. The predictive models (Task 5) remain useful for deciding **whom to include** in the pilot and
how to block it. They do not show that offers **cause** repurchase.

## References (Task 6)

Ascarza, E. (2018). Retention futility: Targeting high-risk customers might be ineffective. *Journal of Marketing Research, 55*(1), 80--98. https://doi.org/10.1509/jmr.16.0163

Devriendt, F., Berrevoets, J., & Verbeke, W. (2021). Why you should stop predicting customer churn and start using uplift models. *Information Sciences, 548*, 497--515. https://doi.org/10.1016/j.ins.2019.12.075

Kohavi, R., Longbotham, R., Sommerfield, D., & Henne, R. M. (2009). Controlled experiments on the web: Survey and practical guide. *Data Mining and Knowledge Discovery, 18*(1), 140--181. https://doi.org/10.1007/s10618-008-0114-1

Lemmens, A., & Gupta, S. (2020). Managing churn to maximize profits. *Marketing Science, 39*(5), 956--973. https://doi.org/10.1287/mksc.2020.1229

Montgomery, D. C. (2017). *Design and analysis of experiments* (9th ed.). Wiley. *[New source, not in the Task 2 list; a textbook, not counted towards the peer-reviewed minimum.]*
