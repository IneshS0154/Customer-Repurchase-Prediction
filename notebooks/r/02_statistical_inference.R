# 02 - Statistical Inference (Task 4)
#
# Brief section 5. Four tests: comparison of means, comparison of proportions,
# comparison of variances, and ANOVA. For each: state H0/H1, justify the test
# (with assumption checks), report the statistic/df/p-value and an effect size
# with a confidence interval, interpret, and state the practical implication.
#
# Run notebook 00 first (creates data/processed/customer_table.csv). This
# script is run from the project root (Rscript notebooks/r/02_statistical_inference.R),
# not from inside notebooks/r/.

library(dplyr)
library(car)         # leveneTest
library(rstatix)     # welch_anova_test, games_howell_test
library(effectsize)  # cohens_d, cramers_v, eta_squared

source("R/features.R")  # for CUTOFF_DATE, used to derive acquisition cohort in Test 4

customers <- read.csv("data/processed/customer_table.csv")
cat("n customers:", nrow(customers), "\n")

ALPHA <- 0.05

# ---- Test 1: Comparison of means -------------------------------------------
# H0: mean log(AvgBasketValue) is equal for UK and international customers
# H1: the means differ
#
# Welch t-test (no assumption of equal variance), on log(AvgBasketValue)
# because basket value is heavily right-skewed (see notebook 01). Two-sided:
# there is no pre-registered direction. Mann-Whitney U is run alongside as a
# robustness check that does not depend on the log transform.

cat("\n=== Test 1: Comparison of means (Welch t-test) ===\n")
customers$log_basket <- log(customers$AvgBasketValue)

t_res <- t.test(log_basket ~ IsUK, data = customers)
print(t_res)

d_res <- cohens_d(log_basket ~ IsUK, data = customers)
cat("Cohen's d:", round(d_res$Cohens_d, 3),
    " 95% CI [", round(d_res$CI_low, 3), ",", round(d_res$CI_high, 3), "]\n")

w_res <- wilcox.test(log_basket ~ IsUK, data = customers, conf.int = TRUE)
cat("Mann-Whitney U robustness check: W =", w_res$statistic, " p =", round(w_res$p.value, 5), "\n")

# ---- Test 2: Comparison of proportions -------------------------------------
# H0: repurchase rate is equal for Q4-acquired and non-Q4-acquired customers
# H1: the proportions differ
#
# Chi-square test of independence (equivalent to a two-proportion z-test for
# a 2x2 table). Cramer's V as the effect size.

cat("\n=== Test 2: Comparison of proportions (chi-square) ===\n")
tab2 <- table(customers$AcquiredInQ4, customers$Repurchase)
print(tab2)
print(prop.table(tab2, margin = 1))

chi_res <- chisq.test(tab2)
print(chi_res)

v_res <- cramers_v(tab2)
cat("Cramer's V:", round(v_res$Cramers_v, 3),
    " 95% CI [", round(v_res$CI_low, 3), ",", round(v_res$CI_high, 3), "]\n")

# ---- Test 3: Comparison of variances ---------------------------------------
# H0: variance of AvgBasketValue is equal for UK and international customers
# H1: the variances differ
#
# Levene's test, median-centred (the Brown-Forsythe variant), which is robust
# to non-normality - the classic F-test of variances is not, and
# AvgBasketValue is heavily skewed.

cat("\n=== Test 3: Comparison of variances (Levene, median-centred) ===\n")
customers$IsUK_f <- factor(customers$IsUK, labels = c("International", "UK"))
lev_res <- leveneTest(AvgBasketValue ~ IsUK_f, data = customers, center = median)
print(lev_res)

var_by_group <- customers %>% group_by(IsUK_f) %>%
  summarise(variance = var(AvgBasketValue), sd = sd(AvgBasketValue), n = n())
print(var_by_group)

