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
# Research question: do international and UK customers differ in typical
# customer-level average order value?
#
# Outcome: log(AvgBasketValue), AvgBasketValue = Monetary / Frequency.
# H0: mean log(AvgBasketValue) is equal for UK and international customers
# H1: the means differ (two-sided: no pre-registered direction)
#
# Test: Welch t-test on the log scale. Average order value is heavily
# right-skewed (notebook 01); the log makes the groups roughly symmetric, and a
# difference in mean logs back-transforms to a RATIO OF GEOMETRIC MEANS, which
# is the business-readable effect. Welch because the groups are very unequal
# in size and need not have equal variances (Test 3 shows they do not).
# Assumption checks: group sizes and skewness of the log outcome (printed).
# With n = 457 and 4,796 the t-test relies on approximate normality of the
# group MEANS, which holds at these sizes for a near-symmetric log outcome.
# Robustness: Mann-Whitney U on the same outcome (no normality assumption).
# Effect sizes: geometric-mean ratio with 95% CI, and Cohen's d with 95% CI.

skewness <- function(x) mean((x - mean(x))^3) / sd(x)^3

cat("\n=== Test 1: Comparison of means (Welch t-test on log average order value) ===\n")
customers$log_basket <- log(customers$AvgBasketValue)
customers$Group1 <- factor(customers$IsUK, levels = c(0, 1), labels = c("International", "UK"))

print(as.data.frame(customers %>% group_by(Group1) %>%
  summarise(n = n(), geo_mean_gbp = exp(mean(log_basket)), median_gbp = median(AvgBasketValue),
            mean_log = mean(log_basket), sd_log = sd(log_basket), skew_log = skewness(log_basket))),
  digits = 4, row.names = FALSE)

t_res <- t.test(log_basket ~ Group1, data = customers)   # difference = International - UK
cat(sprintf("Welch t(%.1f) = %.2f, p = %s\n", t_res$parameter, t_res$statistic,
            format.pval(t_res$p.value, digits = 3, eps = 0.001)))
gm_ratio <- exp(diff(rev(t_res$estimate)))                # exp(mean_Intl - mean_UK)
cat(sprintf("Geometric-mean ratio (International / UK) = %.2f, 95%% CI [%.2f, %.2f]\n",
            gm_ratio, exp(t_res$conf.int[1]), exp(t_res$conf.int[2])))

d_res <- cohens_d(log_basket ~ Group1, data = customers)
cat(sprintf("Cohen's d = %.2f, 95%% CI [%.2f, %.2f]\n", d_res$Cohens_d, d_res$CI_low, d_res$CI_high))

w_res <- wilcox.test(log_basket ~ Group1, data = customers)
cat(sprintf("Robustness (Mann-Whitney U): W = %.0f, p = %s\n", w_res$statistic,
            format.pval(w_res$p.value, digits = 3, eps = 0.001)))

# ---- Test 2: Comparison of proportions -------------------------------------
# Research question: do customers first acquired in Q4 (Oct-Dec) repurchase in
# the 90 days after the cutoff at a different rate from other customers?
#
# H0: the repurchase proportion is equal for Q4-acquired and other customers
# H1: the proportions differ (two-sided)
#
# Test: chi-square test of independence on the 2x2 table (equivalent to the
# two-proportion z-test), with Yates' continuity correction. Assumptions:
# independent customers (one row each) and all expected counts >= 5 (printed).
# Effect sizes: the absolute difference in repurchase proportions with a 95%
# CI (the business-readable effect), the relative risk and odds ratio with
# 95% CIs, and Cramer's V with a two-sided 95% CI (the default one-sided CI
# runs to 1 and is uninformative).

cat("\n=== Test 2: Comparison of proportions (chi-square / two-proportion test) ===\n")
q4 <- customers$AcquiredInQ4 == 1
x2 <- c(Q4 = sum(customers$Repurchase[q4]), NotQ4 = sum(customers$Repurchase[!q4]))
n2 <- c(Q4 = sum(q4), NotQ4 = sum(!q4))
print(data.frame(group = names(n2), n = n2, repurchased = x2, proportion = round(x2 / n2, 4)),
      row.names = FALSE)

