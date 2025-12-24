# Distinct Values API - Request/Response Examples

## Endpoint
```
POST /processor/chart-query
```

---

## Example 1: Get Distinct Locations

### Request
```json
{
  "data": {
    "reports": [
      {
        "location": "North Pit",
        "crew_id": "CREW-001",
        "shifts": [
          { "feet_mined": 150 },
          { "feet_mined": 120 }
        ]
      },
      {
        "location": "South Pit",
        "crew_id": "CREW-002",
        "shifts": [
          { "feet_mined": 100 }
        ]
      },
      {
        "location": "North Pit",
        "crew_id": "CREW-003",
        "shifts": [
          { "feet_mined": 200 }
        ]
      }
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

### Response
```json
{
  "success": true,
  "data": [
    { "location": "North Pit", "count": 1 },
    { "location": "South Pit", "count": 1 }
  ],
  "metadata": {
    "rowCount": 2,
    "dimensions": ["location"],
    "metrics": ["count"],
    "filtersApplied": 0,
    "engine": "polars",
    "executionTime": 12
  }
}
```

### Extract Distinct Values
```javascript
const distinctLocations = response.data.map(row => row.location);
// Result: ["North Pit", "South Pit"]
```

---

## Example 2: Get Distinct Crew IDs

### Request
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

### Response
```json
{
  "success": true,
  "data": [
    { "crew_id": "CREW-001", "count": 1 },
    { "crew_id": "CREW-002", "count": 1 },
    { "crew_id": "CREW-003", "count": 1 }
  ],
  "metadata": {
    "rowCount": 3,
    "dimensions": ["crew_id"],
    "metrics": ["count"],
    "engine": "polars",
    "executionTime": 10
  }
}
```

### Extract Distinct Values
```javascript
const distinctCrews = response.data.map(row => row.crew_id);
// Result: ["CREW-001", "CREW-002", "CREW-003"]
```

---

## Example 3: Get Table Data (No Filters)

### Request
```json
{
  "data": { /* same data */ },
  "dimensions": ["location", "crew_id"],
  "metrics": [
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
  ]
}
```

### Response
```json
{
  "success": true,
  "data": [
    {
      "location": "North Pit",
      "crew_id": "CREW-001",
      "total_feet": 270,
      "avg_per_shift": 135
    },
    {
      "location": "North Pit",
      "crew_id": "CREW-003",
      "total_feet": 200,
      "avg_per_shift": 200
    },
    {
      "location": "South Pit",
      "crew_id": "CREW-002",
      "total_feet": 100,
      "avg_per_shift": 100
    }
  ],
  "metadata": {
    "rowCount": 3,
    "dimensions": ["location", "crew_id"],
    "metrics": ["total_feet", "avg_per_shift"],
    "filtersApplied": 0,
    "engine": "polars",
    "executionTime": 15
  }
}
```

---

## Example 4: Get Table Data (With Single Filter)

### Request
```json
{
  "data": { /* same data */ },
  "dimensions": ["location", "crew_id"],
  "metrics": [
    {
      "field": "shifts_feet_mined",
      "aggregation": "sum",
      "alias": "total_feet"
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

### Response
```json
{
  "success": true,
  "data": [
    {
      "location": "North Pit",
      "crew_id": "CREW-001",
      "total_feet": 270
    },
    {
      "location": "North Pit",
      "crew_id": "CREW-003",
      "total_feet": 200
    }
  ],
  "metadata": {
    "rowCount": 2,
    "dimensions": ["location", "crew_id"],
    "metrics": ["total_feet"],
    "filtersApplied": 1,
    "engine": "polars",
    "executionTime": 18
  }
}
```

---

## Example 5: Get Table Data (With Multiple Filters)

### Request
```json
{
  "data": { /* same data */ },
  "dimensions": ["location", "crew_id"],
  "metrics": [
    {
      "field": "shifts_feet_mined",
      "aggregation": "sum",
      "alias": "total_feet"
    }
  ],
  "filters": [
    {
      "field": "location",
      "operator": "equals",
      "value": "North Pit"
    },
    {
      "field": "crew_id",
      "operator": "equals",
      "value": "CREW-001"
    }
  ]
}
```

### Response
```json
{
  "success": true,
  "data": [
    {
      "location": "North Pit",
      "crew_id": "CREW-001",
      "total_feet": 270
    }
  ],
  "metadata": {
    "rowCount": 1,
    "dimensions": ["location", "crew_id"],
    "metrics": ["total_feet"],
    "filtersApplied": 2,
    "engine": "polars",
    "executionTime": 20
  }
}
```

---

## Example 6: Get Distinct Values with Filter

### Request
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

### Response
```json
{
  "success": true,
  "data": [
    { "crew_id": "CREW-001", "count": 1 },
    { "crew_id": "CREW-003", "count": 1 }
  ],
  "metadata": {
    "rowCount": 2,
    "dimensions": ["crew_id"],
    "metrics": ["count"],
    "filtersApplied": 1,
    "engine": "polars",
    "executionTime": 14
  }
}
```

**Extract:** Only crews in North Pit: `["CREW-001", "CREW-003"]`

---

## Key Patterns

### Pattern 1: Get Distinct Values
```json
{
  "data": yourData,
  "dimensions": ["field_name"],
  "metrics": [{
    "field": "field_name",
    "aggregation": "countDistinct",
    "alias": "count"
  }]
}
```

### Pattern 2: Get Table Data
```json
{
  "data": yourData,
  "dimensions": ["dim1", "dim2"],
  "metrics": [
    { "field": "field1", "aggregation": "sum" },
    { "field": "field2", "aggregation": "avg" }
  ]
}
```

### Pattern 3: Get Filtered Data
```json
{
  "data": yourData,
  "dimensions": ["dim1"],
  "metrics": [{ "field": "field1", "aggregation": "sum" }],
  "filters": [
    { "field": "status", "operator": "equals", "value": "active" }
  ]
}
```

### Pattern 4: Get Filtered Distinct Values
```json
{
  "data": yourData,
  "dimensions": ["field_name"],
  "metrics": [{
    "field": "field_name",
    "aggregation": "countDistinct"
  }],
  "filters": [
    { "field": "location", "operator": "equals", "value": "North Pit" }
  ]
}
```

---

## Response Structure

All responses follow this structure:
```json
{
  "success": true,
  "data": [ /* array of result rows */ ],
  "metadata": {
    "rowCount": 3,
    "dimensions": ["field1", "field2"],
    "metrics": ["metric1", "metric2"],
    "filtersApplied": 1,
    "engine": "polars",
    "executionTime": 15
  }
}
```

---

## Error Response

```json
{
  "success": false,
  "message": "Error message here",
  "error": "Full error details"
}
```

