# First/Last Aggregation - Practical Examples

## Example 1: Mining Report with Multiple Shifts

### Data Structure
```json
{
  "report_date": "2025-01-20",
  "location": "North Pit",
  "crew_id": "CREW-001",
  "supervisor": "John Smith",
  "shifts": [
    { "shift_name": "Morning", "feet_mined": 150, "workers": 5 },
    { "shift_name": "Evening", "feet_mined": 120, "workers": 4 },
    { "shift_name": "Night", "feet_mined": 100, "workers": 3 }
  ]
}
```

### Query: Get Report Info + Total Production
```json
{
  "dimensions": ["location"],
  "metrics": [
    { "field": "report_date", "aggregation": "first", "alias": "date" },
    { "field": "crew_id", "aggregation": "first", "alias": "crew" },
    { "field": "supervisor", "aggregation": "first", "alias": "supervisor" },
    { "field": "shifts_feet_mined", "aggregation": "sum", "alias": "total_feet" },
    { "field": "shifts_feet_mined", "aggregation": "avg", "alias": "avg_per_shift" },
    { "field": "shifts_workers", "aggregation": "sum", "alias": "total_workers" }
  ]
}
```

### Result
```json
{
  "location": "North Pit",
  "date": "2025-01-20",
  "crew": "CREW-001",
  "supervisor": "John Smith",
  "total_feet": 370,
  "avg_per_shift": 123.33,
  "total_workers": 12
}
```

## Example 2: Equipment Downtime Report

### Data Structure
```json
{
  "equipment_id": "EQ-001",
  "equipment_name": "Excavator A",
  "location": "North Pit",
  "maintenance_date": "2025-01-20",
  "downtime_events": [
    { "event_type": "Hydraulic Leak", "duration_hours": 2 },
    { "event_type": "Engine Overheat", "duration_hours": 1.5 },
    { "event_type": "Belt Replacement", "duration_hours": 3 }
  ]
}
```

### Query: Equipment Info + Downtime Analysis
```json
{
  "dimensions": ["equipment_id"],
  "metrics": [
    { "field": "equipment_name", "aggregation": "first" },
    { "field": "location", "aggregation": "first" },
    { "field": "maintenance_date", "aggregation": "first" },
    { "field": "downtime_events_duration_hours", "aggregation": "sum", "alias": "total_downtime" },
    { "field": "downtime_events_duration_hours", "aggregation": "count", "alias": "event_count" },
    { "field": "downtime_events_duration_hours", "aggregation": "avg", "alias": "avg_downtime" }
  ]
}
```

### Result
```json
{
  "equipment_id": "EQ-001",
  "equipment_name": "Excavator A",
  "location": "North Pit",
  "maintenance_date": "2025-01-20",
  "total_downtime": 6.5,
  "event_count": 3,
  "avg_downtime": 2.17
}
```

## Example 3: Production Report with Multiple Items

### Data Structure
```json
{
  "report_id": "RPT-2025-001",
  "facility_name": "Main Plant",
  "supervisor": "Jane Doe",
  "report_date": "2025-01-20",
  "items": [
    { "item_id": "ITEM-1", "quantity": 100, "quality_score": 95 },
    { "item_id": "ITEM-2", "quantity": 150, "quality_score": 92 },
    { "item_id": "ITEM-3", "quantity": 120, "quality_score": 98 }
  ]
}
```

### Query: Report Summary + Production Metrics
```json
{
  "metrics": [
    { "field": "report_id", "aggregation": "first" },
    { "field": "facility_name", "aggregation": "first" },
    { "field": "supervisor", "aggregation": "first" },
    { "field": "report_date", "aggregation": "first" },
    { "field": "items_quantity", "aggregation": "sum", "alias": "total_quantity" },
    { "field": "items_quantity", "aggregation": "avg", "alias": "avg_per_item" },
    { "field": "items_quality_score", "aggregation": "avg", "alias": "avg_quality" },
    { "field": "items_quality_score", "aggregation": "min", "alias": "min_quality" },
    { "field": "items_quality_score", "aggregation": "max", "alias": "max_quality" }
  ]
}
```

### Result
```json
{
  "report_id": "RPT-2025-001",
  "facility_name": "Main Plant",
  "supervisor": "Jane Doe",
  "report_date": "2025-01-20",
  "total_quantity": 370,
  "avg_per_item": 123.33,
  "avg_quality": 95,
  "min_quality": 92,
  "max_quality": 98
}
```

## Example 4: Multi-Dimension Report

### Query: Group by Location + Get Header Info
```json
{
  "dimensions": ["location"],
  "metrics": [
    { "field": "report_date", "aggregation": "first" },
    { "field": "supervisor", "aggregation": "first" },
    { "field": "shifts_feet_mined", "aggregation": "sum", "alias": "total_feet" },
    { "field": "shifts_workers", "aggregation": "sum", "alias": "total_workers" }
  ]
}
```

### Result
```json
[
  {
    "location": "North Pit",
    "report_date": "2025-01-20",
    "supervisor": "John Smith",
    "total_feet": 370,
    "total_workers": 12
  },
  {
    "location": "South Pit",
    "report_date": "2025-01-20",
    "supervisor": "Jane Doe",
    "total_feet": 280,
    "total_workers": 10
  }
]
```

## Key Takeaways

✅ Use `first` for scalar fields that are repeated
✅ Use `last` when you need the final state
✅ Combine with other aggregations (sum, avg, count, etc.)
✅ Works with single and multi-dimension queries
✅ Perfect for reports with header + detail data

