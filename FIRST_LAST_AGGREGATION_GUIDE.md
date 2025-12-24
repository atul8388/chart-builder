# First/Last Aggregation Functions - Complete Guide

## Problem Solved

When you have header-level (scalar) data that gets repeated for each array item row, aggregating those scalar fields produces incorrect results.

### Example Scenario

**Input Data:**
```json
{
  "report_date": "2025-01-20",
  "location": "North Pit",
  "crew_id": "CREW-001",
  "shifts": [
    { "shift_name": "Morning", "feet_mined": 150 },
    { "shift_name": "Evening", "feet_mined": 120 },
    { "shift_name": "Night", "feet_mined": 100 }
  ]
}
```

**After Flattening (3 rows):**
```
rn | report_date | location   | crew_id    | shifts_shift_name | shifts_feet_mined
---|-------------|------------|------------|-------------------|------------------
1  | 2025-01-20  | North Pit  | CREW-001   | Morning           | 150
2  | 2025-01-20  | North Pit  | CREW-001   | Evening           | 120
3  | 2025-01-20  | North Pit  | CREW-001   | Night             | 100
```

**Problem:** Scalar fields are repeated! Using `sum` on `report_date` would be wrong.

## Solution: `first` and `last` Aggregations

### `first` - Get the first value
Returns the first value in the group (perfect for scalar fields that are repeated).

```json
{
  "dimensions": ["location"],
  "metrics": [
    { "field": "report_date", "aggregation": "first", "alias": "date" },
    { "field": "crew_id", "aggregation": "first", "alias": "crew" },
    { "field": "shifts_feet_mined", "aggregation": "sum", "alias": "total_feet" }
  ]
}
```

**Result:**
```json
{
  "location": "North Pit",
  "date": "2025-01-20",
  "crew": "CREW-001",
  "total_feet": 370
}
```

### `last` - Get the last value
Returns the last value in the group (useful when you want the final state).

```json
{
  "dimensions": ["location"],
  "metrics": [
    { "field": "report_date", "aggregation": "last", "alias": "date" },
    { "field": "crew_id", "aggregation": "last", "alias": "crew" },
    { "field": "shifts_feet_mined", "aggregation": "sum", "alias": "total_feet" }
  ]
}
```

## Use Cases

### 1. Mining Report with Multiple Shifts
Get the report date and crew ID (scalar) along with total feet mined (array):

```json
{
  "dimensions": ["location"],
  "metrics": [
    { "field": "report_date", "aggregation": "first" },
    { "field": "crew_id", "aggregation": "first" },
    { "field": "shifts_feet_mined", "aggregation": "sum" }
  ]
}
```

### 2. Equipment Downtime with Multiple Events
Get equipment info (scalar) and total downtime (array):

```json
{
  "dimensions": ["equipment_id"],
  "metrics": [
    { "field": "equipment_name", "aggregation": "first" },
    { "field": "location", "aggregation": "first" },
    { "field": "downtime_events_duration", "aggregation": "sum" }
  ]
}
```

### 3. Production Report with Multiple Items
Get report metadata (scalar) and production metrics (array):

```json
{
  "dimensions": ["report_date"],
  "metrics": [
    { "field": "facility_name", "aggregation": "first" },
    { "field": "supervisor", "aggregation": "first" },
    { "field": "items_quantity", "aggregation": "sum" },
    { "field": "items_quantity", "aggregation": "avg" }
  ]
}
```

## Implementation Details

### Files Modified
- `src/processor/dto/chart-query.dto.ts` - Added `first` and `last` to MetricDefinition
- `src/processor/polars-rowpad.service.ts` - Implemented in groupAndAggregate() and aggregateAll()

### Polars Functions Used
- `pl.col(field).first()` - Gets first value
- `pl.col(field).last()` - Gets last value

## Complete Aggregation Functions List

| Function | Purpose |
|----------|---------|
| `sum` | Sum all values |
| `avg` | Average of values |
| `count` | Count rows |
| `min` | Minimum value |
| `max` | Maximum value |
| `median` | Median value |
| `std` | Standard deviation |
| `countDistinct` | Count unique values |
| **`first`** | **Get first value (for scalar fields)** |
| **`last`** | **Get last value (for scalar fields)** |

## Testing

Run the test script:
```powershell
.\test-first-last-aggregation.ps1
```

This tests:
1. Using `first` aggregation
2. Using `last` aggregation
3. Mixed aggregations with first/last and other functions