vr_point <- var_by_group$variance[var_by_group$IsUK_f == "International"] /
            var_by_group$variance[var_by_group$IsUK_f == "UK"]
cat("Variance ratio (International / UK):", round(vr_point, 2), "\n")

# Bootstrap 95% CI for the variance ratio. A classical parametric CI (e.g.
# from the F-distribution) assumes normality - the same assumption already
# rejected when choosing Brown-Forsythe over the classical F-test above, so
# using it here for the CI would be inconsistent. Resample each group
# independently with replacement, recompute the ratio, and take percentiles.
set.seed(42)
intl_vals <- customers$AvgBasketValue[customers$IsUK_f == "International"]
uk_vals <- customers$AvgBasketValue[customers$IsUK_f == "UK"]
B <- 5000
boot_ratios <- numeric(B)
for (i in 1:B) {
  intl_bs <- sample(intl_vals, length(intl_vals), replace = TRUE)
  uk_bs <- sample(uk_vals, length(uk_vals), replace = TRUE)
  boot_ratios[i] <- var(intl_bs) / var(uk_bs)
}
vr_ci <- quantile(boot_ratios, c(0.025, 0.975))
cat("Bootstrap 95% CI for variance ratio (", B, "resamples):",
    round(vr_ci[1], 2), "to", round(vr_ci[2], 2), "\n")

# ---- Test 4: ANOVA ----------------------------------------------------------
# H0: mean log(Monetary) is equal across acquisition-year cohorts
# H1: at least one cohort differs
#
# Originally grouped by Frequency quartile, but Monetary = Frequency x
# AvgBasketValue by construction (see src/features.R / R/features.R), so
# "does Monetary differ by Frequency quartile" is close to tautological -
# of course customers who order more spend more, almost by definition, and
# the resulting effect size mixes a real business signal with a mechanical
# one. Acquisition cohort (the year the customer's first purchase falls in)
# is independent of how Monetary is computed and answers a genuinely
# separate business question: does historical customer value differ by
# when the customer was acquired? That is directly useful for marketing
# (e.g. "are recently-acquired customers worth less than older cohorts?").
#
# Welch ANOVA (does not assume equal variances across groups) with
# Games-Howell post-hoc pairwise comparisons. Kruskal-Wallis run alongside as
# a non-parametric check.

cat("\n=== Test 4: ANOVA (Welch, acquisition-year cohort) ===\n")
customers$FirstPurchase <- as.Date(CUTOFF_DATE) - customers$TenureDays
customers$AcqCohort <- factor(format(customers$FirstPurchase, "%Y"))
print(table(customers$AcqCohort))
customers$log_monetary <- log(customers$Monetary)

welch_res <- welch_anova_test(customers, log_monetary ~ AcqCohort)
print(welch_res)

eta_res <- eta_squared(aov(log_monetary ~ AcqCohort, data = customers))
cat("Eta-squared:", round(eta_res$Eta2[1], 4), "\n")

gh_res <- games_howell_test(customers, log_monetary ~ AcqCohort)
print(gh_res)

kw_res <- kruskal.test(log_monetary ~ AcqCohort, data = customers)
cat("Kruskal-Wallis robustness check: chi-sq =", round(kw_res$statistic, 2),
    " df =", kw_res$parameter, " p =", format.pval(kw_res$p.value, digits = 3), "\n")

# ---- Multiple comparisons note ----------------------------------------------
# Four pre-planned tests answering four different client questions - not a
# search through many comparisons, so Bonferroni across the four headline
# tests is not applied (threshold would be 0.05/4 = 0.0125). Within Test 4's
# six pairwise comparisons, Games-Howell already controls the family-wise
# error rate across that one family.
cat("\n=== Multiple comparisons note ===\n")
cat("Four pre-planned tests, four different questions: no Bonferroni across them.\n")
cat("Bonferroni threshold if it were applied:", ALPHA / 4, "\n")
cat("Within Test 4's 3 pairwise comparisons (3 acquisition cohorts), Games-Howell already controls the family-wise error rate.\n")

