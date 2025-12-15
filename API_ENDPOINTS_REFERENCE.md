# API Endpoints Quick Reference

## Base URL

```
http://localhost:3000
```

---

## 1. Flatten JSON (DuckDB)

**Endpoint**: `POST /processor/flatten-json`

**Description**: Flattens JSON using DuckDB SQL engine

**Request Body**:

```json
{
  "data": {
    /* your JSON data */
  }
}
```

**Response**:

```json
{
  "success": true,
  "rowCount": 2,
  "data": [
    /* flattened rows */
  ]
}
```

**PowerShell Example**:

```powershell
$body = @{ data = @{ orderId = "123"; items = @(@{ product = "Laptop" }) } } | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json" -Method Post -ContentType "application/json" -Body $body
```

---

## 2. Flatten JSON (Polars)

**Endpoint**: `POST /processor/flatten-json-polars`

**Description**: Flattens JSON using Polars (supports grouped properties with numeric suffixes)

**Request Body**:

```json
{
  "data": {
    /* your JSON data */
  }
}
```

**Response**:

```json
{
  "success": true,
  "rowCount": 2,
  "engine": "polars",
  "data": [
    /* flattened rows */
  ]
}
```

**PowerShell Example**:

```powershell
$body = @{ data = @{ orderId = "123"; "down_type-1" = "TypeA"; "down_type-2" = "TypeB" } } | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json-polars" -Method Post -ContentType "application/json" -Body $body
```

---

## 3. Get Fields by Type

**Endpoint**: `POST /processor/get-fields-by-type`

**Description**: Extracts list of field names from template, optionally filtered by type

**Request Body**:

```json
{
  "template": {
    "fields": {
      "amount": { "inputoptiontype": "number" },
      "customer": { "inputoptiontype": "text" }
    }
  },
  "filterType": "number" // optional
}
```

**Response**:

```json
{
  "success": true,
  "filterType": "number",
  "fieldCount": 1,
  "fields": ["amount"]
}
```

**PowerShell Example**:

```powershell
$body = @{
    template = @{
        fields = @{
            amount = @{ inputoptiontype = "number" }
            customer = @{ inputoptiontype = "text" }
        }
    }
    filterType = "number"
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "http://localhost:3000/processor/get-fields-by-type" -Method Post -ContentType "application/json" -Body $body
```

---

## 4. Flatten with Template Filter

**Endpoint**: `POST /processor/flatten-with-template`

**Description**: Flattens JSON and filters fields based on template types

**Request Body**:

```json
{
  "data": {
    "orderId": "12345",
    "customer": "John Doe",
    "amount": 1500,
    "quantity": 3
  },
  "template": {
    "fields": {
      "orderId": { "inputoptiontype": "text" },
      "customer": { "inputoptiontype": "text" },
      "amount": { "inputoptiontype": "number" },
      "quantity": { "inputoptiontype": "number" }
    }
  },
  "filterType": "number" // optional
}
```

**Response**:

```json
{
  "success": true,
  "rowCount": 1,
  "filterType": "number",
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "amount": 1500,
      "quantity": 3
    }
  ]
}
```

**PowerShell Example**:

```powershell
$body = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        amount = 1500
        quantity = 3
    }
    template = @{
        fields = @{
            orderId = @{ inputoptiontype = "text" }
            customer = @{ inputoptiontype = "text" }
            amount = @{ inputoptiontype = "number" }
            quantity = @{ inputoptiontype = "number" }
        }
    }
    filterType = "number"
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-with-template" -Method Post -ContentType "application/json" -Body $body
```

---

## 5. Chart Query (BI Analytics) ⭐ NEW

**Endpoint**: `POST /processor/chart-query`

**Description**: Full BI-style analytics with filtering, grouping, and aggregation for dynamic charts

**Request Body**:

```json
{
  "data": {
    /* your JSON data */
  },
  "dimensions": ["region", "category"],
  "metrics": [
    {
      "field": "amount",
      "aggregation": "sum",
      "alias": "total_revenue"
    },
    {
      "field": "quantity",
      "aggregation": "avg",
      "alias": "avg_quantity"
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
      "field": "total_revenue",
      "direction": "desc"
    }
  ],
  "limit": 10
}
```

**Response**:

```json
{
  "success": true,
  "data": [
    {
      "region": "North",
      "category": "Electronics",
      "total_revenue": 15000,
      "avg_quantity": 2.5
    }
  ],
  "metadata": {
    "rowCount": 1,
    "dimensions": ["region", "category"],
    "metrics": ["total_revenue", "avg_quantity"],
    "filtersApplied": 1,
    "engine": "polars",
    "executionTime": 45
  }
}
```

**Aggregation Functions**:

- `sum` - Sum of values
- `avg` - Average
- `count` - Count rows
- `min` - Minimum value
- `max` - Maximum value
- `median` - Median value
- `std` - Standard deviation
- `countDistinct` - Count unique values

**Filter Operators**:

