# Complete Filter Operators Guide - All 13 Operators

## Overview

The Chart Query API now supports **13 filter operators** for comprehensive data filtering:

---

## 📋 All Operators by Category

### 1️⃣ Null/Empty Checks (4 operators) ⭐ NEW

| Operator     | Purpose                     | Example                                      | Result                                   |
| ------------ | --------------------------- | -------------------------------------------- | ---------------------------------------- |
| `isNotNull`  | Show non-null data          | `{ field: "email", operator: "isNotNull" }`  | Rows where email is not null             |
| `isNull`     | Show null data              | `{ field: "email", operator: "isNull" }`     | Rows where email is null                 |
| `isNotEmpty` | Show non-empty strings ("") | `{ field: "email", operator: "isNotEmpty" }` | Rows where email is not empty string     |
| `isEmpty`    | Show empty strings ("")     | `{ field: "email", operator: "isEmpty" }`    | Rows where email is empty string or null |

**Use Case:** Filter out incomplete records

```json
{ "field": "location", "operator": "isNotNull" }
```

---

### 2️⃣ String Filters (2 operators) ⭐ NEW

| Operator      | Purpose                 | Example                                                      |
| ------------- | ----------------------- | ------------------------------------------------------------ |
| `contains`    | String contains value   | `{ field: "name", operator: "contains", value: "John" }`     |
| `notContains` | String does not contain | `{ field: "email", operator: "notContains", value: "spam" }` |

**Use Case:** Search for specific text

```json
{ "field": "name", "operator": "contains", "value": "John" }
```

---

### 3️⃣ List Filters (2 operators) ⭐ NEW

| Operator | Purpose           | Example                                                             |
| -------- | ----------------- | ------------------------------------------------------------------- |
| `in`     | Value in list     | `{ field: "status", operator: "in", value: ["active", "pending"] }` |
| `notIn`  | Value not in list | `{ field: "status", operator: "notIn", value: ["cancelled"] }`      |

**Use Case:** Filter by multiple values

```json
{
  "field": "status",
  "operator": "in",
  "value": ["active", "pending", "review"]
}
```

---

### 4️⃣ Range Filters (1 operator) ⭐ NEW

| Operator  | Purpose        | Example                                                      |
| --------- | -------------- | ------------------------------------------------------------ |
| `between` | Value in range | `{ field: "price", operator: "between", value: [100, 500] }` |

**Use Case:** Filter by numeric range

```json
{ "field": "price", "operator": "between", "value": [100, 500] }
```

---

### 5️⃣ Comparison Filters (6 operators) - Existing

| Operator             | Purpose      | Example                                                           |
| -------------------- | ------------ | ----------------------------------------------------------------- |
| `equals`             | Exact match  | `{ field: "status", operator: "equals", value: "active" }`        |
| `notEquals`          | Not equal    | `{ field: "status", operator: "notEquals", value: "inactive" }`   |
| `greaterThan`        | Greater than | `{ field: "amount", operator: "greaterThan", value: 100 }`        |
| `lessThan`           | Less than    | `{ field: "amount", operator: "lessThan", value: 100 }`           |
| `greaterThanOrEqual` | >=           | `{ field: "amount", operator: "greaterThanOrEqual", value: 100 }` |
| `lessThanOrEqual`    | <=           | `{ field: "amount", operator: "lessThanOrEqual", value: 100 }`    |

**Use Case:** Numeric comparisons

```json
{ "field": "amount", "operator": "greaterThan", "value": 1000 }
```

---

## 🎯 Quick Reference Table

