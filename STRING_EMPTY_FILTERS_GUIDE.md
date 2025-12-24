# String Empty Filters - Complete Guide

## Overview

Two new filters have been added to check for **empty strings** specifically:

- **`isEmpty`** - Show rows where field is empty string ("") or null
- **`isNotEmpty`** - Show rows where field is NOT empty string (has content)

---

## 🎯 Quick Answer

### Show Non-Empty Strings
```json
{
  "filters": [
    {
      "field": "field_name",
      "operator": "isNotEmpty"
    }
  ]
}
```

### Show Empty Strings
```json
{
  "filters": [
    {
      "field": "field_name",
      "operator": "isEmpty"
    }
  ]
}
```

---

## 📊 Difference Between Operators

| Operator | Null | Empty String ("") | Non-Empty String |
|----------|------|-------------------|------------------|
| `isNull` | ✅ Include | ❌ Exclude | ❌ Exclude |
| `isNotNull` | ❌ Exclude | ✅ Include | ✅ Include |
| `isEmpty` | ✅ Include | ✅ Include | ❌ Exclude |
| `isNotEmpty` | ❌ Exclude | ❌ Exclude | ✅ Include |

---

## 💻 Usage Examples

### Example 1: Show Only Non-Empty Email Addresses
```json
{
  "data": { /* your data */ },
  "dimensions": ["user_id"],
  "metrics": [{ "field": "name", "aggregation": "first" }],
  "filters": [
    {
      "field": "email",
      "operator": "isNotEmpty"
    }
  ]
}
```

**Result:** Only rows with actual email addresses (not null, not "")

---

### Example 2: Show Only Empty Email Addresses
```json
{
  "data": { /* your data */ },
  "dimensions": ["user_id"],
  "metrics": [{ "field": "name", "aggregation": "first" }],
  "filters": [
    {
      "field": "email",
      "operator": "isEmpty"
    }
  ]
}
```

**Result:** Rows where email is null or empty string ("")

---

### Example 3: Show Valid Contact Information
```json
{
  "data": { /* your data */ },
  "dimensions": ["user_id"],
  "metrics": [{ "field": "count", "aggregation": "sum" }],
  "filters": [
    { "field": "email", "operator": "isNotEmpty" },
    { "field": "phone", "operator": "isNotEmpty" },
    { "field": "address", "operator": "isNotEmpty" }
  ]
}
```

**Result:** Only users with all three contact fields populated

---

### Example 4: Find Incomplete Records
```json
{
  "data": { /* your data */ },
  "dimensions": ["record_id"],
  "metrics": [{ "field": "amount", "aggregation": "sum" }],
  "filters": [
    { "field": "description", "operator": "isEmpty" }
  ]
}
```

**Result:** Records with missing or empty descriptions

---

### Example 5: Combine with Other Filters
```json
{
  "data": { /* your data */ },
  "dimensions": ["location"],
  "metrics": [{ "field": "production", "aggregation": "sum" }],
  "filters": [
    { "field": "location", "operator": "isNotEmpty" },
    { "field": "supervisor", "operator": "isNotEmpty" },
    { "field": "production", "operator": "greaterThan", "value": 0 }
  ]
}
```

**Result:** Valid locations with supervisors and positive production

---

## 🔑 Key Differences

### `isNotNull` vs `isNotEmpty`

**`isNotNull`** - Checks if value is not null
- Includes: "John", "", 0, false
- Excludes: null

**`isNotEmpty`** - Checks if string is not empty
- Includes: "John", "0", " " (space)
- Excludes: null, ""

---

### `isNull` vs `isEmpty`

**`isNull`** - Checks if value is null only
- Includes: null
- Excludes: "", "John", 0

**`isEmpty`** - Checks if string is empty or null
- Includes: null, ""
- Excludes: "John", "0", " " (space)

---

## 📝 Complete Request Examples

### Mining Report - Non-Empty Locations
```json
{
  "data": {
    "reports": [
      {
        "location": "North Pit",
        "supervisor": "John Smith",
        "shifts": [{ "feet_mined": 150 }]
      },
      {
        "location": "",
        "supervisor": "Jane Doe",
        "shifts": [{ "feet_mined": 100 }]
      },
      {
        "location": null,
        "supervisor": "Bob Wilson",
        "shifts": [{ "feet_mined": 200 }]
      }
    ]
  },
  "dimensions": ["location"],
  "metrics": [
    { "field": "supervisor", "aggregation": "first" },
    { "field": "shifts_feet_mined", "aggregation": "sum", "alias": "total" }
  ],
  "filters": [
    { "field": "location", "operator": "isNotEmpty" }
  ]
}
```

**Result:** Only "North Pit" row (empty string and null are excluded)

---

### Customer Data - Valid Emails
```json
{
  "data": { /* customer data */ },
  "dimensions": ["customer_id"],
  "metrics": [
    { "field": "name", "aggregation": "first" },
    { "field": "orders", "aggregation": "count" }
  ],
  "filters": [
    { "field": "email", "operator": "isNotEmpty" }
  ]
}
```

**Result:** Only customers with valid email addresses

---

## 🧪 Test Cases

### Test 1: Non-Empty Strings
```json
{ "field": "email", "operator": "isNotEmpty" }
```
- ✅ "john@example.com"
- ✅ "0"
- ✅ " " (space)
- ❌ ""
- ❌ null

### Test 2: Empty Strings
```json
{ "field": "email", "operator": "isEmpty" }
```
- ✅ ""
- ✅ null
- ❌ "john@example.com"
- ❌ "0"
- ❌ " " (space)

### Test 3: Multiple Non-Empty Fields
```json
[
  { "field": "email", "operator": "isNotEmpty" },
  { "field": "phone", "operator": "isNotEmpty" },
  { "field": "address", "operator": "isNotEmpty" }
]
```
- ✅ All three fields have content
- ❌ Any field is empty or null

---

## 💡 Use Cases

### 1. Data Quality Checks
Find records with missing required fields:
```json
{ "field": "required_field", "operator": "isEmpty" }
```

### 2. Contact Information
Show only customers with complete contact info:
```json
[
  { "field": "email", "operator": "isNotEmpty" },
  { "field": "phone", "operator": "isNotEmpty" }
]
```

### 3. Report Validation
Show only reports with descriptions:
```json
{ "field": "description", "operator": "isNotEmpty" }
```

### 4. Data Cleanup
Find incomplete records:
```json
{ "field": "notes", "operator": "isEmpty" }
```

### 5. Production Data
Show only valid production entries:
```json
[
  { "field": "location", "operator": "isNotEmpty" },
  { "field": "crew_id", "operator": "isNotEmpty" },
  { "field": "production", "operator": "greaterThan", "value": 0 }
]
```

---

## ✅ Summary

**Two new string empty filters:**

1. **`isEmpty`** - Show empty strings ("") or null values
2. **`isNotEmpty`** - Show non-empty strings (has content)

**Key Points:**
- ✅ No value needed for these filters
- ✅ Works with string fields
- ✅ Combine with other filters
- ✅ Useful for data quality checks
- ✅ Different from `isNull` and `isNotNull`

---

## 📚 Related Documentation

- **FILTER_NON_EMPTY_VALUES_GUIDE.md** - Complete filter guide
- **COMPLETE_FILTER_OPERATORS_GUIDE.md** - All 15 operators
- **FILTER_NON_EMPTY_QUICK_REFERENCE.md** - Quick reference

