# 01 - Dataset Understanding and Descriptive Analysis (Task 3)

# Brief section 4: summary statistics, histograms/box plots (raw and log scale),
# revenue by country, Pareto chart of revenue concentration, monthly/weekly revenue
# trends, revenue by day of week and hour of day. Turn every observation into a
# business insight (section 4.3).

library(dplyr)
library(ggplot2)
library(readr)

clean <- read_csv("../data/processed/invoice_lines_clean.csv")
customers <- read_csv("../data/processed/customer_table.csv")
theme_set(theme_minimal())

# ---- Purchases only (drop cancellations) ----

sales <- clean %>% filter(!IsCancellation, Quantity > 0)

# ---- Summary statistics ----

summary(sales[, c("Quantity", "Price", "LineRevenue")])
summary(customers)

# ---- Distributions (raw vs log scale) ----

# TODO: histograms / box plots, raw and log1p transformed (ggplot2::geom_histogram)

# ---- Revenue by country ----

# TODO: sales %>% group_by(Country) %>% summarise(Revenue = sum(LineRevenue)) ...

# ---- Pareto chart of cumulative revenue by customer ----

# TODO: sort customers by Monetary desc, plot cumulative revenue share vs customer share

# ---- Monthly and weekly revenue trends ----

# TODO: use lubridate::floor_date(InvoiceDate, "week"/"month") then group_by + summarise

# ---- Revenue by day of week and hour of day ----

# TODO: lubridate::wday(InvoiceDate, label = TRUE), lubridate::hour(InvoiceDate)

# ---- Business insights ----

# _Write 1 insight per finding, e.g. "the top X% of customers generate Y% of revenue..."_
