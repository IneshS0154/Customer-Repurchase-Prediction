# 00 - Data Cleaning & Customer-Level Table

# Loads the raw Online Retail II invoice lines, applies the quality treatments from
# brief section 4.1, and builds the customer-level feature/target table (section 1.3)
# using a 9 September 2011 cutoff to avoid data leakage.

# Outputs `data/processed/invoice_lines_clean.csv` and `data/processed/customer_table.csv`
# for use by every later notebook.

library(dplyr)
source("../R/cleaning.R")
source("../R/features.R")

raw <- load_raw("../data/raw")
dim(raw)
head(raw)

# ---- Step 1: Audit data quality issues on the raw data ----

# Count each issue separately (rows can have several problems, so the counts will not
# add up to the total dropped).

n <- nrow(raw)
is_cancel <- startsWith(raw$Invoice, "C")

audit <- tibble::tibble(
  Issue = c(
    "Missing CustomerID",
    "Cancellation invoices (start with C)",
    "Negative quantity, not a cancellation",
    "Price <= 0",
    "Exact duplicate rows"
  ),
  Rows = c(
    sum(is.na(raw$CustomerID)),
    sum(is_cancel),
    sum(raw$Quantity < 0 & !is_cancel, na.rm = TRUE),
    sum(raw$Price <= 0, na.rm = TRUE),
    sum(duplicated(raw))
  )
)
audit$`% of rows` <- round(audit$Rows / n * 100, 2)
cat("Total raw rows:", n, "\n")
audit

# ---- Non-product stock codes ----

codes <- toupper(raw$StockCode)
odd_codes <- codes[!grepl("^[0-9]{5}", codes)]
sort(table(odd_codes), decreasing = TRUE)[1:30]

# ---- Extreme values ----

summary(raw[, c("Quantity", "Price")])

raw %>% slice_max(Quantity, n = 10) %>%
  select(Invoice, StockCode, Description, Quantity, Price, CustomerID)

# ---- Clean ----

clean <- clean_invoice_lines(raw)
dim(clean)
cat("Missing CustomerID share:", mean(is.na(clean$CustomerID)), "\n")
cat("Cancellation share:", mean(clean$IsCancellation), "\n")
head(clean)

write.csv(clean, "../data/processed/invoice_lines_clean.csv", row.names = FALSE)

# ---- Build the customer-level table ----

customer_table <- build_customer_table(clean, cutoff = CUTOFF_DATE)
dim(customer_table)
summary(customer_table)

write.csv(customer_table, "../data/processed/customer_table.csv", row.names = FALSE)

# ---- Step 2: Target balance ----

# Share of customers who repurchased in the 90 days after the cutoff.

mean(customer_table$Repurchase)
