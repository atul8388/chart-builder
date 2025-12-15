# Null Value Handling Guide

## Overview

The BI Analytics API treats **null values as 0** for all numeric operations including filtering, aggregations, and sorting. This ensures consistent behavior and prevents null-related errors in chart data.

---

## Null Handling Behavior

### ✅ **Null = 0 Rule**

All helper functions in the Polars service automatically convert `null` and `undefined` values to `0` when performing:
- **Filtering** - Numeric comparisons
- **Aggregations** - Sum, avg, min, max, median, std
- **Sorting** - Numeric field sorting

---

## Functions Updated

### 1. **applyFilters()**
Treats null as 0 for all numeric filter operators.

**Operators Affected:**
- `equals`
- `notEquals`
- `greaterThan`
- `lessThan`
- `greaterThanOrEqual`
- `lessThanOrEqual`

**Example:**
```typescript
// Filter: amount > 100
// Row with amount = null is treated as amount = 0
// Result: Row is excluded (0 is not > 100)

// Filter: amount = 0
// Row with amount = null is treated as amount = 0
// Result: Row is included (0 = 0)
```

---

### 2. **groupAndAggregate()**
Treats null as 0 for all numeric aggregations.

**Aggregations Affected:**
- `sum` - Null values contribute 0 to the sum
- `avg` - Null values are treated as 0 in average calculation
- `min` - Null values are treated as 0 for minimum
- `max` - Null values are treated as 0 for maximum
- `median` - Null values are treated as 0 for median
- `std` - Null values are treated as 0 for standard deviation

**Not Affected:**
- `count` - Counts all rows (including nulls)
- `countDistinct` - Counts unique values (including null as a unique value)

**Example:**
```json
// Data
[
  { "category": "A", "amount": 100 },
  { "category": "A", "amount": null },
  { "category": "A", "amount": 50 }
]

// Query: sum(amount) group by category
// Result: { "category": "A", "total_amount": 150 }
// Calculation: 100 + 0 + 50 = 150
```

---

### 3. **aggregateAll()**
Treats null as 0 for all numeric aggregations (same as groupAndAggregate).

**Example:**
```json
// Data
[
  { "amount": 100 },
  { "amount": null },
  { "amount": 50 }
]

// Query: sum(amount)
// Result: { "total_amount": 150 }
// Calculation: 100 + 0 + 50 = 150
```

---

### 4. **sortResults()**
Treats null as 0 for numeric field sorting.

**Example:**
```json
// Data
[
  { "name": "A", "score": 100 },
  { "name": "B", "score": null },
  { "name": "C", "score": 50 }
]

// Sort by score (asc)
// Result:
[
  { "name": "B", "score": null },  // Treated as 0
  { "name": "C", "score": 50 },
  { "name": "A", "score": 100 }
]
```

---

## Implementation Details

### Polars fillNull() Method

All numeric operations use Polars' `fillNull(0)` method:

```typescript
// Before aggregation
pl.col(metric.field).fillNull(0).sum().alias(alias)

// Before filtering
pl.col(column).fillNull(0).gt(filter.value)
```

### JavaScript Null Handling

For sorting (JavaScript-based), explicit null checks:

```typescript
let aVal = a[sortDef.field];
let bVal = b[sortDef.field];

// Treat null/undefined as 0
if (aVal === null || aVal === undefined) aVal = 0;
if (bVal === null || bVal === undefined) bVal = 0;
```

---

## Use Cases

### Production Report Example

**Scenario:** Some cuts have no data (null values)

```json
{
  "cut_total_feet-1": "15",
  "cut_total_feet-2": "20",
  "cut_total_feet-3": "",      // Empty string → null
  "cut_total_feet-4": null,
  "cut_total_feet-5": "10"
}
```

**Query:** Sum of total feet

```json
{
  "metrics": [
    { "field": "cut_total_feet", "aggregation": "sum", "alias": "total_feet" }
  ]
}
```

**Result:**
```json
{
  "total_feet": 45
}
```

**Calculation:** 15 + 20 + 0 + 0 + 10 = 45

---

### Downtime Analysis Example

**Scenario:** Some downtime records are incomplete

```json
[
  { "equipment": "EQ_01", "duration": 30 },
  { "equipment": "EQ_02", "duration": null },
  { "equipment": "EQ_03", "duration": 15 }
]
```

**Query:** Total downtime by equipment

```json
{
  "dimensions": ["equipment"],
  "metrics": [
    { "field": "duration", "aggregation": "sum", "alias": "total_downtime" }
  ]
}
```

**Result:**
```json
[
  { "equipment": "EQ_01", "total_downtime": 30 },
  { "equipment": "EQ_02", "total_downtime": 0 },   // null treated as 0
  { "equipment": "EQ_03", "total_downtime": 15 }
]
```

---

## Benefits

### ✅ **Consistent Behavior**
- No unexpected null errors
- Predictable aggregation results
- Charts render without null-related issues

### ✅ **Simplified Data Preparation**
- No need to pre-fill null values
- Works with incomplete data
- Handles empty strings automatically

### ✅ **Better User Experience**
- Charts always display
- No missing data errors
- Intuitive behavior (null = no value = 0)

---

## Important Notes

### 1. **Empty Strings**
Empty strings (`""`) in the source data are converted to `null` during flattening, then treated as `0` in aggregations.

### 2. **Count Aggregations**
The `count` aggregation counts all rows, including those with null values:

```json
// Data: [100, null, 50]
// count() = 3 (includes null)
// sum() = 150 (null treated as 0)
```

### 3. **String Fields**
Null handling only applies to numeric operations. String fields with null values:
- Are preserved as null in grouping dimensions
- Are not converted to "0" string

---

## Testing

All test scripts have been updated to work with null handling:

- ✅ `test-chart-query.ps1`
- ✅ `test-chart-query-advanced.ps1`
- ✅ `test-production-report.ps1`

---

## Summary

**All numeric operations treat null as 0:**

| Operation | Null Handling |
|-----------|---------------|
| Filtering (>, <, =, etc.) | null → 0 |
| Sum aggregation | null → 0 |
| Average aggregation | null → 0 |
| Min/Max aggregation | null → 0 |
| Median aggregation | null → 0 |
| Std aggregation | null → 0 |
| Count aggregation | Counts nulls |
| Sorting | null → 0 |

**This ensures robust, error-free chart data generation!** ✅

