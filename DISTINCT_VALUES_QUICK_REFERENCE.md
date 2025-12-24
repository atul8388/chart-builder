# Distinct Values for Table Filters - Quick Reference Card

## 🎯 Goal
Get distinct values for filter dropdowns in a table UI

## 📡 Endpoint
```
POST /processor/chart-query
```

---

## 🔍 Get Distinct Values

### Minimal Request
```json
{
  "data": { /* your JSON */ },
  "dimensions": ["field_name"],
  "metrics": [{
    "field": "field_name",
    "aggregation": "countDistinct",
    "alias": "count"
  }]
}
```

### Response
```json
{
  "data": [
    { "field_name": "value1", "count": 1 },
    { "field_name": "value2", "count": 1 }
  ]
}
```

### Extract Values
```javascript
const values = response.data.map(row => row.field_name);
```

---

## 📊 Get Table Data

### Request with Filters
```json
{
  "data": { /* your JSON */ },
  "dimensions": ["dim1", "dim2"],
  "metrics": [
    { "field": "amount", "aggregation": "sum", "alias": "total" },
    { "field": "amount", "aggregation": "avg", "alias": "average" }
  ],
  "filters": [
    { "field": "location", "operator": "equals", "value": "North Pit" }
  ]
}
```

### Response
```json
{
  "data": [
    { "dim1": "A", "dim2": "B", "total": 100, "average": 50 },
    { "dim1": "A", "dim2": "C", "total": 200, "average": 100 }
  ]
}
```

---

## 🔗 Complete Flow

```
1. Load Page
   ↓
2. Get Distinct Values for Each Filter
   POST /processor/chart-query
   dimensions: ["location"]
   metrics: [countDistinct]
   ↓
3. Populate Filter Dropdowns
   ↓
4. User Selects Filters
   ↓
5. Get Table Data with Filters
   POST /processor/chart-query
   dimensions: ["location", "crew_id"]
   metrics: [sum, avg, ...]
   filters: [{ field: "location", operator: "equals", value: "..." }]
   ↓
6. Render Table
   ↓
7. User Changes Filter → Go to Step 5
```

---

## 📋 Request Structure

| Field | Type | Purpose | Example |
|-------|------|---------|---------|
| `data` | Object | Your JSON data | `{ reports: [...] }` |
| `dimensions` | Array | Fields to group by | `["location", "crew_id"]` |
| `metrics` | Array | Fields to calculate | `[{ field: "amount", aggregation: "sum" }]` |
| `filters` | Array | WHERE conditions | `[{ field: "status", operator: "equals", value: "active" }]` |

---

## 🎯 Aggregation Functions

| Function | Purpose | For Distinct Values |
|----------|---------|-------------------|
| `sum` | Total | ❌ |
| `avg` | Average | ❌ |
| `count` | Count | ❌ |
| `countDistinct` | Unique count | ✅ **USE THIS** |
| `first` | First value | ❌ |
| `last` | Last value | ❌ |

---

## 🔐 Filter Operators

| Operator | Example |
|----------|---------|
| `equals` | `{ field: "status", operator: "equals", value: "active" }` |
| `notEquals` | `{ field: "status", operator: "notEquals", value: "inactive" }` |
| `greaterThan` | `{ field: "amount", operator: "greaterThan", value: 100 }` |
| `lessThan` | `{ field: "amount", operator: "lessThan", value: 100 }` |
| `contains` | `{ field: "name", operator: "contains", value: "John" }` |
| `in` | `{ field: "status", operator: "in", value: ["a", "b"] }` |
| `between` | `{ field: "date", operator: "between", value: ["2025-01-01", "2025-01-31"] }` |

---

## 💻 JavaScript Example

```javascript
// Get distinct values
async function getDistinct(data, field) {
  const res = await fetch('/processor/chart-query', {
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
  return (await res.json()).data.map(row => row[field]);
}

// Get table data
async function getTable(data, filters) {
  const res = await fetch('/processor/chart-query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      data: data,
      dimensions: ['location', 'crew_id'],
      metrics: [
        { field: 'amount', aggregation: 'sum', alias: 'total' }
      ],
      filters: filters
    })
  });
  return (await res.json()).data;
}

// Usage
const locations = await getDistinct(data, 'location');
const tableData = await getTable(data, [
  { field: 'location', operator: 'equals', value: 'North Pit' }
]);
```

---

## 🎨 React Hook Example

```javascript
const [distinct, setDistinct] = useState([]);
const [selected, setSelected] = useState('');

useEffect(() => {
  fetch('/processor/chart-query', {
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
  })
  .then(r => r.json())
  .then(r => setDistinct(r.data.map(row => row.location)));
}, [data]);

return (
  <select value={selected} onChange={e => setSelected(e.target.value)}>
    <option value="">All</option>
    {distinct.map(v => <option key={v} value={v}>{v}</option>)}
  </select>
);
```

---

## ✅ Checklist

- [ ] Get distinct values for each filter dimension
- [ ] Populate filter dropdowns
- [ ] Build filters array from user selection
- [ ] Get table data with filters applied
- [ ] Render table with results
- [ ] Handle filter changes
- [ ] Add loading states
- [ ] Add error handling

---

## 📚 Documentation

- **DISTINCT_VALUES_IMPLEMENTATION_GUIDE.md** - Complete guide
- **TABLE_RENDERING_WITH_FILTERS_EXAMPLE.md** - React example
- **DISTINCT_VALUES_API_EXAMPLES.md** - Request/response examples
- **test-distinct-values.ps1** - Test script

---

## 🚀 Test It

```powershell
.\test-distinct-values.ps1
```

---

## 💡 Key Points

✅ Use `countDistinct` for distinct values
✅ Use `dimensions` for grouping
✅ Use `metrics` for calculations
✅ Use `filters` for WHERE conditions
✅ All with existing `/processor/chart-query` endpoint
✅ No new endpoints needed!

