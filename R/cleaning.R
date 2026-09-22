# Load and clean the raw Online Retail II invoice lines (brief section 4.1).

library(readxl)
library(dplyr)
library(stringr)

NON_PRODUCT_CODES <- c("POST", "M", "D", "BANK CHARGES", "AMAZONFEE", "DOT", "C2", "PADS", "B", "ADJUST")

#' Load both sheets of the Online Retail II workbook into one data frame.
load_raw <- function(raw_dir = "data/raw") {
  xlsx_path <- file.path(raw_dir, "online_retail_II.xlsx")
  if (!file.exists(xlsx_path)) {
    candidates <- list.files(raw_dir, pattern = "\\.xlsx$", full.names = TRUE)
    if (length(candidates) == 0) {
      stop(sprintf("No .xlsx file found in %s. See README setup instructions.", raw_dir))
    }
    xlsx_path <- candidates[1]
  }

  # Explicit column types: the two sheets are inconsistent about inferring
  # Invoice/StockCode as numeric when a sheet happens to have no cancellations.
  col_spec <- c("text", "text", "text", "numeric", "date", "numeric", "numeric", "text")

  sheets <- excel_sheets(xlsx_path)
  parts <- lapply(sheets, function(s) read_excel(xlsx_path, sheet = s, col_types = col_spec))
  df <- bind_rows(parts)
  df <- df %>% rename(CustomerID = `Customer ID`)
  df
}

#' Apply the data quality treatments from brief section 4.1.
#'
#' Keeps cancellations and missing-CustomerID rows (needed for cancellation
#' rate and sales totals respectively) but flags them; drops zero/negative
#' price rows, non-product stock codes, and exact duplicates.
clean_invoice_lines <- function(df) {
  df %>%
    mutate(
      StockCode = str_to_upper(StockCode),
      IsCancellation = str_starts(Invoice, "C")
    ) %>%
    filter(!StockCode %in% NON_PRODUCT_CODES) %>%
    filter(Price > 0) %>%
    distinct() %>%
    mutate(LineRevenue = Quantity * Price)
}
