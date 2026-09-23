# Run once: installs every R package used by R/ and notebooks/r/.
# (Python packages are in requirements.txt, for notebooks/python/.)

install.packages(c(
  # R/cleaning.R, R/features.R (shared helpers)
  "readxl", "dplyr", "stringr", "lubridate",
  # notebooks/r/02_statistical_inference.R (Task 4)
  "car",          # Levene's test, VIF
  "rstatix",      # Welch ANOVA, Games-Howell post-hoc
  "effectsize",   # Cohen's d, Cramer's V, eta-squared (with CIs)
  # notebooks/r/06_time_series.R (Task 9)
  "forecast",     # decompose, auto.arima, forecast
  "tseries"       # adf.test, kpss.test
), repos = "https://cloud.r-project.org")
