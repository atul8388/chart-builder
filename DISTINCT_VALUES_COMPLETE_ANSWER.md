# Getting Distinct Values for Table Rendering - Complete Answer

## Your Question
> "If I have to render a table on UI, what information needs to be sent from the frontend to get distinct values for a given dimension?"

## The Answer

To get distinct values for a dimension, send this to the backend:

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

**Endpoint:** `POST /processor/chart-query`

---

## What This Does

1. **`data`** - Your JSON data to query
2. **`dimensions`** - The field you want distinct values for
3. **`metrics`** - Use `countDistinct` aggregation to count unique values

---

## Example

### Request
```json
{
  "data": {
    "reports": [
      { "location": "North Pit", "crew_id": "CREW-001" },
      { "location": "South Pit", "crew_id": "CREW-002" },
      { "location": "North Pit", "crew_id": "CREW-003" }
    ]
  },
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
const distinctLocations = response.data.map(row => row.location);
// Result: ["North Pit", "South Pit"]
```

---

## Complete Table Rendering Flow

### Step 1: Get Distinct Values for Filters
```javascript
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
```

### Step 2: Populate Filter Dropdowns
```javascript
const locations = await getDistinctValues(data, 'location');
const crews = await getDistinctValues(data, 'crew_id');

// Populate dropdowns
populateSelect('locationFilter', locations);
populateSelect('crewFilter', crews);
```

### Step 3: Get Table Data with Filters
```javascript
async function getTableData(data, filters) {
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
  return (await response.json()).data;
}
```

### Step 4: Handle Filter Changes
```javascript
document.getElementById('locationFilter').addEventListener('change', async (e) => {
  const selectedLocation = e.target.value;
  const selectedCrew = document.getElementById('crewFilter').value;
  
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
  
  const tableData = await getTableData(data, filters);
  renderTable(tableData);
});
```

---

## Key Information to Send

### For Distinct Values
| Field | Value |
|-------|-------|
| `data` | Your JSON data |
| `dimensions` | `["field_name"]` |
| `metrics` | `[{ field: "field_name", aggregation: "countDistinct" }]` |

### For Table Data
| Field | Value |
|-------|-------|
| `data` | Your JSON data |
| `dimensions` | `["dim1", "dim2"]` |
| `metrics` | Array of metrics to calculate |
| `filters` | Array of filter conditions |

---

## Supported Aggregations

For getting distinct values, use:
- **`countDistinct`** - Count unique values ✅

For table metrics, use:
- `sum`, `avg`, `count`, `min`, `max`, `median`, `std`, `first`, `last`

---

## Supported Filter Operators

When filtering, use:
- `equals`, `notEquals`
- `greaterThan`, `lessThan`, `greaterThanOrEqual`, `lessThanOrEqual`
- `contains`, `notContains`
- `in`, `notIn`
- `isNull`, `isNotNull`
- `between`

---

## Complete React Component Example

```javascript
import React, { useState, useEffect } from 'react';

function TableWithFilters({ data }) {
  const [locations, setLocations] = useState([]);
  const [crews, setCrews] = useState([]);
  const [tableData, setTableData] = useState([]);
  const [selectedLocation, setSelectedLocation] = useState('');
  const [selectedCrew, setSelectedCrew] = useState('');

  // Load filter options on mount
  useEffect(() => {
    loadFilterOptions();
  }, [data]);

  // Load table data when filters change
  useEffect(() => {
    loadTableData();
  }, [selectedLocation, selectedCrew]);

  const loadFilterOptions = async () => {
    const locRes = await fetch('/processor/chart-query', {
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
    const locData = await locRes.json();
    setLocations(locData.data.map(row => row.location));

    const crewRes = await fetch('/processor/chart-query', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        data: data,
        dimensions: ['crew_id'],
        metrics: [{
          field: 'crew_id',
          aggregation: 'countDistinct',
          alias: 'count'
        }]
      })
    });
    const crewData = await crewRes.json();
    setCrews(crewData.data.map(row => row.crew_id));
  };

  const loadTableData = async () => {
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

    const res = await fetch('/processor/chart-query', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        data: data,
        dimensions: ['location', 'crew_id'],
        metrics: [
          { field: 'shifts_feet_mined', aggregation: 'sum', alias: 'total' }
        ],
        filters: filters
      })
    });
    const result = await res.json();
    setTableData(result.data);
  };

  return (
    <div>
      <select value={selectedLocation} onChange={e => setSelectedLocation(e.target.value)}>
        <option value="">All Locations</option>
        {locations.map(loc => <option key={loc} value={loc}>{loc}</option>)}
      </select>

      <select value={selectedCrew} onChange={e => setSelectedCrew(e.target.value)}>
        <option value="">All Crews</option>
        {crews.map(crew => <option key={crew} value={crew}>{crew}</option>)}
      </select>

      <table>
        <thead>
          <tr>
            <th>Location</th>
            <th>Crew</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          {tableData.map((row, i) => (
            <tr key={i}>
              <td>{row.location}</td>
              <td>{row.crew_id}</td>
              <td>{row.total}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

export default TableWithFilters;
```

---

## Summary

**To get distinct values for a dimension:**

1. Send `POST /processor/chart-query`
2. Include `data`, `dimensions`, and `metrics` with `countDistinct`
3. Extract values from response using `map()`
4. Populate filter dropdowns
5. Get table data with filters applied
6. Update table when filters change

**All done with the existing Chart Query API!**

---

## Documentation Files

- **DISTINCT_VALUES_QUICK_REFERENCE.md** - Quick reference card
- **DISTINCT_VALUES_IMPLEMENTATION_GUIDE.md** - Complete guide
- **TABLE_RENDERING_WITH_FILTERS_EXAMPLE.md** - React example
- **DISTINCT_VALUES_API_EXAMPLES.md** - Request/response examples
- **test-distinct-values.ps1** - Test script

