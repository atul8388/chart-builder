# Filtering Non-Empty Values - Complete Guide

## Overview

You can now filter data to display only rows where specific fields are **not empty** (non-null). This is useful for:

- Hiding rows with missing data
- Showing only completed records
- Filtering out placeholder values
- Displaying only valid data

---

## Quick Answer

To filter and display only non-empty data, use the **`isNotNull`** operator:

```json
{
  "data": {
    /* your JSON */
  },
  "dimensions": ["location"],
  "metrics": [{ "field": "amount", "aggregation": "sum" }],
  "filters": [
    {
      "field": "field_name",
      "operator": "isNotNull",
      "value": null
    }
  ]
}
```

---

## All Supported Filter Operators

### Null/Empty Checks ⭐ NEW

| Operator     | Purpose                     | Example                                      | Result                                   |
| ------------ | --------------------------- | -------------------------------------------- | ---------------------------------------- |
| `isNotNull`  | Show non-null data          | `{ field: "email", operator: "isNotNull" }`  | Rows where email is not null             |
| `isNull`     | Show null data              | `{ field: "email", operator: "isNull" }`     | Rows where email is null                 |
| `isNotEmpty` | Show non-empty strings ("") | `{ field: "email", operator: "isNotEmpty" }` | Rows where email is not empty string     |
| `isEmpty`    | Show empty strings ("")     | `{ field: "email", operator: "isEmpty" }`    | Rows where email is empty string or null |

### String Filters ⭐ NEW

| Operator      | Purpose                 | Example                                                     |
| ------------- | ----------------------- | ----------------------------------------------------------- |
| `contains`    | String contains value   | `{ field: "name", operator: "contains", value: "John" }`    |
| `notContains` | String does not contain | `{ field: "name", operator: "notContains", value: "spam" }` |

### List Filters ⭐ NEW

| Operator | Purpose           | Example                                                             |
| -------- | ----------------- | ------------------------------------------------------------------- |
| `in`     | Value in list     | `{ field: "status", operator: "in", value: ["active", "pending"] }` |
| `notIn`  | Value not in list | `{ field: "status", operator: "notIn", value: ["cancelled"] }`      |

### Range Filters ⭐ NEW

| Operator  | Purpose        | Example                                                      |
| --------- | -------------- | ------------------------------------------------------------ |
| `between` | Value in range | `{ field: "price", operator: "between", value: [100, 500] }` |

### Comparison Filters (Existing)

| Operator             | Purpose               |
| -------------------- | --------------------- |
| `equals`             | Exact match           |
| `notEquals`          | Not equal             |
| `greaterThan`        | Greater than          |
| `lessThan`           | Less than             |
| `greaterThanOrEqual` | Greater than or equal |
| `lessThanOrEqual`    | Less than or equal    |

---

## Use Cases

### 1. Show Only Non-Empty Email Addresses

```json
{
  "data": {
    /* your data */
  },
  "dimensions": ["user_id"],
  "metrics": [{ "field": "name", "aggregation": "first" }],
  "filters": [
    {
      "field": "email",
      "operator": "isNotNull"
    }
  ]
}
```

**Result:** Only rows with email addresses are displayed

---

### 2. Show Only Completed Orders

```json
{
  "data": {
    /* your data */
  },
  "dimensions": ["order_id"],
  "metrics": [
    { "field": "amount", "aggregation": "sum" },
    { "field": "items", "aggregation": "count" }
  ],
  "filters": [
    {
      "field": "completion_date",
      "operator": "isNotNull"
    },
    {
      "field": "status",
      "operator": "equals",
      "value": "completed"
    }
  ]
}
```

**Result:** Only completed orders with completion dates

---

### 3. Show Only Records with Valid Data

```json
{
  "data": {
    /* your data */
  },
  "dimensions": ["location"],
  "metrics": [{ "field": "production", "aggregation": "sum" }],
  "filters": [
    { "field": "location", "operator": "isNotNull" },
    { "field": "production", "operator": "isNotNull" },
    { "field": "supervisor", "operator": "isNotNull" }
  ]
}
```

**Result:** Only rows with all three fields populated

---

### 4. Show Data with Specific Status Values

```json
{
  "data": {
    /* your data */
  },
  "dimensions": ["report_id"],
  "metrics": [{ "field": "amount", "aggregation": "sum" }],
  "filters": [
    {
      "field": "status",
      "operator": "in",
      "value": ["active", "pending", "review"]
    }
  ]
}
```

