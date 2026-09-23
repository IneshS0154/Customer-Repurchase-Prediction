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
cat("Variance ratio (International / UK):",
    round(var_by_group$variance[var_by_group$IsUK_f == "International"] /
          var_by_group$variance[var_by_group$IsUK_f == "UK"], 2), "\n")

# ---- Test 4: ANOVA ----------------------------------------------------------
# H0: mean log(Monetary) is equal across RFM segments (Frequency quartiles)
# H1: at least one segment differs
#
# Welch ANOVA (does not assume equal variances across groups) with
# Games-Howell post-hoc pairwise comparisons. Kruskal-Wallis run alongside as
# a non-parametric check.

cat("\n=== Test 4: ANOVA (Welch, RFM segments by Frequency quartile) ===\n")
customers$FreqSegment <- ntile(customers$Frequency, 4)
customers$FreqSegment <- factor(customers$FreqSegment,
                                 labels = c("Q1 (lowest)", "Q2", "Q3", "Q4 (highest)"))
customers$log_monetary <- log(customers$Monetary)

welch_res <- welch_anova_test(customers, log_monetary ~ FreqSegment)
print(welch_res)

eta_res <- eta_squared(aov(log_monetary ~ FreqSegment, data = customers))
cat("Eta-squared:", round(eta_res$Eta2[1], 4), "\n")

gh_res <- games_howell_test(customers, log_monetary ~ FreqSegment)
print(gh_res)

kw_res <- kruskal.test(log_monetary ~ FreqSegment, data = customers)
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
cat("Within Test 4's 6 pairwise comparisons, Games-Howell already controls the family-wise error rate.\n")

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
# variable than UK customers' (variance ratio 5.24x): Levene's F(1, 5251) =
# 123.9, p < .001. Practical implication: a single average order value
# figure is much less representative for international accounts - discount
# or credit policies set from the average risk being wrong for many
# international customers in either direction.
#
# Test 4 (ANOVA): Monetary value differs sharply across Frequency quartiles
# (Welch F(3, 2901) = 2452, p < .001, eta-sq = 0.615), and every pairwise
# Games-Howell comparison is significant. This effect size is very large
# because Frequency and Monetary are correlated by construction (more orders
# mechanically tends toward more spend) - the same redundancy flagged by the
# VIF check in notebook 03's predictive_modelling. This test confirms the
# segments are statistically distinguishable, but it should not be read as
# an independent discovery given that known correlation.
#
# Recommendation: report Cramer's V and eta-squared alongside every p-value
# in the final write-up - Test 2 is the clearest example in this project of
# where statistical and practical significance diverge.
