# Numeric Suffix Object Flattening - Implementation Guide

## Overview

Enhanced the `detectAndGroupNumericSuffixes()` function to intelligently handle fields with numeric suffixes that contain **objects**.

When a field with numeric suffix (e.g., `item-1`, `item-2`) contains an object, the function now:
- ✅ Detects that the value is an object
- ✅ Flattens each object's properties as separate fields
- ✅ Creates individual arrays for each property
- ✅ Treats each property as a separate field instead of creating an array of objects

---

## 🎯 Problem & Solution

### Before (Old Behavior)
```javascript
// Input data
{
  item-1: { name: "John", age: 30 },
  item-2: { name: "Jane", age: 25 }
}

// Result: Array of objects (problematic for Polars)
groupedArrays: {
  item: [
    { name: "John", age: 30 },
    { name: "Jane", age: 25 }
  ]
}
```

### After (New Behavior)
```javascript
// Input data
{
  item-1: { name: "John", age: 30 },
  item-2: { name: "Jane", age: 25 }
}

// Result: Separate arrays for each property (correct for Polars)
groupedArrays: {
  item_name: ["John", "Jane"],
  item_age: [30, 25]
}
```

---

## 🔧 Implementation Details

### Function: `detectAndGroupNumericSuffixes()`

**Location:** `src/processor/polars-rowpad.service.ts` (lines 420-514)

**Key Changes:**

1. **Object Detection** (lines 460-465)
   ```typescript
   const firstValue = items[0].value;
   const isObjectField =
     firstValue !== null &&
     typeof firstValue === 'object' &&
     !Array.isArray(firstValue);
   ```

2. **Object Property Flattening** (lines 467-485)
   ```typescript
   if (isObjectField) {
     const objectKeys = Object.keys(firstValue);
     for (const objKey of objectKeys) {
       const flattenedFieldName = `${baseName}_${objKey}`;
       const flattenedArray = items.map((item) => {
         const obj = item.value;
         if (obj !== null && typeof obj === 'object' && !Array.isArray(obj)) {
           return obj[objKey] ?? null;
         }
         return null;
       });
       groupedArrays[flattenedFieldName] = flattenedArray;
     }
   }
   ```

3. **Primitive Value Handling** (lines 490-497)
   ```typescript
   else {
     // If values are primitives, create array from grouped items
     groupedArrays[baseName] = items.map((item) => item.value);
   }
   ```

---

## 📊 Examples

### Example 1: Simple Object Fields

**Input:**
```json
{
  "location": "North Pit",
  "equipment-1": { "type": "Drill", "status": "active" },
  "equipment-2": { "type": "Pump", "status": "idle" }
}
```

**Processing:**
- Detects `equipment-1` and `equipment-2` have numeric suffixes
- Checks if values are objects ✅
- Flattens object properties

**Output:**
```json
{
  "groupedArrays": {
    "equipment_type": ["Drill", "Pump"],
    "equipment_status": ["active", "idle"]
  },
  "remainingFields": {
    "location": "North Pit"
  }
}
```

---

### Example 2: Mixed Primitive and Object Fields

**Input:**
```json
{
  "location": "South Pit",
  "count-1": 10,
  "count-2": 20,
  "details-1": { "name": "John", "role": "supervisor" },
  "details-2": { "name": "Jane", "role": "operator" }
}
```

**Processing:**
- `count-1`, `count-2` → Primitives → Create array
- `details-1`, `details-2` → Objects → Flatten properties

**Output:**
```json
{
  "groupedArrays": {
    "count": [10, 20],
    "details_name": ["John", "Jane"],
    "details_role": ["supervisor", "operator"]
  },
  "remainingFields": {
    "location": "South Pit"
  }
}
```

---

### Example 3: Nested Object Properties

**Input:**
```json
{
  "report-1": {
    "date": "2024-01-01",
    "production": 150,
    "status": "completed"
  },
  "report-2": {
    "date": "2024-01-02",
    "production": 200,
    "status": "completed"
  }
}
```

**Output:**
```json
{
  "groupedArrays": {
    "report_date": ["2024-01-01", "2024-01-02"],
    "report_production": [150, 200],
    "report_status": ["completed", "completed"]
  }
}
```

---

## 🔑 Key Features

✅ **Automatic Detection** - Detects if field value is an object
✅ **Property Flattening** - Extracts each property as separate field
✅ **Null Handling** - Uses `?? null` to handle missing properties
✅ **Type Safety** - Checks for null and array types
✅ **Backward Compatible** - Primitives still work as before
✅ **Polars Compatible** - Creates proper array structure for Polars

---

## 🧪 Test Cases

### Test 1: Object Fields with Numeric Suffixes
```javascript
const input = {
  item-1: { name: "A", value: 10 },
  item-2: { name: "B", value: 20 }
};

// Expected output
groupedArrays: {
  item_name: ["A", "B"],
  item_value: [10, 20]
}
```

### Test 2: Primitive Fields with Numeric Suffixes
```javascript
const input = {
  count-1: 100,
  count-2: 200
};

// Expected output
groupedArrays: {
  count: [100, 200]
}
```

### Test 3: Mixed Fields
```javascript
const input = {
  location: "Pit A",
  count-1: 100,
  count-2: 200,
  details-1: { name: "John", role: "supervisor" },
  details-2: { name: "Jane", role: "operator" }
};

// Expected output
groupedArrays: {
  count: [100, 200],
  details_name: ["John", "Jane"],
  details_role: ["supervisor", "operator"]
},
remainingFields: {
  location: "Pit A"
}
```

---

## 📝 Usage in Chart Query

```json
{
  "data": {
    "reports": [
      {
        "location": "North Pit",
        "equipment-1": { "type": "Drill", "status": "active" },
        "equipment-2": { "type": "Pump", "status": "idle" }
      }
    ]
  },
  "dimensions": ["location", "equipment_type"],
  "metrics": [
    { "field": "equipment_status", "aggregation": "first" }
  ]
}
```

**Result:** Properly flattened equipment data with separate fields for type and status

---

## ✅ Summary

**Enhancement:** Object detection and property flattening for numeric suffix fields

**Benefits:**
- ✅ Handles object fields with numeric suffixes correctly
- ✅ Flattens object properties as separate fields
- ✅ Compatible with Polars DataFrame structure
- ✅ Maintains backward compatibility
- ✅ Proper null handling

**Files Modified:**
- `src/processor/polars-rowpad.service.ts` (lines 408-514)

