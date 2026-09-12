import pandas as pd
import matplotlib.pyplot as plt

df = pd.read_csv("data/ecommerce_sales_clean.csv", parse_dates=["Order_Date"])

print("Rows:", len(df))
print("\nMissing values:")
print(df.isna().sum())

print("\nCategory KPI:")
print(
    df.groupby("Category")
      .agg(Orders=("Order_ID","count"),
           Revenue=("Sales","sum"),
           Profit=("Profit","sum"))
      .sort_values("Revenue", ascending=False)
)

monthly = df.groupby(df["Order_Date"].dt.to_period("M"))["Sales"].sum()
monthly.plot(figsize=(10,5), title="Monthly Revenue Trend")
plt.ylabel("Revenue")
plt.tight_layout()
plt.show()
