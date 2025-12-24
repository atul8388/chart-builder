# Frontend Table Rendering with Filters - Summary

## Quick Answer

To render a table with filters on the UI, send this to the backend:

### 1. Get Distinct Values for Filter Dropdowns
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

**Extract distinct values:**
```javascript
const distinctValues = response.data.map(row => row.field_name);
```

### 2. Get Table Data with Filters
```json
{
  "data": { /* your JSON data */ },
  "dimensions": ["dim1", "dim2"],
  "metrics": [
    { "field": "field1", "aggregation": "sum", "alias": "total" },
    { "field": "field2", "aggregation": "avg", "alias": "average" }
  ],
  "filters": [
    {
      "field": "location",
      "operator": "equals",
      "value": "North Pit"
    }
  ]
}
```

---

## Complete Flow

### Step 1: Load Filter Options
```javascript
async function loadFilterOptions(data) {
  const response = await fetch('/processor/chart-query', {
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
  
  const result = await response.json();
  return result.data.map(row => row.location);
}
```

### Step 2: Load Table Data
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
        { field: 'shifts_feet_mined', aggregation: 'sum', alias: 'total' }
      ],
      filters: filters
    })
  });
  
  const result = await response.json();
  return result.data;
}
```

### Step 3: Build Filters from User Selection
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

---

## Request Structure Breakdown

### For Distinct Values
| Field | Value | Purpose |
|-------|-------|---------|
| `data` | Your JSON | The data to query |
| `dimensions` | `["field_name"]` | The field to get distinct values for |
| `metrics` | `[{field, aggregation: "countDistinct"}]` | Count distinct values |

### For Table Data
| Field | Value | Purpose |
|-------|-------|---------|
| `data` | Your JSON | The data to query |
| `dimensions` | `["dim1", "dim2"]` | Columns to group by |
| `metrics` | Array of metrics | Columns to calculate |
| `filters` | Array of filters | WHERE clause conditions |

---

## Supported Filter Operators

Use these operators in the `filters` array:

| Operator | Example | Use Case |
|----------|---------|----------|
| `equals` | `{ field: "status", operator: "equals", value: "active" }` | Exact match |
| `notEquals` | `{ field: "status", operator: "notEquals", value: "inactive" }` | Not equal |
| `greaterThan` | `{ field: "amount", operator: "greaterThan", value: 100 }` | Greater than |
| `lessThan` | `{ field: "amount", operator: "lessThan", value: 100 }` | Less than |
| `contains` | `{ field: "name", operator: "contains", value: "John" }` | String contains |
| `in` | `{ field: "status", operator: "in", value: ["active", "pending"] }` | In list |
| `between` | `{ field: "date", operator: "between", value: ["2025-01-01", "2025-01-31"] }` | Range |

---

## Aggregation Functions for Metrics

| Function | Purpose | Example |
|----------|---------|---------|
| `sum` | Total | `{ field: "amount", aggregation: "sum" }` |
| `avg` | Average | `{ field: "amount", aggregation: "avg" }` |
| `count` | Count rows | `{ field: "id", aggregation: "count" }` |
| `min` | Minimum | `{ field: "price", aggregation: "min" }` |
| `max` | Maximum | `{ field: "price", aggregation: "max" }` |
| `countDistinct` | Unique count | `{ field: "user_id", aggregation: "countDistinct" }` |
| `first` | First value | `{ field: "date", aggregation: "first" }` |
| `last` | Last value | `{ field: "date", aggregation: "last" }` |

---

## Example: Complete Table with 2 Filters

### HTML
```html
<div>
  <select id="locationFilter">
    <option value="">All Locations</option>
  </select>
  
  <select id="crewFilter">
    <option value="">All Crews</option>
  </select>
  
  <table id="dataTable">
    <thead>
      <tr>
        <th>Location</th>
        <th>Crew</th>
        <th>Total Feet</th>
        <th>Average</th>
      </tr>
    </thead>
    <tbody></tbody>
  </table>
</div>
```

### JavaScript
```javascript
// Load filter options
async function init(data) {
  const locations = await getDistinctValues(data, 'location');
  const crews = await getDistinctValues(data, 'crew_id');
  
  populateSelect('locationFilter', locations);
  populateSelect('crewFilter', crews);
  
  loadTable(data, [], []);
}

// When filters change
document.getElementById('locationFilter').addEventListener('change', (e) => {
  const location = e.target.value;
  const crew = document.getElementById('crewFilter').value;
  const filters = buildFilters(location, crew);
  loadTable(data, filters);
});

// Helper functions
async function getDistinctValues(data, field) {
  const response = await fetch('/processor/chart-query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      data: data,
      dimensions: [field],
      metrics: [{
        field: field,
        aggregation: 'countDistinct',
        alias: 'count'
      }]
    })
  });
  const result = await response.json();
  return result.data.map(row => row[field]);
}

async function loadTable(data, filters) {
  const response = await fetch('/processor/chart-query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      data: data,
      dimensions: ['location', 'crew_id'],
      metrics: [
        { field: 'shifts_feet_mined', aggregation: 'sum', alias: 'total' },
        { field: 'shifts_feet_mined', aggregation: 'avg', alias: 'average' }
      ],
      filters: filters
    })
  });
  const result = await response.json();
  renderTable(result.data);
}
```

---

## Key Takeaways

✅ Use `countDistinct` to get distinct values for filters
✅ Use `dimensions` for grouping/columns
✅ Use `metrics` for calculations
✅ Use `filters` for WHERE conditions
✅ Combine multiple filters in the `filters` array
✅ All done with the existing Chart Query API!

---

## Test It

Run the test script:
```powershell
.\test-distinct-values.ps1
```

This demonstrates:
1. Getting distinct locations
2. Getting distinct crew IDs
3. Getting full table data
4. Filtering by location
5. Filtering by multiple fields

