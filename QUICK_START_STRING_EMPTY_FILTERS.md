# Quick Start - String Empty Filters

## 🎯 What You Asked For

You wanted to check if a value is an **empty string** ("") which is different from **null**.

## ✅ Solution

Two new filters have been added:

### 1. `isNotEmpty` - Show Non-Empty Strings
```json
{
  "filters": [
    { "field": "email", "operator": "isNotEmpty" }
  ]
}
```
**Shows:** Rows where email has content (not null, not "")

### 2. `isEmpty` - Show Empty Strings
```json
{
  "filters": [
    { "field": "email", "operator": "isEmpty" }
  ]
}
```
**Shows:** Rows where email is empty ("") or null

---

## 📊 Quick Comparison

| Value | isNull | isNotNull | isEmpty | isNotEmpty |
|-------|--------|-----------|---------|-----------|
| null | ✅ | ❌ | ✅ | ❌ |
| "" | ❌ | ✅ | ✅ | ❌ |
| "John" | ❌ | ✅ | ❌ | ✅ |

---

## 💻 Real-World Examples

### Example 1: Show Only Valid Emails
```json
{
  "data": { /* your data */ },
  "dimensions": ["user_id"],
  "metrics": [{ "field": "name", "aggregation": "first" }],
  "filters": [
    { "field": "email", "operator": "isNotEmpty" }
  ]
}
```
**Result:** Only users with actual email addresses

---

### Example 2: Find Missing Emails
```json
{
  "data": { /* your data */ },
  "dimensions": ["user_id"],
  "metrics": [{ "field": "name", "aggregation": "first" }],
  "filters": [
    { "field": "email", "operator": "isEmpty" }
  ]
}
```
**Result:** Users with missing or empty emails

---

### Example 3: Complete Contact Information
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
**Result:** Only users with all three contact fields filled

---

### Example 4: Data Quality Check
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
**Result:** Records with missing descriptions

---

## 🔑 Key Differences

### `isNotNull` vs `isNotEmpty`

**`isNotNull`** - Checks if value is not null
- ✅ Includes: "John", "", 0, false
- ❌ Excludes: null

**`isNotEmpty`** - Checks if string is not empty
- ✅ Includes: "John", "0", " " (space)
- ❌ Excludes: null, ""

---

### `isNull` vs `isEmpty`

**`isNull`** - Checks if value is null only
- ✅ Includes: null
- ❌ Excludes: "", "John", 0

**`isEmpty`** - Checks if string is empty or null
- ✅ Includes: null, ""
- ❌ Excludes: "John", "0", " " (space)

---

## 📝 Complete Request

```json
{
  "data": {
    "users": [
      { "id": 1, "email": "john@example.com", "phone": "555-1234" },
      { "id": 2, "email": "", "phone": "555-5678" },
      { "id": 3, "email": null, "phone": null }
    ]
  },
  "dimensions": ["id"],
  "metrics": [
    { "field": "email", "aggregation": "first" },
    { "field": "phone", "aggregation": "first" }
  ],
  "filters": [
    { "field": "email", "operator": "isNotEmpty" }
  ]
}
```

**Result:** Only user 1 (john@example.com)

---

## 🧪 Test It

Run the test script:
```powershell
.\test-non-empty-filters.ps1
```

Tests 7-10 cover the new string empty filters:
- Test 7: Show non-empty strings
- Test 8: Show empty strings
- Test 9: Multiple non-empty fields
- Test 10: Records with empty notes

---

## 📚 Documentation

- **STRING_EMPTY_FILTERS_GUIDE.md** - Complete guide
- **STRING_EMPTY_FILTERS_SUMMARY.md** - Implementation details
- **COMPLETE_FILTER_OPERATORS_GUIDE.md** - All 15 operators
- **FINAL_IMPLEMENTATION_SUMMARY.md** - Full summary

---

## ✅ Summary

**Two new filters added:**

1. **`isNotEmpty`** - Show non-empty strings (has content)
2. **`isEmpty`** - Show empty strings ("") or null

**Use them to:**
- ✅ Filter out empty strings
- ✅ Show only valid data
- ✅ Find incomplete records
- ✅ Check data quality

**All fully implemented and ready to use!**

