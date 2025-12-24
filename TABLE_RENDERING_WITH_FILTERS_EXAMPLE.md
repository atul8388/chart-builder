# Complete Table Rendering with Dynamic Filters - Example

## Scenario

You have mining report data and want to render a table with:
- Columns: Location, Crew ID, Total Feet Mined, Average Per Shift
- Filters: Location dropdown, Crew ID dropdown

---

## Step 1: Get Distinct Values for Filters

### Get Distinct Locations
```json
{
  "data": {
    "report_date": "2025-01-20",
    "location": "North Pit",
    "crew_id": "CREW-001",
    "shifts": [
      { "shift_name": "Morning", "feet_mined": 150 },
      { "shift_name": "Evening", "feet_mined": 120 }
    ]
  },
  "dimensions": ["location"],
  "metrics": [
    {
      "field": "location",
      "aggregation": "countDistinct",
      "alias": "count"
    }
  ]
}
```

**Response:**
```json
{
  "data": [
    { "location": "North Pit", "count": 1 },
    { "location": "South Pit", "count": 1 }
  ]
}
```

**Extract:** `["North Pit", "South Pit"]`

---

### Get Distinct Crew IDs
```json
{
  "data": { /* same data */ },
  "dimensions": ["crew_id"],
  "metrics": [
    {
      "field": "crew_id",
      "aggregation": "countDistinct",
      "alias": "count"
    }
  ]
}
```

**Response:**
```json
{
  "data": [
    { "crew_id": "CREW-001", "count": 1 },
    { "crew_id": "CREW-002", "count": 1 }
  ]
}
```

**Extract:** `["CREW-001", "CREW-002"]`

---

## Step 2: Render Table with Filters

### Get Table Data (with optional filters)
```json
{
  "data": { /* same data */ },
  "dimensions": ["location", "crew_id"],
  "metrics": [
    {
      "field": "report_date",
      "aggregation": "first",
      "alias": "date"
    },
    {
      "field": "shifts_feet_mined",
      "aggregation": "sum",
      "alias": "total_feet"
    },
    {
      "field": "shifts_feet_mined",
      "aggregation": "avg",
      "alias": "avg_per_shift"
    }
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

**Response:**
```json
{
  "data": [
    {
      "location": "North Pit",
      "crew_id": "CREW-001",
      "date": "2025-01-20",
      "total_feet": 270,
      "avg_per_shift": 135
    }
  ]
}
```

---

## Complete React Implementation

```javascript
import React, { useState, useEffect } from 'react';

function MiningReportTable({ data }) {
  const [tableData, setTableData] = useState([]);
  const [locations, setLocations] = useState([]);
  const [crews, setCrews] = useState([]);
  const [selectedLocation, setSelectedLocation] = useState('');
  const [selectedCrew, setSelectedCrew] = useState('');
  const [loading, setLoading] = useState(false);

  // Step 1: Load filter options on mount
  useEffect(() => {
    loadFilterOptions();
  }, [data]);

  // Step 2: Load table data when filters change
  useEffect(() => {
    loadTableData();
  }, [selectedLocation, selectedCrew]);

  const loadFilterOptions = async () => {
    try {
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
      setLocations(locData.data.map(row => row.location));

      // Get distinct crews
      const crewResponse = await fetch('/processor/chart-query', {
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
      const crewData = await crewResponse.json();
      setCrews(crewData.data.map(row => row.crew_id));
    } catch (error) {
      console.error('Error loading filter options:', error);
    }
  };

  const loadTableData = async () => {
    setLoading(true);
    try {
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

      const response = await fetch('/processor/chart-query', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          data: data,
          dimensions: ['location', 'crew_id'],
          metrics: [
            {
              field: 'report_date',
              aggregation: 'first',
              alias: 'date'
            },
            {
              field: 'shifts_feet_mined',
              aggregation: 'sum',
              alias: 'total_feet'
            },
            {
              field: 'shifts_feet_mined',
              aggregation: 'avg',
              alias: 'avg_per_shift'
            }
          ],
          filters: filters
        })
      });

      const result = await response.json();
      setTableData(result.data);
    } catch (error) {
      console.error('Error loading table data:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <h2>Mining Report</h2>
      
      {/* Filters */}
      <div style={{ marginBottom: '20px' }}>
        <select 
          value={selectedLocation} 
          onChange={(e) => setSelectedLocation(e.target.value)}
        >
          <option value="">All Locations</option>
          {locations.map(loc => (
            <option key={loc} value={loc}>{loc}</option>
          ))}
        </select>

        <select 
          value={selectedCrew} 
          onChange={(e) => setSelectedCrew(e.target.value)}
        >
          <option value="">All Crews</option>
          {crews.map(crew => (
            <option key={crew} value={crew}>{crew}</option>
          ))}
        </select>
      </div>

      {/* Table */}
      {loading ? (
        <p>Loading...</p>
      ) : (
        <table border="1">
          <thead>
            <tr>
              <th>Location</th>
              <th>Crew ID</th>
              <th>Date</th>
              <th>Total Feet</th>
              <th>Avg Per Shift</th>
            </tr>
          </thead>
          <tbody>
            {tableData.map((row, idx) => (
              <tr key={idx}>
                <td>{row.location}</td>
                <td>{row.crew_id}</td>
                <td>{row.date}</td>
                <td>{row.total_feet}</td>
                <td>{row.avg_per_shift.toFixed(2)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default MiningReportTable;
```

---

## Key Points for Frontend

### 1. Get Distinct Values
```javascript
// Request structure
{
  "data": yourData,
  "dimensions": ["field_name"],
  "metrics": [{
    "field": "field_name",
    "aggregation": "countDistinct",
    "alias": "count"
  }]
}

// Extract values
const distinctValues = response.data.map(row => row.field_name);
```

### 2. Get Table Data with Filters
```javascript
// Add filters to request
{
  "data": yourData,
  "dimensions": ["dim1", "dim2"],
  "metrics": [/* your metrics */],
  "filters": [
    {
      "field": "location",
      "operator": "equals",
      "value": selectedLocation
    }
  ]
}
```

### 3. Combine Multiple Filters
```javascript
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
// Use filters in request
```

---

## Summary

**To render a table with filters:**

1. **Get distinct values** for each filter dimension using `countDistinct`
2. **Populate dropdowns** with those distinct values
3. **Get table data** using dimensions and metrics
4. **Apply filters** when user selects filter values
5. **Update table** with filtered results

All done with the existing **Chart Query API**!