- `equals`, `notEquals`
- `greaterThan`, `lessThan`, `greaterThanOrEqual`, `lessThanOrEqual`
- `contains`, `notContains`
- `in`, `notIn`
- `isNull`, `isNotNull`
- `between`

**PowerShell Example**:

```powershell
$body = @{
    data = @{
        sales = @(
            @{ region = "North"; category = "Electronics"; amount = 1200; quantity = 2 }
            @{ region = "South"; category = "Furniture"; amount = 500; quantity = 1 }
        )
    }
    dimensions = @("sales_region")
    metrics = @(
        @{
            field = "sales_amount"
            aggregation = "sum"
            alias = "total_revenue"
        }
    )
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "http://localhost:3000/processor/chart-query" -Method Post -ContentType "application/json" -Body $body
```

---

## Feature Comparison

| Feature                               | DuckDB | Polars | Polars + Template | Chart Query |
| ------------------------------------- | ------ | ------ | ----------------- | ----------- |
| Flatten nested objects                | ✅     | ✅     | ✅                | ✅          |
| Unnest arrays                         | ✅     | ✅     | ✅                | ✅          |
| Row padding                           | ✅     | ✅     | ✅                | ✅          |
| Grouped properties (numeric suffixes) | ❌     | ✅     | ✅                | ✅          |
| Template-based filtering              | ❌     | ❌     | ✅                | ❌          |
| Field type extraction                 | ❌     | ❌     | ✅                | ❌          |
| **Filtering (pre-aggregation)**       | ❌     | ❌     | ❌                | ✅          |
| **Grouping (dimensions)**             | ❌     | ❌     | ❌                | ✅          |
| **Aggregation (metrics)**             | ❌     | ❌     | ❌                | ✅          |
| **Sorting**                           | ❌     | ❌     | ❌                | ✅          |
| **Top N (limit)**                     | ❌     | ❌     | ❌                | ✅          |
| **Date Range Filtering**              | ❌     | ❌     | ❌                | ✅          |

---

## Common Field Types

- `"number"` - Numeric fields (integers, decimals)
- `"text"` - Text/string fields
- `"date"` - Date fields
- `"datetime"` - DateTime fields
- `"boolean"` - Boolean fields
- Custom types as needed

---

## Test Scripts

```powershell
# Basic flattening tests
.\test-flatten-api.ps1          # DuckDB tests
.\test-polars-api.ps1           # Polars tests

# Grouped properties tests
.\test-polars-grouped.ps1       # Numeric suffix grouping

# Template filtering tests
.\test-template-filter.ps1      # Basic template tests
.\test-template-advanced.ps1    # Advanced template tests with arrays

# Chart query tests (BI Analytics) ⭐ NEW
.\test-chart-query.ps1          # Basic chart query tests
.\test-chart-query-advanced.ps1 # Advanced BI analytics tests
.\test-production-report.ps1    # Production report comprehensive tests (7 tests)
```

---

## Documentation

### Core Features

- **FLATTEN_API_USAGE.md** - Basic flattening guide
- **POLARS_SERVICE_README.md** - Polars service overview
- **GROUPED_PROPERTIES_GUIDE.md** - Grouped properties feature
- **TEMPLATE_FILTERING_GUIDE.md** - Template filtering guide
- **TEMPLATE_FILTERING_SUMMARY.md** - Implementation summary

### BI Analytics ⭐ NEW

- **CHART_QUERY_GUIDE.md** - Comprehensive chart query guide (255 lines)
- **CHART_QUERY_QUICK_REFERENCE.md** - Quick reference card
- **BI_ANALYTICS_IMPLEMENTATION.md** - Implementation summary
- **POLARS_DATAFRAME_REFACTORING.md** - Polars DataFrame details
- **PRODUCTION_REPORT_TESTING.md** - Production report testing guide
- **NULL_HANDLING_GUIDE.md** - Null value handling guide ⭐ NEW
- **NULL_HANDLING_UPDATE.md** - Null handling update summary ⭐ NEW

---

## Use Cases

### 1. Simple Data Flattening

Use `/processor/flatten-json-polars` when you just need to flatten nested JSON.

### 2. Form Builder Integration

Use `/processor/flatten-with-template` when you have a form template and want to filter fields by type.

### 3. Dynamic Chart Building ⭐

Use `/processor/chart-query` when you need:

- Bar charts, line charts, pie charts
- Grouped/stacked charts
- KPI cards with aggregations
- Top N rankings
- Filtered analytics
- Multi-dimensional analysis

---

## Quick Start

1. **Start the server:**

   ```bash
   npm run start:dev
   ```

2. **Test basic flattening:**

   ```bash
   .\test-polars-api.ps1
   ```

3. **Test chart queries:**

   ```bash
   .\test-chart-query.ps1
   ```

4. **Read the guides:**
   - For flattening: `POLARS_SERVICE_README.md`
   - For charts: `CHART_QUERY_GUIDE.md`

---

**Happy Building!** 🚀