cat("\nDone.\n")

# ---- Findings and interpretation -------------------------------------------
# Numbers below are from the current data (5,253 customers). Re-check if
# notebook 00 or R/features.R changes.
#
# Test 1 (means): International customers have a HIGHER mean log basket
# value (6.07) than UK customers (5.55): t = 12.41, df = 515.8, p < .001,
# 95% CI for the difference [0.44, 0.60] (on the log scale). Cohen's d =
# 0.72 (medium-large) - the Mann-Whitney check agrees (p < .001), so this
# is not an artefact of the log transform. Practical implication: pricing
# and account-management strategy should not assume international orders
# are smaller than UK orders - if anything the opposite holds here, likely
# reflecting bulk/freight-consolidated ordering by fewer, larger overseas
# wholesale accounts.
#
# Test 2 (proportions): Q4-acquired customers repurchase more often (49.8%)
# than non-Q4-acquired customers (40.2%): chi-sq = 43.4, df = 1, p < .001,
# but Cramer's V = 0.09 - a SMALL effect despite the tiny p-value. With
# 5,253 customers even a modest real difference is easily "significant".
# Practical implication: Q4 acquisition timing is associated with better
# retention, but it is a weak signal on its own - not a strong enough lever
# to justify major spend reallocation by itself.
#
# Test 3 (variances): International customers' basket values are far more
# variable than UK customers' (variance ratio 5.24x, bootstrap 95% CI
# [1.94, 13.39], 5000 resamples): Levene's F(1, 5251) = 123.9, p < .001.
# The CI is wide and entirely above 1, so we can say with confidence the
# true ratio exceeds 1 (international is more variable), but not pin down
# the exact multiple - expected, given the international group is much
# smaller (n = 457) than the UK group (n = 4796) and both are skewed.
# Practical implication: a single average order value figure is much less
# representative for international accounts - discount or credit policies
# set from the average risk being wrong for many international customers
# in either direction, and the width of the CI itself is a reason not to
# over-commit to the specific 5.24x figure in the final report.
#
# Test 4 (ANOVA): originally grouped by Frequency quartile, which produced
# a huge but close-to-meaningless effect size (eta-sq = 0.615) because
# Monetary = Frequency x AvgBasketValue by construction - testing whether
# Monetary differs by Frequency quartile is close to circular. Redone by
# acquisition-year cohort (2009: n=951, 2010: n=3364, 2011: n=938) instead,
# which is independent of how Monetary is computed: Welch F(2, 1843) = 420,
# p < .001, eta-sq = 0.146 - a genuine, moderate effect, not a construction
# artefact. Every pairwise Games-Howell comparison is significant and
# monotonic: log(Monetary) is highest for the 2009 cohort, lower for 2010
# (estimate -1.06, 95% CI [-1.18, -0.94]), lower again for 2011 (-1.70 vs
# 2009; -0.65 vs 2010).
#
# Honest confound to state alongside this: Monetary is a running total, not
# a rate, so an earlier acquisition cohort has simply had more calendar
# time to accumulate spend - the 2011 cohort is also right-censored at the
# 9 Sep 2011 cutoff, with at most ~9 months of history. Part of this effect
# is genuinely "customers acquired in 2009 turned out more valuable" and
# part is mechanically "customers acquired in 2009 have had 21 more months
# to spend than the 2011 cohort" - the two are not separated by this test.
# A tenure-normalised measure (e.g. Monetary / TenureDays, a spend rate)
# would isolate the first from the second and is worth flagging as a
# refinement for the final report rather than presenting this result as a
# clean, unconfounded acquisition-cohort effect.
#
# Recommendation: report Cramer's V and eta-squared alongside every p-value
# in the final write-up - Test 2 is the clearest example in this project of
# where statistical and practical significance diverge.