tab2 <- table(customers$AcquiredInQ4, customers$Repurchase)
chi_res <- chisq.test(tab2)
cat(sprintf("Smallest expected count: %.0f (>= 5 required)\n", min(chi_res$expected)))
cat(sprintf("Chi-square(%d) = %.2f, p = %s\n", chi_res$parameter, chi_res$statistic,
            format.pval(chi_res$p.value, digits = 3, eps = 0.001)))

pt_res <- prop.test(x2, n2)   # same statistic; CI for p_Q4 - p_NotQ4
cat(sprintf("Difference in proportions (Q4 - not Q4) = %.3f, 95%% CI [%.3f, %.3f] (percentage points: %.1f [%.1f, %.1f])\n",
            diff(rev(pt_res$estimate)), pt_res$conf.int[1], pt_res$conf.int[2],
            100 * diff(rev(pt_res$estimate)), 100 * pt_res$conf.int[1], 100 * pt_res$conf.int[2]))

p_q4 <- x2[["Q4"]] / n2[["Q4"]]; p_nq <- x2[["NotQ4"]] / n2[["NotQ4"]]
rr <- p_q4 / p_nq
se_log_rr <- sqrt(1 / x2[["Q4"]] - 1 / n2[["Q4"]] + 1 / x2[["NotQ4"]] - 1 / n2[["NotQ4"]])
or <- (p_q4 / (1 - p_q4)) / (p_nq / (1 - p_nq))
se_log_or <- sqrt(1 / x2[["Q4"]] + 1 / (n2[["Q4"]] - x2[["Q4"]]) +
                  1 / x2[["NotQ4"]] + 1 / (n2[["NotQ4"]] - x2[["NotQ4"]]))
cat(sprintf("Relative risk = %.2f, 95%% CI [%.2f, %.2f]; odds ratio = %.2f, 95%% CI [%.2f, %.2f]\n",
            rr, exp(log(rr) - 1.96 * se_log_rr), exp(log(rr) + 1.96 * se_log_rr),
            or, exp(log(or) - 1.96 * se_log_or), exp(log(or) + 1.96 * se_log_or)))

v_res <- cramers_v(tab2, alternative = "two.sided")
cat(sprintf("Cramer's V = %.3f, 95%% CI [%.3f, %.3f]\n", v_res$Cramers_v, v_res$CI_low, v_res$CI_high))

# ---- Test 3: Comparison of variances ---------------------------------------
# Research question: is customer-level average order value more variable for
# international customers than for UK customers?
#
# Outcome: AvgBasketValue = Monetary / Frequency (see R/features.R), i.e. each
# customer's total pre-cutoff spend divided by their number of orders. It is
# the customer-level average order value, not the value of any single order.
#
# H0: the variance of customer-level average order value is equal for UK and
#     international customers
# H1: the variance of customer-level average order value differs between UK
#     and international customers (two-sided; the direction is read from the
#     variance ratio, not tested one-sidedly)
#
# Test: Levene's test centred on the median (the Brown-Forsythe variant).
# Appropriate because (1) average order value is a monetary amount and
# heavily right-skewed (notebook 01), (2) the groups are very unequal in size
# (about 10 UK customers per international customer), and (3) centring on
# the median makes the test robust to non-normality and outliers, whereas the
# classical F-test of variances is highly sensitive to both.
#
# Magnitude: variance ratio (International / UK) with a bootstrap 95% CI.

cat("\n=== Test 3: Comparison of variances (Brown-Forsythe / median-centred Levene) ===\n")
cat("Outcome: customer-level average order value (AvgBasketValue = Monetary / Frequency)\n\n")
customers$IsUK_f <- factor(customers$IsUK, labels = c("International", "UK"))

