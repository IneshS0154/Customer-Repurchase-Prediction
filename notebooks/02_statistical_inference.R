# 02 - Statistical Inference (Task 4)

# Brief section 5. For every test: state H0/H1, justify the test (incl. assumption
# checks), report the statistic/df/p-value, report an effect size, interpret, and
# state the practical implication for management.

library(dplyr)
library(ggplot2)
library(readr)

clean <- read_csv("../data/processed/invoice_lines_clean.csv")
customers <- read_csv("../data/processed/customer_table.csv")
theme_set(theme_minimal())

library(car)         # leveneTest
library(rstatix)     # welch_anova_test, games_howell_test
library(effectsize)  # cohens_d, cramers_v, eta_squared

# ---- Test 1 — Comparison of means ----

# **Question:** Do international customers have a higher average order value than UK customers?
# **Method:** Welch t-test on log order value; Mann-Whitney U as a robustness check.

# TODO: t.test(log(AvgBasketValue) ~ IsUK, data = customers, var.equal = FALSE)
# TODO: wilcox.test(...) as robustness check
# TODO: effectsize::cohens_d(...)

# ---- Test 2 — Comparison of proportions ----

# **Question:** Does the repurchase rate differ for Q4-acquired customers?
# **Method:** Two-proportion z-test or chi-square test.

# TODO: chisq.test(table(customers$AcquiredInQ4, customers$Repurchase))
# TODO: effectsize::cramers_v(...)

# ---- Test 3 — Comparison of variances ----

# **Question:** Is order value more variable for international customers?
# **Method:** Levene / Brown-Forsythe test (F-test too sensitive to non-normality).

# TODO: car::leveneTest(AvgBasketValue ~ factor(IsUK), data = customers, center = median)

# ---- Test 4 — ANOVA ----

# **Question:** Does basket value differ by day of week or RFM segment?
# **Method:** Welch ANOVA with Games-Howell post-hoc; Kruskal-Wallis as a check.

# TODO: build RFM segments (e.g. ntile() quartiles of Recency/Frequency/Monetary)
# TODO: rstatix::welch_anova_test(...) + rstatix::games_howell_test(...)
# TODO: kruskal.test(...) as non-parametric check

# ---- Key points to note in write-up ----

# - Monetary variables are right-skewed — justify log transforms / non-parametric pairing.
# - With thousands of customers, almost everything is significant — effect sizes are essential.
