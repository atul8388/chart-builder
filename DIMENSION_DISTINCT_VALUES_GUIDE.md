# Getting Distinct Values for Dimensions - UI Implementation Guide

## Overview

To render a table with filters on the UI, you need to populate dropdown/filter menus with distinct values for each dimension. This guide explains what information to send from the frontend to get those values.

---

## Solution: Use Chart Query with `countDistinct`

The simplest approach is to use the existing **Chart Query API** to get distinct values for any dimension.

### Endpoint
```
POST /processor/chart-query
```

---

## Method 1: Get Distinct Values for a Single Dimension

### Request
```json
{
  "data": {
    /* your JSON data */
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
    { "location": "South Pit", "count": 1 },
    { "location": "East Pit", "count": 1 }
  ],
  "metadata": {
    "rowCount": 3,
    "dimensions": ["location"],
    "metrics": ["count"],
    "engine": "polars",
    "executionTime": 45
  }
}
```

**Extract distinct values:**
```javascript
const distinctValues = response.data.map(row => row.location);
// Result: ["North Pit", "South Pit", "East Pit"]
```

---

## Method 2: Get Distinct Values for Multiple Dimensions

### Request
```json
{
  "data": {
    /* your JSON data */
  },
  "dimensions": ["location", "crew_id"],
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
    { "location": "North Pit", "crew_id": "CREW-001", "count": 1 },
    { "location": "North Pit", "crew_id": "CREW-002", "count": 1 },
    { "location": "South Pit", "crew_id": "CREW-001", "count": 1 }
  ]
}
```

**Extract distinct locations:**
```javascript
const distinctLocations = [...new Set(response.data.map(row => row.location))];
// Result: ["North Pit", "South Pit"]
```

---

## Method 3: Get Distinct Values with Filters

### Request
```json
{
  "data": {
    /* your JSON data */
  },
  "dimensions": ["location"],
  "metrics": [
    {
      "field": "location",
      "aggregation": "countDistinct",
      "alias": "count"
    }
  ],
  "filters": [
    {
      "field": "status",
      "operator": "equals",
      "value": "active"
    }
  ]
}
```

This returns only distinct values for active records.

---

## Frontend Implementation Example

### React Component
```javascript
import { useState, useEffect } from 'react';

function DimensionFilter({ data, dimensionField }) {
  const [distinctValues, setDistinctValues] = useState([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    fetchDistinctValues();
  }, [data, dimensionField]);

  const fetchDistinctValues = async () => {
    setLoading(true);
    try {
      const response = await fetch('/processor/chart-query', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          data: data,
          dimensions: [dimensionField],
          metrics: [
            {
              field: dimensionField,
              aggregation: 'countDistinct',
              alias: 'count'
            }
          ]
        })
      });

      const result = await response.json();
      const values = result.data.map(row => row[dimensionField]);
      setDistinctValues(values);
    } catch (error) {
      console.error('Error fetching distinct values:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <select disabled={loading}>
      <option value="">Select {dimensionField}</option>
      {distinctValues.map(value => (
        <option key={value} value={value}>{value}</option>
      ))}
    </select>
  );
}

export default DimensionFilter;
```

---

## Frontend Implementation - Vue.js
```javascript
<template>
  <select v-model="selectedValue" :disabled="loading">
    <option value="">Select {{ dimensionField }}</option>
    <option v-for="value in distinctValues" :key="value" :value="value">
      {{ value }}
    </option>
  </select>
</template>

<script>
export default {
  props: ['data', 'dimensionField'],
  data() {
    return {
      distinctValues: [],
      selectedValue: '',
      loading: false
    };
  },
  watch: {
    data: 'fetchDistinctValues'
  },
  methods: {
    async fetchDistinctValues() {
      this.loading = true;
      try {
        const response = await fetch('/processor/chart-query', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            data: this.data,
            dimensions: [this.dimensionField],
            metrics: [{
              field: this.dimensionField,
              aggregation: 'countDistinct',
              alias: 'count'
            }]
          })
        });
        const result = await response.json();
        this.distinctValues = result.data.map(row => row[this.dimensionField]);
      } catch (error) {
        console.error('Error:', error);
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>
```

---

## Request Structure Summary

### Minimal Request (Get Distinct Values)
```json
{
  "data": { /* your JSON data */ },
  "dimensions": ["field_name"],
  "metrics": [
    {
      "field": "field_name",
      "aggregation": "countDistinct",
      "alias": "count"
    }
  ]
}
```

### With Filters (Get Filtered Distinct Values)
```json
{
  "data": { /* your JSON data */ },
  "dimensions": ["field_name"],
  "metrics": [
    {
      "field": "field_name",
      "aggregation": "countDistinct",
      "alias": "count"
    }
  ],
  "filters": [
    {
      "field": "status",
      "operator": "equals",
      "value": "active"
    }
  ]
}
```

---

## Key Points

✅ Use `dimensions` array with the field name
✅ Use `countDistinct` aggregation to get unique values
✅ Extract values from the response using `map()`
✅ Can combine with filters to get conditional distinct values
✅ Works with any field type (text, number, date)
✅ Efficient - only returns distinct values, not all rows

---

## Performance Considerations

- **Small datasets** (< 10K rows): Direct API call is fine
- **Large datasets** (> 10K rows): Consider caching results
- **Frequently changing data**: Refresh on data change
- **Multiple filters**: Apply filters in the request, not after

---

## Supported Filter Operators

When filtering distinct values, use any of these operators:
- `equals`, `notEquals`
- `greaterThan`, `lessThan`, `greaterThanOrEqual`, `lessThanOrEqual`
- `contains`, `notContains`
- `in`, `notIn`
- `isNull`, `isNotNull`
- `between`

