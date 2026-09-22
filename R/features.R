# Build the customer-level feature/target table (brief section 1.3).
#
# Features are computed only from transactions strictly before CUTOFF_DATE.
# Targets are computed from the 90-day window strictly after CUTOFF_DATE.
# This split is what prevents data leakage - see the brief's viva checklist.

library(dplyr)
library(lubridate)

CUTOFF_DATE <- as.POSIXct("2011-09-09", tz = "UTC")
TARGET_WINDOW_DAYS <- 90

#' One row per CustomerID, built only from data before `cutoff`.
build_features <- function(df, cutoff = CUTOFF_DATE) {
  hist <- df %>% filter(InvoiceDate < cutoff, !is.na(CustomerID))
  purchases <- hist %>% filter(!IsCancellation)

  features <- purchases %>%
    group_by(CustomerID) %>%
    summarise(
      Recency = as.numeric(difftime(cutoff, max(InvoiceDate), units = "days")),
      Frequency = n_distinct(Invoice),
      Monetary = sum(LineRevenue),
      FirstPurchase = min(InvoiceDate),
      DistinctProducts = n_distinct(StockCode),
      Country = names(sort(table(Country), decreasing = TRUE))[1],
      .groups = "drop"
    ) %>%
    mutate(
      TenureDays = as.numeric(difftime(cutoff, FirstPurchase, units = "days")),
      AvgBasketValue = Monetary / Frequency,
      IsUK = as.integer(Country == "United Kingdom"),
      AcquiredInQ4 = as.integer(month(FirstPurchase) %in% c(10, 11, 12))
    )

  cancel_orders <- hist %>% filter(IsCancellation) %>%
    group_by(CustomerID) %>% summarise(n_cancelled = n_distinct(Invoice), .groups = "drop")
  all_orders <- hist %>% group_by(CustomerID) %>% summarise(n_all = n_distinct(Invoice), .groups = "drop")

  features <- features %>%
    left_join(all_orders, by = "CustomerID") %>%
    left_join(cancel_orders, by = "CustomerID") %>%
    mutate(
      n_cancelled = coalesce(n_cancelled, 0),
      CancellationRate = coalesce(n_cancelled / n_all, 0)
    ) %>%
    select(-FirstPurchase, -Country, -n_all, -n_cancelled)

  features
}

#' Repurchase flag and future spend from the window strictly after `cutoff`.
build_targets <- function(df, cutoff = CUTOFF_DATE, window_days = TARGET_WINDOW_DAYS) {
  window_end <- cutoff + days(window_days)
  future <- df %>%
    filter(InvoiceDate >= cutoff, InvoiceDate < window_end, !is.na(CustomerID), !IsCancellation)

  future %>%
    group_by(CustomerID) %>%
    summarise(FutureSpend = sum(LineRevenue), .groups = "drop") %>%
    mutate(Repurchase = 1L)
}

#' Merge features and targets; customers with no future orders get Repurchase = 0.
build_customer_table <- function(df, cutoff = CUTOFF_DATE) {
  features <- build_features(df, cutoff)
  targets <- build_targets(df, cutoff)

  features %>%
    left_join(targets, by = "CustomerID") %>%
    mutate(
      Repurchase = coalesce(Repurchase, 0L),
      FutureSpend = coalesce(FutureSpend, 0)
    )
}
