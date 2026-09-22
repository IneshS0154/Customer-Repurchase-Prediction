"""Build the customer-level feature/target table (brief section 1.3).

Features are computed only from transactions strictly before CUTOFF_DATE.
Targets are computed from the 90-day window strictly after CUTOFF_DATE.
This split is what prevents data leakage — see the brief's viva checklist.
"""

import pandas as pd

CUTOFF_DATE = pd.Timestamp("2011-09-09")
TARGET_WINDOW_DAYS = 90


def build_features(df: pd.DataFrame, cutoff: pd.Timestamp = CUTOFF_DATE) -> pd.DataFrame:
    """One row per CustomerID, built only from data before `cutoff`."""
    hist = df[(df["InvoiceDate"] < cutoff) & df["CustomerID"].notna()].copy()

    purchases = hist[~hist["IsCancellation"]]
    cancellations = hist[hist["IsCancellation"]]

    grouped = purchases.groupby("CustomerID")

    features = grouped.agg(
        Recency=("InvoiceDate", lambda s: (cutoff - s.max()).days),
        Frequency=("Invoice", "nunique"),
        Monetary=("LineRevenue", "sum"),
        FirstPurchase=("InvoiceDate", "min"),
        DistinctProducts=("StockCode", "nunique"),
        Country=("Country", lambda s: s.mode().iat[0] if not s.mode().empty else "Unknown"),
    )

    features["TenureDays"] = (cutoff - features["FirstPurchase"]).dt.days
    features["AvgBasketValue"] = features["Monetary"] / features["Frequency"]
    features["IsUK"] = (features["Country"] == "United Kingdom").astype(int)
    features["AcquiredInQ4"] = features["FirstPurchase"].dt.month.isin([10, 11, 12]).astype(int)

    cancel_orders = cancellations.groupby("CustomerID")["Invoice"].nunique()
    all_orders = hist.groupby("CustomerID")["Invoice"].nunique()
    features["CancellationRate"] = (
        cancel_orders.reindex(features.index).fillna(0) / all_orders.reindex(features.index)
    ).fillna(0)

    return features.drop(columns=["FirstPurchase", "Country"]).reset_index()


def build_targets(
    df: pd.DataFrame,
    cutoff: pd.Timestamp = CUTOFF_DATE,
    window_days: int = TARGET_WINDOW_DAYS,
) -> pd.DataFrame:
    """Repurchase flag and future spend from the window strictly after `cutoff`."""
    window_end = cutoff + pd.Timedelta(days=window_days)
    future = df[
        (df["InvoiceDate"] >= cutoff)
        & (df["InvoiceDate"] < window_end)
        & df["CustomerID"].notna()
        & (~df["IsCancellation"])
    ]

    spend = future.groupby("CustomerID")["LineRevenue"].sum().rename("FutureSpend")
    targets = spend.to_frame()
    targets["Repurchase"] = 1
    return targets.reset_index()


def build_customer_table(df: pd.DataFrame, cutoff: pd.Timestamp = CUTOFF_DATE) -> pd.DataFrame:
    """Merge features and targets; customers with no future orders get Repurchase=0."""
    features = build_features(df, cutoff)
    targets = build_targets(df, cutoff)

    table = features.merge(targets, on="CustomerID", how="left")
    table["Repurchase"] = table["Repurchase"].fillna(0).astype(int)
    table["FutureSpend"] = table["FutureSpend"].fillna(0.0)
    return table
