# Numeric Suffix Object Flattening - Quick Reference

## 🎯 What Changed

The `detectAndGroupNumericSuffixes()` function now **detects and flattens object fields** with numeric suffixes.

---

## 📊 Before vs After

### Before (Old Behavior)
```javascript
// Input
{
  item-1: { name: "John", age: 30 },
  item-2: { name: "Jane", age: 25 }
}

// Output: Array of objects ❌
groupedArrays: {
  item: [
    { name: "John", age: 30 },
    { name: "Jane", age: 25 }
  ]
}
```

### After (New Behavior)
```javascript
// Input
{
  item-1: { name: "John", age: 30 },
  item-2: { name: "Jane", age: 25 }
}

// Output: Separate arrays for each property ✅
groupedArrays: {
  item_name: ["John", "Jane"],
  item_age: [30, 25]
}
```

---

## 🔑 How It Works

### Step 1: Detect Numeric Suffix
```
item-1, item-2 → Matches pattern: propertyName-number
```

### Step 2: Check if Value is Object
```
{ name: "John", age: 30 } → Is object? YES ✅
```

### Step 3: Flatten Object Properties
```
Object keys: ["name", "age"]
↓
Create separate arrays:
- item_name: ["John", "Jane"]
- item_age: [30, 25]
```

---

## 💻 Examples

### Example 1: Equipment with Properties
```javascript
// Input
{
  equipment-1: { type: "Drill", status: "active" },
  equipment-2: { type: "Pump", status: "idle" }
}

// Output
{
  equipment_type: ["Drill", "Pump"],
  equipment_status: ["active", "idle"]
}
```

### Example 2: Reports with Multiple Properties
```javascript
// Input
{
  report-1: { date: "2024-01-01", production: 150 },
  report-2: { date: "2024-01-02", production: 200 }
}

// Output
{
  report_date: ["2024-01-01", "2024-01-02"],
  report_production: [150, 200]
}
```

### Example 3: Mixed Primitives and Objects
```javascript
// Input
{
  location: "North Pit",
  count-1: 10,
  count-2: 20,
  details-1: { name: "John", role: "supervisor" },
  details-2: { name: "Jane", role: "operator" }
}

// Output
{
  groupedArrays: {
    count: [10, 20],
    details_name: ["John", "Jane"],
    details_role: ["supervisor", "operator"]
  },
  remainingFields: {
    location: "North Pit"
  }
}
```

---

## 🔍 Detection Logic

```typescript
// Check if value is an object (not array, not null)
const isObjectField =
  firstValue !== null &&
  typeof firstValue === 'object' &&
  !Array.isArray(firstValue);

if (isObjectField) {
  // Flatten each property as separate field
  // Format: baseName_propertyName
} else {
  // Create array from primitive values
}
```

---

## 📝 Field Naming Convention

When flattening object properties:

```
Original field: item-1, item-2
Base name: item
Object property: name, age

Result field names:
- item_name
- item_age
```

**Pattern:** `{baseName}_{propertyName}`

---

## ✅ Key Features

✅ **Automatic Detection** - Detects object vs primitive
✅ **Property Extraction** - Extracts each property separately
✅ **Null Safe** - Handles missing properties with `?? null`
✅ **Type Checking** - Validates object type
✅ **Backward Compatible** - Primitives work as before
✅ **Polars Ready** - Creates proper array structure

---

## 🧪 Test Scenarios

### Scenario 1: Pure Objects
```
Input: item-1: {...}, item-2: {...}
Output: item_prop1, item_prop2, ... (separate arrays)
```

### Scenario 2: Pure Primitives
```
Input: count-1: 10, count-2: 20
Output: count (single array)
```

### Scenario 3: Mixed
```
Input: count-1: 10, details-1: {...}
Output: count (array), details_prop1, details_prop2 (arrays)
```

---

## 📚 Related Documentation

- **NUMERIC_SUFFIX_OBJECT_FLATTENING_GUIDE.md** - Complete guide
- **src/processor/polars-rowpad.service.ts** - Implementation (lines 420-514)

---

## 🎉 Summary

**Enhancement:** Automatic object detection and property flattening for numeric suffix fields

**Benefit:** Properly handles object fields with numeric suffixes by flattening them into separate arrays

**Result:** Compatible with Polars DataFrame structure

