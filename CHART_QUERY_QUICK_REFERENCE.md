# Chart Query API - Quick Reference Card

## 🚀 Endpoint

```
POST /processor/chart-query
```

---

## 📋 Request Template

```json
{
  "data": {
    /* Your JSON data */
  },
  "dimensions": ["field1", "field2"],
  "metrics": [
    {
      "field": "amount",
      "aggregation": "sum",
      "alias": "total"
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
      "field": "total",
      "direction": "desc"
    }
  ],
  "limit": 10
}
```

---

## 📊 Aggregation Functions

| Function        | Description         | Use Case                                      |
| --------------- | ------------------- | --------------------------------------------- |
| `sum`           | Sum of values       | Total revenue, total quantity                 |
| `avg`           | Average             | Average price, average rating                 |
| `count`         | Count rows          | Number of records                             |
| `min`           | Minimum value       | Lowest price, earliest date                   |
| `max`           | Maximum value       | Highest price, latest date                    |
| `median`        | Median value        | Median income, median age                     |
| `std`           | Standard deviation  | Price variance, score distribution            |
| `countDistinct` | Count unique values | Unique customers, unique products             |
| `first`         | First value         | Get scalar field value (repeated across rows) |
| `last`          | Last value          | Get scalar field value (repeated across rows) |

---

## 🔍 Filter Operators

| Operator             | Example                   |
| -------------------- | ------------------------- |
| `equals`             | `"status" = "active"`     |
| `notEquals`          | `"status" != "cancelled"` |
| `greaterThan`        | `"price" > 100`           |
| `lessThan`           | `"quantity" < 10`         |
| `greaterThanOrEqual` | `"age" >= 18`             |
| `lessThanOrEqual`    | `"discount" <= 50`        |

---

## 📈 Common Patterns

### Bar Chart - Group by One Dimension

```json
{
  "dimensions": ["region"],
  "metrics": [{ "field": "amount", "aggregation": "sum", "alias": "revenue" }]
}
```

### Stacked Bar - Group by Two Dimensions

```json
{
  "dimensions": ["region", "category"],
  "metrics": [{ "field": "amount", "aggregation": "sum", "alias": "revenue" }]
}
```

### KPI Card - No Grouping

```json
{
  "metrics": [
    { "field": "amount", "aggregation": "sum", "alias": "total_revenue" },
    { "field": "orderId", "aggregation": "count", "alias": "total_orders" }
  ]
}
```

### Top 10 - With Limit

```json
{
  "dimensions": ["product"],
  "metrics": [{ "field": "amount", "aggregation": "sum", "alias": "revenue" }],
  "sort": [{ "field": "revenue", "direction": "desc" }],
  "limit": 10
}
```

### Filtered Chart

```json
{
  "dimensions": ["region"],
  "metrics": [{ "field": "amount", "aggregation": "sum", "alias": "revenue" }],
  "filters": [
    { "field": "category", "operator": "equals", "value": "Electronics" }
  ]
}
```

---

## 📤 Response Format

```json
{
  "success": true,
  "data": [
    { "region": "North", "revenue": 15000 },
    { "region": "South", "revenue": 12000 }
  ],
  "metadata": {
    "rowCount": 2,
    "dimensions": ["region"],
    "metrics": ["revenue"],
    "filtersApplied": 0,
    "engine": "polars",
    "executionTime": 45
  }
}
```

---

## 🎯 Chart Type Mapping

| Chart Type       | Dimensions | Metrics | Sort           | Limit    |
| ---------------- | ---------- | ------- | -------------- | -------- |
| **Bar Chart**    | 1          | 1+      | Optional       | No       |
| **Line Chart**   | 1 (time)   | 1+      | By time ASC    | No       |
| **Pie Chart**    | 1          | 1       | Optional       | Optional |
| **Stacked Bar**  | 2          | 1+      | Optional       | No       |
| **Scatter Plot** | 0          | 2       | No             | Optional |
| **KPI Card**     | 0          | 1+      | No             | No       |
| **Top N**        | 1          | 1+      | By metric DESC | Yes      |
| **Heatmap**      | 2          | 1       | Optional       | No       |

---

## ⚡ Performance Tips

1. **Filter early** - Apply filters before grouping
2. **Use limit** - For top N queries
3. **Minimize dimensions** - Fewer dimensions = faster queries
4. **Cache results** - Cache on client side
5. **Use aliases** - Makes data easier to work with

---

## 🔗 Integration Example

```javascript
// Fetch data
const response = await fetch('/processor/chart-query', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    data: myData,
    dimensions: ['region'],
    metrics: [{ field: 'amount', aggregation: 'sum', alias: 'revenue' }],
  }),
});

const result = await response.json();

// Use with Chart.js
const chartData = {
  labels: result.data.map((row) => row.region),
  datasets: [
    {
      data: result.data.map((row) => row.revenue),
    },
  ],
};
```

---

## 📚 Full Documentation

- **CHART_QUERY_GUIDE.md** - Complete guide with examples
- **BI_ANALYTICS_IMPLEMENTATION.md** - Implementation details
- **test-chart-query.ps1** - Basic test examples
- **test-chart-query-advanced.ps1** - Advanced test examples

---

**Happy Charting!** 📊