test3_desc <- customers %>% group_by(Group = IsUK_f) %>%
  summarise(n = n(),
            mean_avg_order_value = mean(AvgBasketValue),
            sd = sd(AvgBasketValue),
            variance = var(AvgBasketValue))
cat("Customer-level average order value (GBP) by group:\n")
print(as.data.frame(test3_desc), digits = 6, row.names = FALSE)

lev_res <- leveneTest(AvgBasketValue ~ IsUK_f, data = customers, center = median)
print(lev_res)
cat(sprintf("Brown-Forsythe: F(%d, %d) = %.2f, p = %s\n",
            lev_res$Df[1], lev_res$Df[2], lev_res$`F value`[1],
            format.pval(lev_res$`Pr(>F)`[1], digits = 3, eps = 0.001)))

intl_vals <- customers$AvgBasketValue[customers$IsUK_f == "International"]
uk_vals <- customers$AvgBasketValue[customers$IsUK_f == "UK"]
vr_point <- var(intl_vals) / var(uk_vals)
cat(sprintf("Variance ratio (International / UK) = %.2f\n", vr_point))

# Bootstrap 95% CI for the variance ratio. A classical parametric CI (e.g.
# from the F-distribution) assumes normality - the same assumption already
# rejected when choosing Brown-Forsythe over the classical F-test above, so
# using it here for the CI would be inconsistent. Resample each group
# independently with replacement, recompute the ratio, and take percentiles.
set.seed(42)
B <- 5000
boot_ratios <- numeric(B)
for (i in 1:B) {
  intl_bs <- sample(intl_vals, length(intl_vals), replace = TRUE)
  uk_bs <- sample(uk_vals, length(uk_vals), replace = TRUE)
  boot_ratios[i] <- var(intl_bs) / var(uk_bs)
}
vr_ci <- quantile(boot_ratios, c(0.025, 0.975))
cat(sprintf("Bootstrap 95%% CI for the variance ratio (%d resamples): [%.2f, %.2f]\n",
            B, vr_ci[1], vr_ci[2]))

# ---- Test 4: ANOVA ----------------------------------------------------------
# Research question: does customers' spending rate over their first 90 days
# differ across acquisition-year cohorts?
#
# Design history. Version 1 grouped log(Monetary) by Frequency quartile -
# close to circular, because Monetary = Frequency x AvgBasketValue. Version 2
# grouped log(Monetary) by acquisition cohort, but Monetary is a cumulative
# pre-cutoff total, so earlier cohorts had more time to accumulate it
# (tenure: 2009 cohort ~640 days, 2011 cohort ~138 days).
#
# Why not simply Monetary / TenureDays? Checked on the data before choosing:
# 2 customers have TenureDays = 0 and 102 have < 30, so dividing by tenure
# explodes the rate for very recent customers (one 1-day customer comes out
# at GBP 1,462/day), and log(Monetary / TenureDays) is NEGATIVELY correlated
# with log(TenureDays) (r = -0.24): it swaps the old bias (older cohorts
# favoured) for the opposite one, because a recent customer's single first
# order is divided by only a few days.
#
# Outcome used instead: SpendRate90 = spend in the customer's first 90 days
# after their first purchase / 90 (GBP per day). Every customer is measured
# over exactly the same 90-day exposure, so no customer's value depends on
# how long ago they were acquired, and there is no small denominator.
# Eligibility: customers with TenureDays >= 90, i.e. whose full 90-day window
# ends before the cutoff (so no post-cutoff data is used). Customers
# acquired < 90 days before the cutoff cannot be observed for 90 days and are
# excluded - all from the 2011 cohort; the count is printed below.
# Transformation: log(SpendRate90). Every eligible customer's window contains
# their first order, so the rate is strictly positive and log() is defined
# without the +1 offset of log1p (which would distort values in GBP/day).
# The log is used because spend is heavily right-skewed; group differences on
# the log scale back-transform to ratios of geometric means.
#
# H0: mean log(SpendRate90) is equal across acquisition-year cohorts
# H1: at least one cohort's mean log(SpendRate90) differs
#
# Grouping: AcqCohort = calendar year of the first pre-cutoff purchase
# (derivation from TenureDays verified against the invoice lines below).
#
# Test: Welch's one-way ANOVA, because cohort sizes are very unequal and
# spending is heterogeneous across groups (checked with Brown-Forsythe
# below); Welch's F does not assume equal variances. Games-Howell post-hoc
# comparisons (unequal variances and n; adjusted p-values). Kruskal-Wallis on
# the same outcome as a robustness check. Sensitivity analysis:
# log(Monetary) on the same customers, to show what the cumulative measure
# would have concluded.
#
# Effect size: omega-squared with a 95% CI. Omega-squared is less biased
# than eta-squared in the population and is the same variance-explained
# idea. Limitation: it is computed from the classical one-way ANOVA
# decomposition, and its CI assumes equal variances - which Welch's test
# itself does not. Read it as a descriptive magnitude alongside Welch's F.

