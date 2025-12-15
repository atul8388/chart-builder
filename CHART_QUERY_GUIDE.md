# Chart Query API - BI-Style Analytics Guide

## Overview

The Chart Query API provides **full BI-style analytics capabilities** for dynamic chart building. It combines data flattening, filtering, grouping, and aggregation into a single powerful endpoint.

This is designed to work like **Power BI, Tableau, or Looker** - allowing you to build dynamic charts with complex queries.

---

## Endpoint

**POST** `/processor/chart-query`

---

## Key Features

✅ **Data Flattening** - Automatically flattens nested JSON and unnests arrays  
✅ **Filtering** - Apply multiple filters with various operators  
✅ **Grouping** - Group by one or more dimensions  
✅ **Aggregation** - Sum, average, count, min, max, median, std, countDistinct  
✅ **Sorting** - Sort results by any field  
✅ **Limiting** - Get top N results  
✅ **Date Range Filtering** - Filter by date ranges  
✅ **Multi-dimensional Analysis** - Group by multiple dimensions  

---

## Request Structure

```json
{
  "data": { /* Your JSON data */ },
  "template": { /* Optional: field type definitions */ },
  "dimensions": ["field1", "field2"],
  "metrics": [
    {
      "field": "amount",
      "aggregation": "sum",
      "alias": "total_amount"
    }
  ],
  "filters": [
    {
      "field": "status",
      "operator": "equals",
      "value": "active"
    }
  ],
  "sort": [
    {
      "field": "total_amount",
      "direction": "desc"
    }
  ],
  "limit": 10,
  "dateRange": {
    "field": "orderDate",
    "startDate": "2025-01-01",
    "endDate": "2025-12-31"
  }
}
```

---

## Aggregation Functions

| Function | Description | Example Use Case |
|----------|-------------|------------------|
| `sum` | Sum of all values | Total revenue, total quantity |
| `avg` | Average of all values | Average order value, average rating |
| `count` | Count of rows | Number of orders, number of customers |
| `min` | Minimum value | Lowest price, earliest date |
| `max` | Maximum value | Highest price, latest date |
| `median` | Median value | Median income, median age |
| `std` | Standard deviation | Price variance, score distribution |
| `countDistinct` | Count unique values | Unique customers, unique products |

---

## Filter Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `equals` | Exact match | `status = "active"` |
| `notEquals` | Not equal | `status != "cancelled"` |
| `greaterThan` | Greater than | `price > 100` |
| `lessThan` | Less than | `quantity < 10` |
| `greaterThanOrEqual` | Greater than or equal | `age >= 18` |
| `lessThanOrEqual` | Less than or equal | `discount <= 50` |
| `contains` | String contains | `name contains "John"` |
| `notContains` | String does not contain | `email not contains "spam"` |
| `in` | Value in list | `region in ["North", "South"]` |
| `notIn` | Value not in list | `status not in ["cancelled", "refunded"]` |
| `isNull` | Value is null | `discount is null` |
| `isNotNull` | Value is not null | `email is not null` |
| `between` | Value between range | `price between [100, 500]` |

---

## Common Chart Types & Queries

### 1. Bar Chart - Sales by Region

**Use Case:** Show total sales for each region

```json
{
  "data": { "sales": [...] },
  "dimensions": ["sales_region"],
  "metrics": [
    {
      "field": "sales_amount",
      "aggregation": "sum",
      "alias": "total_sales"
    }
  ],
  "sort": [
    { "field": "total_sales", "direction": "desc" }
  ]
}
```

**Result:**
```json
[
  { "sales_region": "North", "total_sales": 15000 },
  { "sales_region": "South", "total_sales": 12000 },
  { "sales_region": "East", "total_sales": 8000 }
]
```

---

### 2. Line Chart - Sales Over Time

**Use Case:** Show sales trend by month

```json
{
  "data": { "sales": [...] },
  "dimensions": ["sales_month"],
  "metrics": [
    {
      "field": "sales_amount",
      "aggregation": "sum",
      "alias": "monthly_revenue"
    }
  ],
  "sort": [
    { "field": "sales_month", "direction": "asc" }
  ]
}
```

---

### 3. Pie Chart - Market Share by Category

**Use Case:** Show percentage of sales by category

```json
{
  "data": { "sales": [...] },
  "dimensions": ["sales_category"],
  "metrics": [
    {
      "field": "sales_amount",
      "aggregation": "sum",
      "alias": "category_revenue"
    },
    {
      "field": "sales_orderId",
      "aggregation": "count",
      "alias": "order_count"
    }
  ]
}
```

---

### 4. Stacked Bar Chart - Sales by Region & Category

**Use Case:** Show sales breakdown by region and category

```json
{
  "data": { "sales": [...] },
  "dimensions": ["sales_region", "sales_category"],
  "metrics": [
    {
      "field": "sales_amount",
      "aggregation": "sum",
      "alias": "revenue"
    }
  ]
}
```

**Result:**
```json
[
  { "sales_region": "North", "sales_category": "Electronics", "revenue": 8000 },
  { "sales_region": "North", "sales_category": "Furniture", "revenue": 5000 },
  { "sales_region": "South", "sales_category": "Electronics", "revenue": 6000 }
]
```

---

### 5. KPI Card - Overall Totals

**Use Case:** Show grand totals without grouping

```json
{
  "data": { "sales": [...] },
  "metrics": [
    {
      "field": "sales_amount",
      "aggregation": "sum",
      "alias": "total_revenue"
    },
    {
      "field": "sales_orderId",
      "aggregation": "count",
      "alias": "total_orders"
    },
    {
      "field": "sales_amount",
      "aggregation": "avg",
      "alias": "avg_order_value"
    }
  ]
}
```

**Result:**
```json
[
  {
    "total_revenue": 45000,
    "total_orders": 150,
    "avg_order_value": 300
  }
]
```

---


