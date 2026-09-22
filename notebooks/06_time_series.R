# 06 - Time Series Analysis (Task 9)

# Brief section 10. Decompose weekly revenue into trend/seasonality, note the
# absence of Saturday orders and the strong Q4/November peak, and discuss
# forecasting (ARIMA/SARIMA) qualitatively. Honest limitation: only two years of
# data = two seasonal cycles, thin for annual seasonality.

library(dplyr)
library(ggplot2)
library(readr)

clean <- read_csv("../data/processed/invoice_lines_clean.csv")
customers <- read_csv("../data/processed/customer_table.csv")
theme_set(theme_minimal())

library(forecast)
library(lubridate)

# ---- Weekly revenue series ----

weekly_revenue <- clean %>%
  filter(!IsCancellation) %>%
  mutate(week = floor_date(InvoiceDate, "week")) %>%
  group_by(week) %>%
  summarise(Revenue = sum(LineRevenue), .groups = "drop")

ggplot(weekly_revenue, aes(week, Revenue)) + geom_line() + labs(title = "Weekly revenue")

# ---- Decomposition ----

# TODO: ts(weekly_revenue$Revenue, frequency = 52) %>% decompose() %>% plot()
# or stl() for a more robust seasonal-trend decomposition

# ---- Day-of-week pattern (no Saturday orders) ----

# TODO: clean %>% mutate(dow = wday(InvoiceDate, label = TRUE)) %>% group_by(dow) %>% summarise(Revenue = sum(LineRevenue))

# ---- Discussion ----

# - Trend, weekly seasonality (no Saturdays — operational explanation), annual/Q4 seasonality
# - ARIMA/SARIMA as a forecasting option (not required to fit — discuss qualitatively or fit with `forecast::auto.arima()`)
# - Business applications: inventory planning, staffing, campaign timing, cash-flow