cat("\n=== Test 4: ANOVA (Welch, first-90-day spending rate by acquisition-year cohort) ===\n")
WINDOW_DAYS <- 90
customers$FirstPurchase <- as.Date(CUTOFF_DATE) - customers$TenureDays
customers$AcqCohort <- factor(format(customers$FirstPurchase, "%Y"))

# First 90 days of purchases per customer, from the cleaned invoice lines
# (same definition as Monetary in R/features.R: non-cancelled, pre-cutoff).
inv_lines <- read.csv("data/processed/invoice_lines_clean.csv")
inv_lines$IsCancellation <- as.logical(inv_lines$IsCancellation)
inv_lines$InvoiceDate <- as.POSIXct(inv_lines$InvoiceDate, tz = "UTC")
purchases <- inv_lines %>%
  filter(!is.na(CustomerID), !IsCancellation, InvoiceDate < CUTOFF_DATE) %>%
  group_by(CustomerID) %>%
  mutate(FirstPurchaseTime = min(InvoiceDate)) %>%
  ungroup()
first90 <- purchases %>%
  filter(InvoiceDate < FirstPurchaseTime + WINDOW_DAYS * 86400) %>%
  group_by(CustomerID) %>%
  summarise(Spend90 = sum(LineRevenue),
            FirstYear = format(first(FirstPurchaseTime), "%Y"), .groups = "drop")
rm(inv_lines, purchases)

customers <- customers %>% left_join(first90, by = "CustomerID")
stopifnot(all(customers$FirstYear == as.character(customers$AcqCohort)))
cat("Cohort check: AcqCohort (from TenureDays) matches first-purchase year in the invoice lines for all",
    nrow(customers), "customers\n")

cat("\nCustomers by cohort, and eligible for a full", WINDOW_DAYS, "day window (TenureDays >=", WINDOW_DAYS, "):\n")
print(customers %>% group_by(AcqCohort) %>%
        summarise(all = n(), eligible = sum(TenureDays >= WINDOW_DAYS),
                  excluded = sum(TenureDays < WINDOW_DAYS), .groups = "drop") %>%
        as.data.frame(), row.names = FALSE)

t4 <- customers %>% filter(TenureDays >= WINDOW_DAYS) %>%
  mutate(SpendRate90 = Spend90 / WINDOW_DAYS,
         log_rate90 = log(SpendRate90),
         log_monetary = log(Monetary))
stopifnot(all(t4$SpendRate90 > 0))

