# Distinct Values for Table Rendering - Documentation Index

## 📌 Quick Answer

To get distinct values for a dimension, send this to `/processor/chart-query`:

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

Extract values: `response.data.map(row => row.field_name)`

---

## 📚 Documentation Files

### 1. **DISTINCT_VALUES_COMPLETE_ANSWER.md** ⭐ START HERE
   - Complete answer to your question
   - Full React component example
   - Step-by-step implementation
   - **Best for:** Getting the complete picture

### 2. **DISTINCT_VALUES_QUICK_REFERENCE.md** 🚀 QUICK LOOKUP
   - One-page reference card
   - Code snippets
   - Aggregations and operators
   - **Best for:** Quick lookups while coding

### 3. **DISTINCT_VALUES_IMPLEMENTATION_GUIDE.md** 📖 DETAILED GUIDE
   - Complete implementation guide
   - Step-by-step instructions
   - Performance tips
   - **Best for:** Understanding the full implementation

### 4. **TABLE_RENDERING_WITH_FILTERS_EXAMPLE.md** 💻 PRACTICAL EXAMPLE
   - Complete React implementation
   - Mining report example
   - Filter handling
   - **Best for:** Copy-paste ready code

### 5. **DISTINCT_VALUES_API_EXAMPLES.md** 🔌 API REFERENCE
   - Request/response examples
   - 6 different scenarios
   - Pattern reference
   - **Best for:** Understanding API structure

### 6. **DIMENSION_DISTINCT_VALUES_GUIDE.md** 📋 DETAILED GUIDE
   - Comprehensive guide
   - React and Vue examples
   - Performance considerations
   - **Best for:** In-depth understanding

### 7. **FRONTEND_TABLE_RENDERING_SUMMARY.md** 📊 SUMMARY
   - Complete flow explanation
   - Request structure breakdown
   - Supported operators
   - **Best for:** Understanding the complete flow

---

## 🧪 Test Files

### **test-distinct-values.ps1**
PowerShell test script demonstrating:
1. Getting distinct locations
2. Getting distinct crew IDs
3. Getting full table data
4. Filtering by single field
5. Filtering by multiple fields

Run: `.\test-distinct-values.ps1`

---

## 🎯 Use Cases

### Use Case 1: Simple Filter Dropdown
**File:** DISTINCT_VALUES_QUICK_REFERENCE.md
```json
{
  "data": data,
  "dimensions": ["location"],
  "metrics": [{
    "field": "location",
    "aggregation": "countDistinct",
    "alias": "count"
  }]
}
```

### Use Case 2: Table with Multiple Filters
**File:** TABLE_RENDERING_WITH_FILTERS_EXAMPLE.md
- Get distinct values for each filter
- Populate dropdowns
- Get table data with filters
- Handle filter changes

### Use Case 3: Conditional Distinct Values
**File:** DISTINCT_VALUES_API_EXAMPLES.md (Example 6)
- Get distinct values only for filtered data
- Add filters to the request

### Use Case 4: Complete React Component
**File:** DISTINCT_VALUES_COMPLETE_ANSWER.md
- Full working React component
- All hooks and state management
- Error handling

---

## 🔑 Key Concepts

### Distinct Values
Get unique values for a field:
```json
{
  "dimensions": ["field_name"],
  "metrics": [{
    "aggregation": "countDistinct"
  }]
}
```

### Table Data
Get rows with grouping and aggregation:
```json
{
  "dimensions": ["dim1", "dim2"],
  "metrics": [
    { "aggregation": "sum" },
    { "aggregation": "avg" }
  ]
}
```

### Filters
Apply WHERE conditions:
```json
{
  "filters": [
    { "field": "location", "operator": "equals", "value": "North Pit" }
  ]
}
```

---

## 📊 Supported Aggregations

| Function | Use | For Distinct |
|----------|-----|--------------|
| `sum` | Total | ❌ |
| `avg` | Average | ❌ |
| `count` | Count | ❌ |
| `countDistinct` | Unique | ✅ **USE THIS** |
| `first` | First value | ❌ |
| `last` | Last value | ❌ |

---

## 🔐 Supported Filter Operators

- `equals`, `notEquals`
- `greaterThan`, `lessThan`, `greaterThanOrEqual`, `lessThanOrEqual`
- `contains`, `notContains`
- `in`, `notIn`
- `isNull`, `isNotNull`
- `between`

---

## 🚀 Quick Start

### Step 1: Read the Complete Answer
→ **DISTINCT_VALUES_COMPLETE_ANSWER.md**

### Step 2: Copy the React Component
→ **TABLE_RENDERING_WITH_FILTERS_EXAMPLE.md**

### Step 3: Customize for Your Data
→ Update field names and dimensions

### Step 4: Test with PowerShell
→ `.\test-distinct-values.ps1`

---

## 💡 Tips

✅ Use `countDistinct` for distinct values
✅ Use `dimensions` for grouping
✅ Use `metrics` for calculations
✅ Use `filters` for WHERE conditions
✅ Cache distinct values to avoid repeated API calls
✅ Debounce filter changes for better performance
✅ Use `in` operator for multiple values

---

## 🔗 Related Documentation

- **CHART_QUERY_QUICK_REFERENCE.md** - Chart Query API reference
- **CHART_QUERY_GUIDE.md** - Complete Chart Query guide
- **API_ENDPOINTS_REFERENCE.md** - All API endpoints

---

## 📞 Common Questions

### Q: What aggregation should I use for distinct values?
**A:** Use `countDistinct`

### Q: Can I get distinct values with filters?
**A:** Yes, add `filters` to the request

### Q: How do I handle multiple filters?
**A:** Add multiple objects to the `filters` array

### Q: What if I need to get distinct values for multiple fields?
**A:** Make separate API calls for each field

### Q: Can I cache the distinct values?
**A:** Yes, cache them and refresh on data change

---

## 📈 Performance Considerations

1. **Cache Results** - Don't fetch on every render
2. **Debounce Changes** - Wait before fetching new data
3. **Lazy Load** - Load filter options only when needed
4. **Batch Requests** - Get multiple values in parallel
5. **Pagination** - For large result sets, use `limit`

---

## ✅ Checklist for Implementation

- [ ] Read DISTINCT_VALUES_COMPLETE_ANSWER.md
- [ ] Understand the request structure
- [ ] Copy React component example
- [ ] Update field names for your data
- [ ] Test with test-distinct-values.ps1
- [ ] Implement in your frontend
- [ ] Add error handling
- [ ] Add loading states
- [ ] Cache distinct values
- [ ] Test with real data

---

## 🎓 Learning Path

1. **Beginner** → DISTINCT_VALUES_QUICK_REFERENCE.md
2. **Intermediate** → DISTINCT_VALUES_COMPLETE_ANSWER.md
3. **Advanced** → TABLE_RENDERING_WITH_FILTERS_EXAMPLE.md
4. **Expert** → DISTINCT_VALUES_IMPLEMENTATION_GUIDE.md

---

## 📝 Summary

**To render a table with filters:**

1. Get distinct values using `countDistinct`
2. Populate filter dropdowns
3. Get table data with filters applied
4. Update table when filters change

**All with the existing `/processor/chart-query` endpoint!**