**Result:** Only rows with status in the specified list

---

### 5. Show Data in Price Range

```json
{
  "data": {
    /* your data */
  },
  "dimensions": ["product_id"],
  "metrics": [{ "field": "quantity", "aggregation": "sum" }],
  "filters": [
    {
      "field": "price",
      "operator": "between",
      "value": [100, 500]
    }
  ]
}
```

**Result:** Only products with price between 100 and 500

---

### 6. Show Data Containing Specific Text

```json
{
  "data": {
    /* your data */
  },
  "dimensions": ["user_id"],
  "metrics": [{ "field": "count", "aggregation": "sum" }],
  "filters": [
    {
      "field": "name",
      "operator": "contains",
      "value": "John"
    }
  ]
}
```

**Result:** Only rows where name contains "John"

---

## Complete Request Examples

### Example 1: Mining Report - Non-Empty Locations

```json
{
  "data": {
    "reports": [
      {
        "location": "North Pit",
        "crew_id": "CREW-001",
        "shifts": [{ "feet_mined": 150 }]
      },
      {
        "location": null,
        "crew_id": "CREW-002",
        "shifts": [{ "feet_mined": 100 }]
      }
    ]
  },
  "dimensions": ["location"],
  "metrics": [
    { "field": "shifts_feet_mined", "aggregation": "sum", "alias": "total" }
  ],
  "filters": [
    {
      "field": "location",
      "operator": "isNotNull"
    }
  ]
}
```

**Response:** Only "North Pit" row (null location is filtered out)

---

### Example 2: Multiple Non-Empty Filters

```json
{
  "data": {
    /* your data */
  },
  "dimensions": ["location", "crew_id"],
  "metrics": [
    { "field": "shifts_feet_mined", "aggregation": "sum", "alias": "total" }
  ],
  "filters": [
    { "field": "location", "operator": "isNotNull" },
    { "field": "crew_id", "operator": "isNotNull" },
    { "field": "shifts_feet_mined", "operator": "greaterThan", "value": 0 }
  ]
}
```

**Result:** Only rows with all three fields populated and production > 0

---

## Frontend Implementation

### React Example

```javascript
async function getFilteredData(data, filters) {
  const response = await fetch('/processor/chart-query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      data: data,
      dimensions: ['location', 'crew_id'],
      metrics: [
        { field: 'shifts_feet_mined', aggregation: 'sum', alias: 'total' },
      ],
      filters: filters,
    }),
  });
  return (await response.json()).data;
}

// Usage: Show only non-empty locations
const filters = [
  {
    field: 'location',
    operator: 'isNotNull',
  },
];

const filteredData = await getFilteredData(data, filters);
```

---

## Key Points

✅ Use `isNotNull` to show non-empty data
✅ Use `isNull` to show empty data
✅ Combine multiple filters for complex queries
✅ Works with all field types
✅ No value needed for `isNull` and `isNotNull`
✅ All filters are applied together (AND logic)

---

## Supported Operators Summary

| Category        | Operators                                                                                 |
| --------------- | ----------------------------------------------------------------------------------------- |
| **Null Checks** | `isNull`, `isNotNull`                                                                     |
| **String**      | `contains`, `notContains`                                                                 |
| **List**        | `in`, `notIn`                                                                             |
| **Range**       | `between`                                                                                 |
| **Comparison**  | `equals`, `notEquals`, `greaterThan`, `lessThan`, `greaterThanOrEqual`, `lessThanOrEqual` |

---

## Implementation Details

### Files Modified

- `src/processor/polars-rowpad.service.ts` - Updated `applyFilters()` method

### New Filter Cases Added

- `isNull` - `pl.col(column).isNull()`
- `isNotNull` - `pl.col(column).isNotNull()`
- `contains` - `pl.col(column).cast(pl.Utf8).str.contains(value)`
- `notContains` - `pl.col(column).cast(pl.Utf8).str.contains(value).not()`
- `in` - `pl.col(column).isIn(value)`
- `notIn` - `pl.col(column).isIn(value).not()`
- `between` - `pl.col(column).gtEq(min).and(pl.col(column).ltEq(max))`

---

## Testing

Run the test script:

```powershell
.\test-non-empty-filters.ps1
```

This tests:

1. Filtering non-empty values
2. Filtering empty values
3. String contains filter
4. List filter (in)
5. Range filter (between)
6. Multiple filters combined
