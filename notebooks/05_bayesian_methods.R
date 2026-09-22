# 05 - Critical Evaluation of Bayesian Methods (Task 8)

# Brief section 9. Naive Bayes (independence assumption violated by correlated RFM
# vars, but rankings may still be reasonable), Bayesian hierarchical regression for
# small-sample countries (partial pooling), and a Bayesian decision rule for when to
# send a retention offer. Mention BG/NBD (Fader, Hardie & Lee, 2005) as the industry
# standard probabilistic CLV approach.

library(dplyr)
library(ggplot2)
library(readr)

clean <- read_csv("../data/processed/invoice_lines_clean.csv")
customers <- read_csv("../data/processed/customer_table.csv")
theme_set(theme_minimal())

library(e1071)     # naiveBayes
library(rstanarm)  # stan_glmer - precompiled Bayesian hierarchical models

# ---- Naive Bayes classifier for repurchase ----

# TODO: e1071::naiveBayes(factor(Repurchase) ~ ..., data = train)
# TODO: compare AUC/calibration to Task 5 logistic model
# TODO: discuss independence assumption violation given correlated RFM features

# ---- Bayesian hierarchical regression across countries (partial pooling) ----

# TODO: table(customers$Country) -- show many countries have few customers
# TODO: rstanarm::stan_glmer(Repurchase ~ ... + (1 | Country), data = customers, family = binomial)
# TODO: compare partial-pooled vs no-pooling per-country estimates

# ---- Bayesian decision rule ----

# Send an offer only when `P(repurchase | offer) * margin > cost of offer`.

# TODO: apply the rule using calibrated probabilities from Task 5/here, assumed margin & offer cost
# TODO: sensitivity of the decision to the assumed margin/cost

# ---- Limitations to discuss ----

# - Choice of priors is contestable
# - MCMC computational cost
# - Harder to explain to non-technical stakeholders
