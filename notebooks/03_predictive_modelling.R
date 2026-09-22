# 03 - Predictive Statistical Modelling (Task 5)

# Brief section 6. Repurchase (binary): logistic regression baseline, then
# stepwise vs LASSO vs elastic net logistic regression. Future spend (continuous):
# linear regression on log spend vs Gamma GLM with log link.

# Evaluate beyond accuracy: AUC, calibration/Brier score, top-decile lift,
# expected-profit comparison, RMSE/MAE. Check VIF, linearity of the logit,
# residuals, and influential observations.

library(dplyr)
library(ggplot2)
library(readr)

clean <- read_csv("../data/processed/invoice_lines_clean.csv")
customers <- read_csv("../data/processed/customer_table.csv")
theme_set(theme_minimal())

library(broom)
library(glmnet)
library(car)     # vif
library(pROC)    # auc

# ---- Train/test split ----

FEATURES <- c("Recency", "Frequency", "Monetary", "TenureDays", "DistinctProducts",
              "AvgBasketValue", "IsUK", "AcquiredInQ4", "CancellationRate")

set.seed(42)
n <- nrow(customers)
train_idx <- sample.int(n, size = round(0.75 * n))
train <- customers[train_idx, ]
test <- customers[-train_idx, ]

# ---- Model 1 — Logistic regression baseline (odds ratios) ----

# TODO: glm(Repurchase ~ ..., data = train, family = binomial) for interpretable coefficients
# TODO: broom::tidy(model, exponentiate = TRUE, conf.int = TRUE) for odds ratios

# ---- Model 2 — Stepwise vs LASSO vs Elastic Net logistic regression ----

# TODO: step(glm(...), direction = "both") for stepwise
# TODO: glmnet::cv.glmnet(x, y, family = "binomial", alpha = 1) for LASSO (alpha=1) / elastic net (0<alpha<1)
# TODO: compare coefficient stability vs baseline; discuss correlated RFM features

# ---- Assumption checks ----

# TODO: car::vif(model)
# TODO: Box-Tidwell test for linearity of the logit
# TODO: influence/leverage diagnostics (cooks.distance())

# ---- Evaluation beyond accuracy ----

# TODO: pROC::roc(), calibration curve, Brier score
# TODO: top-decile lift
# TODO: expected-profit comparison across thresholds/models

# ---- Future spend — Linear regression (log) vs Gamma GLM ----

# TODO: lm(log1p(FutureSpend) ~ ..., data = ...)
# TODO: glm(FutureSpend ~ ..., data = ..., family = Gamma(link = "log"))
# TODO: RMSE / MAE on held-out spend

# ---- Recommendation ----

# _Expected: penalised (LASSO/elastic net) logistic regression — interpretability, stability, calibration over raw AUC._