# Descriptive statistics and assumption diagnostics, per cohort.
# skew_log: skewness of log(SpendRate90); outliers_log: |z| > 3 within cohort.
cat("\nSpendRate90 (GBP/day) and log(SpendRate90) by cohort:\n")
print(t4 %>% group_by(AcqCohort) %>%
        summarise(n = n(),
                  mean_rate = mean(SpendRate90), sd_rate = sd(SpendRate90),
                  median_rate = median(SpendRate90),
                  mean_log = mean(log_rate90), sd_log = sd(log_rate90),
                  skew_log = skewness(log_rate90),
                  outliers_log = sum(abs(log_rate90 - mean(log_rate90)) > 3 * sd(log_rate90)),
                  .groups = "drop") %>%
        as.data.frame(), digits = 4, row.names = FALSE)

bf4 <- leveneTest(log_rate90 ~ AcqCohort, data = t4, center = median)
cat(sprintf("Variance check (Brown-Forsythe on log(SpendRate90)): F(%d, %d) = %.2f, p = %s\n",
            bf4$Df[1], bf4$Df[2], bf4$`F value`[1],
            format.pval(bf4$`Pr(>F)`[1], digits = 3, eps = 0.001)))

aov4 <- aov(log_rate90 ~ AcqCohort, data = t4)
png("reports/figures/r_test4_diagnostics.png", width = 1200, height = 500, res = 120)
par(mfrow = c(1, 2))
boxplot(log_rate90 ~ AcqCohort, data = t4, xlab = "Acquisition cohort",
        ylab = "log(first-90-day spend, GBP/day)", main = "Outcome by cohort")
qqnorm(residuals(aov4), main = "Q-Q plot of ANOVA residuals"); qqline(residuals(aov4))
invisible(dev.off())
cat("Diagnostic plots written to reports/figures/r_test4_diagnostics.png\n")

# Primary test
welch_res <- welch_anova_test(t4, log_rate90 ~ AcqCohort)
cat(sprintf("\nWelch ANOVA: F(%.0f, %.1f) = %.2f, p = %s\n",
            welch_res$DFn, welch_res$DFd, welch_res$statistic,
            format.pval(welch_res$p, digits = 3, eps = 0.001)))

omega_res <- omega_squared(aov4, partial = FALSE, ci = 0.95, alternative = "two.sided")
cat(sprintf("Omega-squared = %.3f, 95%% CI [%.3f, %.3f] (%s effect, Field 2013 rules)\n",
            omega_res$Omega2[1], omega_res$CI_low[1], omega_res$CI_high[1],
            interpret_omega_squared(omega_res$Omega2[1], rules = "field2013")))

# Post-hoc: estimates are differences in mean log(SpendRate90);
# exp(estimate) = ratio of geometric-mean spending rates (group2 / group1).
gh_res <- games_howell_test(t4, log_rate90 ~ AcqCohort, conf.level = 0.95)
cat("\nGames-Howell pairwise comparisons (log scale; ratio = exp(estimate), group2 / group1):\n")
print(gh_res %>%
        transmute(group1, group2, estimate = round(estimate, 3),
                  conf.low = round(conf.low, 3), conf.high = round(conf.high, 3),
                  ratio = round(exp(estimate), 2),
                  ratio.low = round(exp(conf.low), 2), ratio.high = round(exp(conf.high), 2),
                  p.adj = format.pval(p.adj, digits = 3, eps = 0.001), p.adj.signif) %>%
        as.data.frame(), row.names = FALSE)

# Robustness check: same outcome, rank-based
kw_res <- kruskal.test(log_rate90 ~ AcqCohort, data = t4)
kw_eff <- kruskal_effsize(t4, log_rate90 ~ AcqCohort)
cat(sprintf("\nRobustness (Kruskal-Wallis): chi-sq(%d) = %.2f, p = %s, eta-squared[H] = %.3f (%s)\n",
            kw_res$parameter, kw_res$statistic,
            format.pval(kw_res$p.value, digits = 3, eps = 0.001),
            kw_eff$effsize, kw_eff$magnitude))

# Sensitivity: cumulative log(Monetary) on the same customers. Subject to the
# exposure confounding described above - shown only for comparison.
welch_mon <- welch_anova_test(t4, log_monetary ~ AcqCohort)
omega_mon <- omega_squared(aov(log_monetary ~ AcqCohort, data = t4), partial = FALSE,
                           ci = 0.95, alternative = "two.sided")
