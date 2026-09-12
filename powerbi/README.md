# Power BI Dashboard — E-Commerce Sales & KPI Performance

Import `data/ecommerce_sales_clean.csv`.

## Page 1 — Executive Overview
KPI cards: Total Revenue, Total Profit, Total Orders, Units Sold, Average Order Value, Profit Margin %.
Charts: Revenue by Category, Monthly Revenue Trend, Revenue by Region, Revenue Contribution by Category.
Slicers: Date, Category, Region, Customer Segment.

## Page 2 — Category Performance
Revenue by Category, Profit by Category, Profit Margin % by Category, Units Sold by Category, Top Products by Revenue.

## Page 3 — KPI & Segment Analysis
Revenue by Customer Segment, AOV by Segment, Payment Method distribution, monthly revenue/profit trend.

## DAX measures
Total Revenue = SUM(ecommerce_sales_clean[Sales])
Total Profit = SUM(ecommerce_sales_clean[Profit])
Total Orders = DISTINCTCOUNT(ecommerce_sales_clean[Order_ID])
Units Sold = SUM(ecommerce_sales_clean[Quantity])
Average Order Value = DIVIDE([Total Revenue], [Total Orders])
Profit Margin % = DIVIDE([Total Profit], [Total Revenue])
Revenue Contribution % = DIVIDE([Total Revenue], CALCULATE([Total Revenue], ALL(ecommerce_sales_clean[Category])))

**Note:** PNGs in `screenshots/` are Power BI-style portfolio previews, not `.pbix` exports.