| Operator             | Category     | Value Type | Example                                                           |
| -------------------- | ------------ | ---------- | ----------------------------------------------------------------- |
| `isNotNull`          | Null Check   | None       | `{ field: "email", operator: "isNotNull" }`                       |
| `isNull`             | Null Check   | None       | `{ field: "email", operator: "isNull" }`                          |
| `isNotEmpty`         | String Empty | None       | `{ field: "email", operator: "isNotEmpty" }`                      |
| `isEmpty`            | String Empty | None       | `{ field: "email", operator: "isEmpty" }`                         |
| `contains`           | String       | String     | `{ field: "name", operator: "contains", value: "John" }`          |
| `notContains`        | String       | String     | `{ field: "name", operator: "notContains", value: "spam" }`       |
| `in`                 | List         | Array      | `{ field: "status", operator: "in", value: ["a", "b"] }`          |
| `notIn`              | List         | Array      | `{ field: "status", operator: "notIn", value: ["c"] }`            |
| `between`            | Range        | [min, max] | `{ field: "price", operator: "between", value: [100, 500] }`      |
| `equals`             | Compare      | Any        | `{ field: "status", operator: "equals", value: "active" }`        |
| `notEquals`          | Compare      | Any        | `{ field: "status", operator: "notEquals", value: "inactive" }`   |
| `greaterThan`        | Compare      | Number     | `{ field: "amount", operator: "greaterThan", value: 100 }`        |
| `lessThan`           | Compare      | Number     | `{ field: "amount", operator: "lessThan", value: 100 }`           |
| `greaterThanOrEqual` | Compare      | Number     | `{ field: "amount", operator: "greaterThanOrEqual", value: 100 }` |
| `lessThanOrEqual`    | Compare      | Number     | `{ field: "amount", operator: "lessThanOrEqual", value: 100 }`    |

---

## 💻 Complete Examples

### Example 1: Non-Empty Data

```json
{
  "filters": [
    { "field": "location", "operator": "isNotNull" },
    { "field": "crew_id", "operator": "isNotNull" }
  ]
}
```

### Example 2: Specific Status Values

```json
{
  "filters": [
    { "field": "status", "operator": "in", "value": ["active", "pending"] }
  ]
}
```

### Example 3: Price Range

```json
{
  "filters": [{ "field": "price", "operator": "between", "value": [100, 500] }]
}
```

### Example 4: Text Search

```json
{
  "filters": [{ "field": "name", "operator": "contains", "value": "John" }]
}
```

### Example 5: Complex Query

```json
{
  "filters": [
    { "field": "location", "operator": "isNotNull" },
    { "field": "status", "operator": "in", "value": ["active", "pending"] },
    { "field": "amount", "operator": "greaterThan", "value": 100 },
    { "field": "name", "operator": "contains", "value": "John" }
  ]
}
```

---

## 🔑 Key Points

✅ **Null Checks** - `isNotNull` and `isNull` don't need a value
✅ **String Filters** - `contains` and `notContains` work with text
✅ **List Filters** - `in` and `notIn` take an array of values
✅ **Range Filter** - `between` takes [min, max] array
✅ **Comparison** - All numeric comparison operators supported
✅ **Multiple Filters** - All filters use AND logic
✅ **All Field Types** - Works with any field type

---

## 📊 Filter Logic

All filters in the `filters` array are combined with **AND logic**:

```json
{
  "filters": [
    { "field": "location", "operator": "isNotNull" }, // AND
    { "field": "status", "operator": "equals", "value": "active" } // AND
  ]
}
```

**Result:** Rows where location is NOT null **AND** status equals "active"

---

## 🧪 Test All Operators

Run the test script:

```powershell
.\test-non-empty-filters.ps1
```

---

## 📚 Documentation

- **FILTER_NON_EMPTY_VALUES_GUIDE.md** - Detailed guide
- **FILTER_NON_EMPTY_QUICK_REFERENCE.md** - Quick reference
- **COMPLETE_FILTER_OPERATORS_GUIDE.md** - This file
- **test-non-empty-filters.ps1** - Test script

---

## 🚀 Summary

**15 Filter Operators Available:**

- 4 Null/Empty checks (isNull, isNotNull, isEmpty, isNotEmpty)
- 2 String filters (contains, notContains)
- 2 List filters (in, notIn)
- 1 Range filter (between)
- 6 Comparison filters (equals, notEquals, >, <, >=, <=)

**All fully implemented and ready to use!**
