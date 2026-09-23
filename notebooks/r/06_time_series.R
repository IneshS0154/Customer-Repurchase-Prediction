# 06 - Time Series Analysis (Task 9)
#
# Brief section 10. The brief does not require fitting a time series model,
# only a critical discussion (trend, seasonality, forecasting, ARIMA,
# business applications). Since the discussion is much stronger grounded in
# a real result than a purely qualitative one, this script actually runs
# the diagnostic steps (stationarity tests, ACF/PACF, a SARIMA fit) on the
# real weekly revenue series, then discusses what they show.
#
# Run notebook 00 first (creates data/processed/invoice_lines_clean.csv).
# Run from the project root: Rscript notebooks/r/06_time_series.R

library(dplyr)
library(lubridate)
library(forecast)
library(tseries)

clean <- read.csv("data/processed/invoice_lines_clean.csv")
clean$InvoiceDate <- as.POSIXct(clean$InvoiceDate, tz = "UTC")
clean$IsCancellation <- as.logical(clean$IsCancellation)

# ---- Weekly revenue series ---------------------------------------------------
cat("=== Building weekly revenue series ===\n")
sales <- clean %>% filter(!IsCancellation, Quantity > 0)
sales$week <- floor_date(sales$InvoiceDate, "week")

weekly <- sales %>% group_by(week) %>% summarise(Revenue = sum(LineRevenue)) %>% arrange(week)
cat("Weeks:", nrow(weekly), " from", as.character(min(weekly$week)), "to", as.character(max(weekly$week)), "\n")
cat("Note: the final week is partial (data ends 9 Dec 2011 mid-week) - its lower revenue\n")
cat("is a data-boundary artefact, not a real decline. Kept in, because STL needs at\n")
cat("least 2 full 52-week periods (104 weeks) and dropping it falls one week short.\n")

weekly_full <- weekly
weekly_ts <- ts(weekly_full$Revenue, frequency = 52,
                 start = c(year(min(weekly_full$week)), week(min(weekly_full$week))))

png("reports/figures/r_weekly_revenue.png", width = 1000, height = 400)
plot(weekly_ts, main = "Weekly revenue", ylab = "Revenue (GBP)", xlab = "Time")
dev.off()

# ---- Decomposition ------------------------------------------------------------
# Classical additive decomposition, not STL: STL requires strictly more than
# 2 full seasonal periods (>104 weeks here) to estimate a periodic seasonal
# component; this series has exactly 104 weeks - just short of STL's
# requirement, and itself evidence for the "only two seasonal cycles"
# limitation the brief asks to be stated.
cat("\n=== Classical decomposition (additive) ===\n")
decomp <- decompose(weekly_ts, type = "additive")
png("reports/figures/r_decomposition.png", width = 1000, height = 800)
plot(decomp)
dev.off()

resid <- decomp$random
seasonal_strength <- 1 - var(resid, na.rm = TRUE) /
  var(decomp$seasonal + resid, na.rm = TRUE)
trend_strength <- 1 - var(resid, na.rm = TRUE) /
  var(decomp$trend + resid, na.rm = TRUE)
cat("Seasonal strength:", round(seasonal_strength, 3), " (0 = no seasonality, 1 = fully seasonal)\n")
cat("Trend strength:", round(trend_strength, 3), " (0 = no trend, 1 = fully trend-driven)\n")

# ---- Day-of-week pattern -------------------------------------------------------
cat("\n=== Day-of-week revenue ===\n")
sales$Day <- weekdays(sales$InvoiceDate)
day_order <- c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")
day_revenue <- sales %>% group_by(Day) %>% summarise(Revenue = sum(LineRevenue))
day_revenue$Day <- factor(day_revenue$Day, levels = day_order)
day_revenue <- day_revenue %>% arrange(Day)
print(day_revenue)

png("reports/figures/r_day_of_week.png", width = 800, height = 400)
barplot(day_revenue$Revenue, names.arg = day_revenue$Day, main = "Revenue by day of week",
        ylab = "Revenue (GBP)", col = "steelblue")
dev.off()

# ---- Stationarity tests ---------------------------------------------------------
# ADF (H0: series has a unit root / is non-stationary) and KPSS (H0: series
# IS stationary) have opposite null hypotheses - agreement between them is
# stronger evidence than either alone.
cat("\n=== Stationarity tests (on the raw weekly series) ===\n")
adf_res <- adf.test(weekly_ts)
cat("ADF test: statistic =", round(adf_res$statistic, 3), " p =", round(adf_res$p.value, 4), "\n")
kpss_res <- kpss.test(weekly_ts)
cat("KPSS test: statistic =", round(kpss_res$statistic, 3), " p =", round(kpss_res$p.value, 4), "\n")

n_diff <- ndiffs(weekly_ts)
cat("Suggested order of differencing (ndiffs):", n_diff, "\n")

# ---- ACF / PACF -----------------------------------------------------------------
cat("\n=== ACF / PACF ===\n")
png("reports/figures/r_acf_pacf.png", width = 1000, height = 500)
par(mfrow = c(1, 2))
acf(weekly_ts, main = "ACF: weekly revenue")
pacf(weekly_ts, main = "PACF: weekly revenue")
dev.off()

