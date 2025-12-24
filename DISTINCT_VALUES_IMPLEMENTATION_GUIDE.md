# Getting Distinct Values for Table Rendering - Complete Implementation Guide

## Quick Summary

To render a table with filters on the UI, you need to:

1. **Get distinct values** for each filter dimension
2. **Populate dropdowns** with those values
3. **Get table data** with applied filters
4. **Update table** when filters change

All using the existing **Chart Query API** endpoint.

---

## What Information to Send from Frontend

### To Get Distinct Values
```json
{
  "data": { /* your JSON data */ },
  "dimensions": ["field_name"],
  "metrics": [{
    "field": "field_name",
    "aggregation": "countDistinct",
    "alias": "count"
  }]
}
```

### To Get Table Data
```json
{
  "data": { /* your JSON data */ },
  "dimensions": ["dim1", "dim2"],
  "metrics": [
    { "field": "field1", "aggregation": "sum", "alias": "total" },
    { "field": "field2", "aggregation": "avg", "alias": "average" }
  ],
  "filters": [
    { "field": "location", "operator": "equals", "value": "North Pit" }
  ]
}
```

---

## Step-by-Step Implementation

### Step 1: Load Filter Options on Component Mount
```javascript
async function loadFilterOptions(data) {
  // Get distinct locations
  const locResponse = await fetch('/processor/chart-query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      data: data,
      dimensions: ['location'],
      metrics: [{
        field: 'location',
        aggregation: 'countDistinct',
        alias: 'count'
      }]
    })
  });
  
  const locData = await locResponse.json();
  const locations = locData.data.map(row => row.location);
  
  // Repeat for other dimensions...
  return { locations, crews, supervisors };
}
```

### Step 2: Build Filters from User Selection
```javascript
function buildFilters(selectedLocation, selectedCrew) {
  const filters = [];
  
  if (selectedLocation) {
    filters.push({
      field: 'location',
      operator: 'equals',
      value: selectedLocation
    });
  }
  
  if (selectedCrew) {
    filters.push({
      field: 'crew_id',
      operator: 'equals',
      value: selectedCrew
    });
  }
  
  return filters;
}
```

### Step 3: Load Table Data with Filters
```javascript
async function loadTableData(data, filters) {
  const response = await fetch('/processor/chart-query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      data: data,
      dimensions: ['location', 'crew_id'],
      metrics: [
        { field: 'report_date', aggregation: 'first' },
        { field: 'shifts_feet_mined', aggregation: 'sum', alias: 'total' },
        { field: 'shifts_feet_mined', aggregation: 'avg', alias: 'average' }
      ],
      filters: filters
    })
  });
  
  const result = await response.json();
  return result.data;
}
```

### Step 4: Handle Filter Changes
```javascript
// When user changes a filter
document.getElementById('locationFilter').addEventListener('change', (e) => {
  const selectedLocation = e.target.value;
  const selectedCrew = document.getElementById('crewFilter').value;
  
  const filters = buildFilters(selectedLocation, selectedCrew);
  const tableData = await loadTableData(data, filters);
  
  renderTable(tableData);
});
```

---

## Complete Request/Response Examples

### Request: Get Distinct Locations
```json
{
  "data": { /* your data */ },
  "dimensions": ["location"],
  "metrics": [{
    "field": "location",
    "aggregation": "countDistinct",
    "alias": "count"
  }]
}
```

### Response
```json
{
  "success": true,
  "data": [
    { "location": "North Pit", "count": 1 },
    { "location": "South Pit", "count": 1 }
  ]
}
```

### Extract Distinct Values
```javascript
const locations = response.data.map(row => row.location);
// ["North Pit", "South Pit"]
```

---

## Supported Aggregations for Metrics

| Function | Use Case |
|----------|----------|
| `sum` | Total amount |
| `avg` | Average value |
| `count` | Number of records |
| `min` | Minimum value |
| `max` | Maximum value |
| `countDistinct` | Unique count |
| `first` | First value (for scalar fields) |
| `last` | Last value (for scalar fields) |

---

## Supported Filter Operators

| Operator | Example |
|----------|---------|
| `equals` | `{ field: "status", operator: "equals", value: "active" }` |
| `notEquals` | `{ field: "status", operator: "notEquals", value: "inactive" }` |
| `greaterThan` | `{ field: "amount", operator: "greaterThan", value: 100 }` |
| `lessThan` | `{ field: "amount", operator: "lessThan", value: 100 }` |
| `contains` | `{ field: "name", operator: "contains", value: "John" }` |
| `in` | `{ field: "status", operator: "in", value: ["active", "pending"] }` |
| `between` | `{ field: "date", operator: "between", value: ["2025-01-01", "2025-01-31"] }` |

---

## Performance Tips

1. **Cache distinct values** - Don't fetch on every render
2. **Debounce filter changes** - Wait before fetching new data
3. **Use pagination** - For large result sets, add `limit` and `offset`
4. **Lazy load** - Load filter options only when dropdown opens
5. **Batch requests** - Get multiple distinct values in parallel

---

## Testing

Run the test script to see all examples:
```powershell
.\test-distinct-values.ps1
```

This demonstrates:
- Getting distinct locations
- Getting distinct crew IDs
- Getting full table data
- Filtering by single field
- Filtering by multiple fields

---

## Documentation Files

- **DIMENSION_DISTINCT_VALUES_GUIDE.md** - Detailed guide
- **TABLE_RENDERING_WITH_FILTERS_EXAMPLE.md** - Complete React example
- **DISTINCT_VALUES_API_EXAMPLES.md** - Request/response examples
- **FRONTEND_TABLE_RENDERING_SUMMARY.md** - Quick reference
- **test-distinct-values.ps1** - Test script

---

## Key Takeaways

✅ Use `countDistinct` aggregation to get distinct values
✅ Use `dimensions` to specify which field to get distinct values for
✅ Use `filters` to get conditional distinct values
✅ Combine with table data queries for complete filtering
✅ All done with the existing Chart Query API!

No new endpoints needed - everything works with `/processor/chart-query`

