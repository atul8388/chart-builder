# Scalar Field Repetition Issue - Problem & Solution

## The Problem

When you have header-level (scalar) data that gets repeated for each array item, aggregating those scalar fields produces incorrect results.

### Example Data Structure

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

### After Flattening (Current Behavior)

```
rn | report_date | location   | crew_id    | shifts_shift_name | shifts_feet_mined
---|-------------|------------|------------|-------------------|------------------
1  | 2025-01-20  | North Pit  | CREW-001   | Morning           | 150
2  | 2025-01-20  | North Pit  | CREW-001   | Evening           | 120
3  | 2025-01-20  | North Pit  | CREW-001   | Night             | 100
```

### The Issue When Aggregating

If you try to aggregate `report_date` or `location` with `sum` or `count`:

```json
{
  "dimensions": ["location"],
  "metrics": [
    { "field": "report_date", "aggregation": "sum", "alias": "date_sum" }
  ]
}
```

**Problem:** The scalar field `report_date` is repeated 3 times, so aggregating it gives wrong results!

## Solution: Add `first` and `last` Aggregations

For scalar fields that are repeated, we need aggregation functions that:
- **`first`** - Get the first value (since all are the same)
- **`last`** - Get the last value (since all are the same)
- **`distinctCount`** - Count unique values (should be 1 for scalar fields)

### Example Usage

```json
{
  "dimensions": ["location"],
  "metrics": [
    { "field": "report_date", "aggregation": "first", "alias": "report_date" },
    { "field": "crew_id", "aggregation": "first", "alias": "crew_id" },
    { "field": "shifts_feet_mined", "aggregation": "sum", "alias": "total_feet" }
  ]
}
```

### Expected Result

```json
{
  "location": "North Pit",
  "report_date": "2025-01-20",
  "crew_id": "CREW-001",
  "total_feet": 370
}
```

## Implementation Plan

1. Add `first` aggregation function
2. Add `last` aggregation function
3. Update MetricDefinition DTO to include new types
4. Update groupAndAggregate() method in polars-rowpad.service.ts
5. Update aggregateAll() method for consistency
6. Update documentation

## Benefits

✅ Correctly handle scalar fields in aggregations
✅ No data loss or duplication
✅ Intuitive for users
✅ Consistent with SQL behavior
✅ Works with all dimension combinations

