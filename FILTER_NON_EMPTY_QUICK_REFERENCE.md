# Filter Non-Empty Values - Quick Reference

## 🎯 Goal

Display only rows where specific fields are **not empty** (non-null)

---

## ⚡ Quick Syntax

### Show Non-Empty Data

```json
{
  "filters": [
    {
      "field": "field_name",
      "operator": "isNotNull"
    }
  ]
}
```

### Show Empty Data

```json
{
  "filters": [
    {
      "field": "field_name",
      "operator": "isNull"
    }
  ]
}
```

---

## 📋 All Filter Operators

### Null Checks ⭐ NEW

| Operator     | Purpose                         | No Value Needed |
| ------------ | ------------------------------- | --------------- |
| `isNotNull`  | Show non-null data              | ✅ Yes          |
| `isNull`     | Show null data                  | ✅ Yes          |
| `isNotEmpty` | Show non-empty strings ("")     | ✅ Yes          |
| `isEmpty`    | Show empty strings ("") or null | ✅ Yes          |

### String Filters ⭐ NEW

| Operator      | Purpose          | Value  |
| ------------- | ---------------- | ------ |
| `contains`    | Contains text    | String |
| `notContains` | Does not contain | String |

### List Filters ⭐ NEW

| Operator | Purpose     | Value |
| -------- | ----------- | ----- |
| `in`     | In list     | Array |
| `notIn`  | Not in list | Array |

### Range Filters ⭐ NEW

| Operator  | Purpose  | Value      |
| --------- | -------- | ---------- |
| `between` | In range | [min, max] |

### Comparison (Existing)

| Operator             | Purpose      |
| -------------------- | ------------ |
| `equals`             | Equal to     |
| `notEquals`          | Not equal    |
| `greaterThan`        | Greater than |
| `lessThan`           | Less than    |
| `greaterThanOrEqual` | >=           |
| `lessThanOrEqual`    | <=           |

---

## 💻 Code Examples

### JavaScript

```javascript
// Show non-empty locations
const filters = [{ field: 'location', operator: 'isNotNull' }];

// Show non-empty AND production > 100
const filters = [
  { field: 'location', operator: 'isNotNull' },
  { field: 'production', operator: 'greaterThan', value: 100 },
];

// Show data in specific status list
const filters = [
  { field: 'status', operator: 'in', value: ['active', 'pending'] },
];

// Show data in price range
const filters = [{ field: 'price', operator: 'between', value: [100, 500] }];

// Show names containing "John"
const filters = [{ field: 'name', operator: 'contains', value: 'John' }];
```

---

## 📊 Complete Request

```json
{
  "data": {
    /* your JSON */
  },
  "dimensions": ["location", "crew_id"],
  "metrics": [{ "field": "amount", "aggregation": "sum", "alias": "total" }],
  "filters": [
    { "field": "location", "operator": "isNotNull" },
    { "field": "crew_id", "operator": "isNotNull" },
    { "field": "amount", "operator": "greaterThan", "value": 0 }
  ]
}
```

---

## 🎯 Use Cases

### 1. Show Non-Empty Locations

```json
{ "field": "location", "operator": "isNotNull" }
```

### 2. Show Non-Empty Email

```json
{ "field": "email", "operator": "isNotNull" }
```

### 3. Show Completed Orders

```json
{ "field": "completion_date", "operator": "isNotNull" }
```

### 4. Show Active Status

```json
{ "field": "status", "operator": "equals", "value": "active" }
```

### 5. Show Multiple Valid Statuses

```json
{ "field": "status", "operator": "in", "value": ["active", "pending"] }
```

### 6. Show Price in Range

```json
{ "field": "price", "operator": "between", "value": [100, 500] }
```

### 7. Show Names with "John"

```json
{ "field": "name", "operator": "contains", "value": "John" }
```

### 8. Show Non-Empty + Amount > 0

```json
[
  { "field": "location", "operator": "isNotNull" },
  { "field": "amount", "operator": "greaterThan", "value": 0 }
]
```

---

## 🔑 Key Points

✅ `isNotNull` - Show non-empty data
✅ `isNull` - Show empty data
✅ No `value` needed for null checks
✅ Combine multiple filters (AND logic)
✅ Works with all field types
✅ All new operators fully implemented

---

## 📝 Request Structure

```json
{
  "data": {
    /* your JSON */
  },
  "dimensions": ["field1", "field2"],
  "metrics": [{ "field": "amount", "aggregation": "sum" }],
  "filters": [
    {
      "field": "field_name",
      "operator": "isNotNull"
    }
  ]
}
```

---

## 🧪 Test It

```powershell
.\test-non-empty-filters.ps1
```

Tests:

1. All data (no filters)
2. Non-empty locations
3. Non-empty crew IDs
4. Multiple non-empty fields
5. Empty locations
6. Non-empty + production > 100

---

## 📚 Documentation

- **FILTER_NON_EMPTY_VALUES_GUIDE.md** - Complete guide
- **test-non-empty-filters.ps1** - Test script
- **CHART_QUERY_GUIDE.md** - Full Chart Query API

---

## ✅ Checklist

- [ ] Use `isNotNull` to show non-empty data
- [ ] Use `isNull` to show empty data
- [ ] Combine multiple filters for complex queries
- [ ] Test with your data
- [ ] Implement in frontend

---

## 🚀 Summary

**To show only non-empty data:**

```json
{
  "filters": [{ "field": "location", "operator": "isNotNull" }]
}
```

**That's it!** All new operators are fully implemented and ready to use.
