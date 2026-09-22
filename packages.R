# Run once: installs every package used across the notebooks.
# Individual .Rmd files only need the packages they actually use.

install.packages(c(
  # Data wrangling & IO
  "tidyverse", "readxl", "lubridate", "janitor",
  # Rendering
  "rmarkdown", "knitr",
  # Task 4 - inference
  "car",          # Levene's test
  "rstatix",      # Welch ANOVA, Games-Howell post-hoc, effect sizes
  "effectsize",   # Cohen's d, Cramer's V, eta-squared
  # Task 5 - predictive modelling
  "broom",        # tidy() model summaries, odds ratios
  "glmnet",       # LASSO / elastic net
  "statmod",      # tweedie/gamma GLM helpers
  "pROC",         # AUC, ROC curves
  "car",          # VIF
  # Task 7 - PCA
  "factoextra",   # PCA visualisation
  # Task 8 - Bayesian methods
  "e1071",        # Naive Bayes
  "rstanarm",     # Bayesian hierarchical regression (precompiled Stan models)
  "BTYD",         # BG/NBD probabilistic CLV
  # Task 9 - time series
  "forecast",     # decompose, ARIMA/SARIMA
  "tsibble"
), repos = "https://cloud.r-project.org")