# ---- SARIMA fit and forecast (illustrative - not required by the brief) --------
# Held out: the last 8 weeks, to check the forecast against real data.
cat("\n=== SARIMA fit (illustrative forecast) ===\n")
h <- 8
train_ts <- window(weekly_ts, end = time(weekly_ts)[length(weekly_ts) - h])
test_actual <- tail(weekly_full$Revenue, h)

fit <- auto.arima(train_ts, seasonal = TRUE, stepwise = TRUE, approximation = FALSE)
print(summary(fit))

fc <- forecast(fit, h = h)
png("reports/figures/r_sarima_forecast.png", width = 1000, height = 500)
plot(fc, main = paste0("SARIMA", paste(fit$arma[c(1,6,2)], collapse=","), " forecast vs actual (last ", h, " weeks held out)"))
lines(ts(test_actual, start = time(fc$mean)[1], frequency = 52), col = "red", lwd = 2)
legend("topleft", legend = c("Forecast", "Actual (held out)"), col = c("blue", "red"), lty = 1)
dev.off()

rmse <- sqrt(mean((as.numeric(fc$mean) - test_actual)^2))
mae <- mean(abs(as.numeric(fc$mean) - test_actual))
naive_rmse <- sqrt(mean((rep(tail(train_ts, 1), h) - test_actual)^2))
cat("Held-out RMSE:", round(rmse, 0), " MAE:", round(mae, 0),
    " | naive (repeat last value) RMSE:", round(naive_rmse, 0), "\n")

# ---- Residual diagnostics --------------------------------------------------------
cat("\n=== Ljung-Box test on residuals ===\n")
lb_res <- Box.test(residuals(fit), lag = 10, type = "Ljung-Box", fitdf = length(fit$coef))
cat("Ljung-Box: X-sq =", round(lb_res$statistic, 2), " df =", lb_res$parameter,
    " p =", round(lb_res$p.value, 4), "(p > 0.05 means no significant leftover pattern)\n")

# ---- Findings and discussion --------------------------------------------------
# Numbers below are from the current data (104 weekly points, Nov 2009-Dec
# 2011). Re-check if notebook 00 changes.
#
# Decomposition: both the seasonal and trend strength estimates come out at
# essentially 1.0 (near-zero residual variance). Read literally this says
# "perfectly seasonal, perfectly trending" - but the honest interpretation is
# the opposite: with only 104 weeks and a 52-week period, classical
# decompose() estimates each week-of-year's seasonal value from at most TWO
# observations, so it fits almost exactly by construction. This is not
# evidence of strong real seasonality so much as a direct illustration of
# why two cycles is too little data to estimate a seasonal component with any
# real confidence - the number itself demonstrates the brief's own
# limitation point, rather than just asserting it.
#
# Day-of-week: Saturday revenue is essentially zero (GBP 9,803 vs
# GBP 2.96m-4.01m on weekdays) - about 0.1% of a weekday's revenue, not
# "low", confirming this is a B2B wholesaler with no weekend trading.
# Sunday (GBP 1.79m) sits well below weekday levels too.
#
# Stationarity: the ADF and KPSS results DISAGREE here - ADF (p = 0.61)
# fails to reject a unit root (suggests non-stationary), while KPSS
# (p = 0.091) is borderline but does not reject stationarity at the 5%
# level. This ambiguity is itself the honest finding: revenue has both a
# trend and (per above) an unreliable seasonal estimate, so the series sits
# in a genuinely unclear zone rather than cleanly stationary or not.
# ndiffs() suggests one order of differencing would be needed for a formal
# ARIMA fit.
#
# Forecast: auto.arima() selected a plain, non-seasonal ARIMA(1,0,0) - it
# could not attempt a seasonal (SARIMA) fit at all, because 96 training
# weeks against a 52-week period is under two full seasonal cycles. This is
# a second, independent piece of evidence for the same limitation. On the
# 8 held-out weeks, this model's RMSE (GBP 135,207) is WORSE than simply
# repeating the last observed week's revenue (naive RMSE GBP 109,032). This
# is reported honestly rather than hidden: with this little data, a fitted
# time series model can lose to the simplest possible baseline, which is
# itself the argument for not deploying a forecast model on this data as-is
# and instead waiting for more history. Ljung-Box (p = 0.69) confirms the
# AR(1) model's own residuals show no leftover pattern, so the model is not
# mis-specified for what little structure it does capture - it is simply
# working with too little data to add value over the naive baseline.
#
# Limitation to state explicitly: this series covers only two 52-week
# cycles (Dec 2009-Dec 2011). Every diagnostic above independently points to
# the same conclusion - the decomposition's suspiciously perfect fit, the
# conflicting stationarity tests, and auto.arima's inability to fit a
# seasonal model are three separate symptoms of the same root limitation.
# State this before an examiner asks, and use it as the argument for
# collecting more data before deploying any time series forecast in
# production, per Task 10's proposal.
#
# Business applications: inventory planning ahead of the Q4 peak (still
# visible descriptively in notebook 01's monthly chart, even though a
# formal model cannot yet confirm it repeats reliably), staffing (zero
# Saturday orders simplifies weekend staffing decisions), campaign timing,
# and cash-flow planning.

cat("\nDone. Figures written to reports/figures/r_*.png\n")
