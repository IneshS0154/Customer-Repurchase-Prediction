"""Load and clean the raw Online Retail II invoice lines (brief section 4.1)."""

from pathlib import Path

import pandas as pd

RAW_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"

NON_PRODUCT_CODES = {"POST", "M", "D", "BANK CHARGES", "AMAZONFEE", "DOT", "C2", "PADS"}


def load_raw(raw_dir: Path = RAW_DIR) -> pd.DataFrame:
    """Load both sheets of the Online Retail II workbook into one frame."""
    xlsx_path = raw_dir / "online_retail_II.xlsx"
    if not xlsx_path.exists():
        candidates = list(raw_dir.glob("*.xlsx"))
        if not candidates:
            raise FileNotFoundError(
                f"No .xlsx file found in {raw_dir}. See README setup instructions."
            )
        xlsx_path = candidates[0]

    sheets = pd.read_excel(xlsx_path, sheet_name=None, engine="openpyxl")
    df = pd.concat(sheets.values(), ignore_index=True)
    df = df.rename(columns={"Customer ID": "CustomerID"})
    return df


def clean_invoice_lines(df: pd.DataFrame) -> pd.DataFrame:
    """Apply the data quality treatments from brief section 4.1.

    Keeps cancellations and missing-CustomerID rows (needed for cancellation
    rate and sales totals respectively) but flags them; drops zero/negative
    price rows, non-product stock codes, and exact duplicates.
    """
    df = df.copy()
    df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"])
    df["Invoice"] = df["Invoice"].astype(str)
    df["StockCode"] = df["StockCode"].astype(str).str.upper()

    df["IsCancellation"] = df["Invoice"].str.startswith("C")

    df = df[~df["StockCode"].isin(NON_PRODUCT_CODES)]
    df = df[df["Price"] > 0]
    df = df.drop_duplicates()

    df["LineRevenue"] = df["Quantity"] * df["Price"]

    return df.reset_index(drop=True)