cat(sprintf("Sensitivity (cumulative log(Monetary), exposure-confounded): Welch F(%.0f, %.1f) = %.2f, p = %s, omega-squared = %.3f [%.3f, %.3f]\n",
            welch_mon$DFn, welch_mon$DFd, welch_mon$statistic,
            format.pval(welch_mon$p, digits = 3, eps = 0.001),
            omega_mon$Omega2[1], omega_mon$CI_low[1], omega_mon$CI_high[1]))

# ---- Multiple comparisons note ----------------------------------------------
# Four pre-planned tests answering four different client questions - not a
# search through many comparisons, so Bonferroni across the four headline
# tests is not applied (threshold would be 0.05/4 = 0.0125). Within Test 4's
# three pairwise comparisons, Games-Howell already controls the family-wise
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
# Test 1 (means): international customers have a higher typical average
# order value. Geometric means: International GBP 432 (n = 457), UK GBP 257
# (n = 4,796). Welch t(515.8) = 12.41, p < .001. Geometric-mean ratio
# (International / UK) = 1.68, 95% CI [1.55, 1.82]: a typical international
# customer's average order is about 55-82% larger. Cohen's d = 0.72 [0.62,
# 0.81], medium-to-large. Mann-Whitney agrees (p < .001), so the result does
# not depend on the log transform. Assumptions: the log outcome is close to
# symmetric in both groups (skewness 0.29 and -0.39) and the groups are large.
# Practical implication: pricing and account-management strategy should not
# assume international orders are smaller than UK orders - the opposite holds,
# likely reflecting bulk, freight-consolidated ordering by overseas wholesale
# accounts. Limitation: association only; country is not assigned, and the
# international group mixes about 40 countries with very different sizes.
#
# Test 2 (proportions): Q4-acquired customers repurchase more often (49.8%,
# n = 1,728) than other customers (40.2%, n = 3,525). Chi-square(1) = 43.37,
# p < .001 (smallest expected count 749). Difference = 9.6 percentage points,
# 95% CI [6.7, 12.5]; relative risk 1.24 [1.16, 1.32]; odds ratio 1.48
# [1.32, 1.66]; Cramer's V = 0.09 [0.06, 0.12] - a SMALL association despite
# the tiny p-value, because with 5,253 customers modest differences are easily
# "significant". Practical implication: a Q4-acquired customer is about 10
# points more likely to come back in the next 90 days - worth using as one
# input to targeting, but too weak on its own to justify reallocating budget.
# Limitation: the target window (Sep-Dec 2011) is itself the Christmas season,
# so this may reflect a seasonal buying rhythm (customers first seen in Q4
# buy again in Q4) rather than anything about acquisition timing; the design
# cannot separate the two.
#
# Test 3 (variances): outcome is customer-level average order value
# (Monetary / Frequency). International customers: n = 457, mean GBP 664,
# SD GBP 966, variance 933,840. UK customers: n = 4796, mean GBP 334,
# SD GBP 422, variance 178,201. Brown-Forsythe (median-centred Levene):
# F(1, 5251) = 123.94, p < .001, so H0 of equal variances is rejected.
# Variance ratio (International / UK) = 5.24, bootstrap 95% CI for the
# variance ratio [1.94, 13.39] (5000 resamples). The confidence interval lies
# entirely above 1, providing evidence that international customers have
# greater variability in customer-level average order value than UK
# customers. The interval is wide, so the size of the difference is
# uncertain: 5.24 is a point estimate, not a known multiple - expected given
# the much smaller international group and the skewed outcome.
# Practical implication: international customers show substantially greater
# dispersion in average order value, so a single average-value figure is
# likely to be less representative for international accounts than for UK
# accounts. This suggests segmenting international customers (e.g. by order
# size) or considering differentiated commercial approaches may be worth
# investigating. The test shows a difference in spread only - it does not
# explain why it exists or show that any particular pricing, discount or
# credit policy would change revenue.
#
# Test 4 (ANOVA): outcome is log(SpendRate90), each customer's spend in the
# first 90 days after their first purchase, per day - the same exposure for
# every customer. Eligible customers: 2009 n = 951, 2010 n = 3364, 2011
# n = 636 (302 customers acquired < 90 days before the cutoff excluded, all
# 2011). Median first-90-day spend rate: GBP 6.30/day (2009), 4.29 (2010),
# 3.84 (2011). Variances differ (Brown-Forsythe F(2, 4948) = 23.91,
# p < .001), supporting Welch over classical ANOVA.
#
# Welch F(2, 1343.7) = 45.11, p < .001: H0 is rejected - mean log spending
# rate differs across cohorts. But the effect is SMALL: omega-squared =
# 0.022, 95% CI [0.014, 0.030] - cohort accounts for roughly 2% of the
# variation in log spending rate. Games-Howell: the 2009 cohort's
# geometric-mean spending rate is higher than 2010's (2010 / 2009 ratio 0.69,
# 95% CI [0.62, 0.76], adj. p < .001) and 2011's (ratio 0.63, [0.55, 0.72],
# adj. p < .001); 2010 and 2011 do not differ significantly (ratio 0.92,
# [0.83, 1.02], adj. p = 0.157). Kruskal-Wallis agrees (chi-sq(2) = 91.39,
# p < .001, eta-squared[H] = 0.018, small), so the conclusion does not
# depend on the normality of the log outcome (residual Q-Q plot: roughly
# symmetric, heavier tails than normal - r_test4_diagnostics.png).
#
# Sensitivity - what the cumulative measure would have said: on the same
# customers, log(Monetary) gives Welch F(2, 1411.0) = 317.88 and
# omega-squared = 0.126 [0.109, 0.143], about six times the effect size.
# Most of the cohort difference in cumulative spend is therefore explained
# by older cohorts having had longer to accumulate it, not by a higher
# spending rate. This contrast is the main reason Test 4 was redesigned.
#
# Interpretation: acquisition cohort is associated with a small difference
# in early spending rate, and it is driven by the 2009 group alone. The data
# start on 1 Dec 2009, so the "2009 cohort" is every customer active in
# December 2009 - it includes established accounts acquired before the data
# begin (left-censoring), and its "first 90 days" are only its first 90 days
# in the data. The higher 2009 rate is therefore at least partly
# "already-established customers spend faster", not "customers acquired in
# 2009 are better". Among customers genuinely first seen in the data (2010
# vs 2011) there is no significant difference.
#
# Practical implication: there is no evidence that recently acquired
# customers are spending at a lower rate in their first 90 days than the
# 2010 cohort did, so this test gives no reason to change acquisition
# strategy by period. Established accounts spend faster, which supports
# prioritising their retention (links to Task 5), but the effect is small
# and cohort alone is a weak basis for segmentation.
#
# Limitations: (1) tenure normalisation reduces the mechanical advantage of
# earlier cohorts caused by having more time to accumulate spending, but it
# does not eliminate all cohort-related confounding; (2) the 2009 cohort is
# left-censored (see above); (3) the 2011 cohort is right-censored - only
# customers acquired Jan to early Jun 2011 can be observed for 90 days, so
# it is not representative of the whole 2011 intake; (4) seasonality: the
# 90-day windows fall in different seasons (e.g. December 2009 starts in the
# pre-Christmas period), and acquisition month is not controlled; (5) the
# data are observational - cohort is associated with spending rate, not a
# cause of it; (6) omega-squared and its CI come from the classical ANOVA
# decomposition, which assumes equal variances.
#
# Recommendation: report the effect size (Cohen's d, Cramer's V, variance
# ratio, omega-squared) alongside every p-value
# in the final write-up - Test 2 is the clearest example in this project of
# where statistical and practical significance diverge.
