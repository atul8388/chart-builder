# flattenWithRowPadding Function - Technical Details

## 🎯 The Problem

The `flattenWithRowPadding` function was **destroying the numeric suffix pattern** before the `detectAndGroupNumericSuffixes` function could process it.

### Root Cause

```typescript
// OLD CODE (Lines 35-50)
const flattenedObjects: Record<string, any> = {};
for (const [objKey, objValue] of Object.entries(objectFields)) {
  if (objValue && typeof objValue === 'object') {
    for (const [nestedKey, nestedValue] of Object.entries(objValue)) {
      flattenedObjects[`${objKey}_${nestedKey}`] = nestedValue;
    }
  }
}

// This pre-flattening destroyed the numeric suffix pattern!
// equipment-1: { type: "Drill" } → equipment_type: "Drill"
// equipment-2: { type: "Pump" } → equipment_type: "Pump"
// Now there's no -1, -2 suffix to detect!
```

---

## ✅ The Solution

### New Code (Lines 35-41)
```typescript
// NEW CODE - Pass objects directly without pre-flattening
const { groupedArrays, remainingFields } =
  this.detectAndGroupNumericSuffixes({
    ...scalarFields,
    ...objectFields,  // ✅ Keep numeric suffixes intact
  });
```

---

## 🔄 Data Flow Comparison

### OLD FLOW (Broken)
```
Input: equipment-1: { type: "Drill", status: "active" }
       equipment-2: { type: "Pump", status: "idle" }
         ↓
Pre-flatten: equipment_type: "Drill"
             equipment_status: "active"
             equipment_type: "Pump"
             equipment_status: "idle"
         ↓
Pass to detectAndGroupNumericSuffixes:
  { equipment_type: "Drill", equipment_status: "active", ... }
         ↓
Pattern matching: /^(.+?)[-_](\d+)$/
  - equipment_type: NO MATCH ❌
  - equipment_status: NO MATCH ❌
         ↓
Result: ❌ Objects not flattened to arrays
```

### NEW FLOW (Fixed)
```
Input: equipment-1: { type: "Drill", status: "active" }
       equipment-2: { type: "Pump", status: "idle" }
         ↓
Pass to detectAndGroupNumericSuffixes:
  { equipment-1: {...}, equipment-2: {...} }
         ↓
Pattern matching: /^(.+?)[-_](\d+)$/
  - equipment-1: MATCH ✅ (baseName: "equipment", index: 1)
  - equipment-2: MATCH ✅ (baseName: "equipment", index: 2)
         ↓
Type checking: isObjectField = true ✅
         ↓
Flatten properties:
  - equipment_type: ["Drill", "Pump"]
  - equipment_status: ["active", "idle"]
         ↓
Result: ✅ Objects properly flattened to arrays
```

---

## 📊 Data Structure Changes

### Before Fix
```javascript
// Input
{
  location: "North Pit",
  equipment-1: { type: "Drill", status: "active" },
  equipment-2: { type: "Pump", status: "idle" }
}

// After pre-flattening (WRONG)
{
  location: "North Pit",
  equipment_type: "Drill",
  equipment_status: "active",
  equipment_type: "Pump",  // ❌ Overwrites previous value!
  equipment_status: "idle"
}

// Result: Data loss and no arrays created
```

### After Fix
```javascript
// Input
{
  location: "North Pit",
  equipment-1: { type: "Drill", status: "active" },
  equipment-2: { type: "Pump", status: "idle" }
}

// Passed to detectAndGroupNumericSuffixes (CORRECT)
{
  location: "North Pit",
  "equipment-1": { type: "Drill", status: "active" },
  "equipment-2": { type: "Pump", status: "idle" }
}

// Result
{
  groupedArrays: {
    equipment_type: ["Drill", "Pump"],
    equipment_status: ["active", "idle"]
  },
  remainingFields: {
    location: "North Pit"
  }
}
```

---

## 🔍 Pattern Matching Details

### Numeric Suffix Pattern
```regex
/^(.+?)[-_](\d+)$/
```

**Breakdown:**
- `^` - Start of string
- `(.+?)` - Capture group 1: Base name (non-greedy)
- `[-_]` - Separator: dash or underscore
- `(\d+)` - Capture group 2: One or more digits
- `$` - End of string

**Examples:**
- `equipment-1` → baseName: "equipment", index: 1 ✅
- `equipment_1` → baseName: "equipment", index: 1 ✅
- `down_type-2` → baseName: "down_type", index: 2 ✅
- `item-10` → baseName: "item", index: 10 ✅
- `equipment` → NO MATCH ❌
- `equipment-a` → NO MATCH ❌

---

## 🧪 Test Case: Equipment Data

### Input
```json
{
  "location": "North Pit",
  "equipment-1": {
    "type": "Drill",
    "status": "active",
    "power": 500
  },
  "equipment-2": {
    "type": "Pump",
    "status": "idle",
    "power": 300
  }
}
```

### Processing Steps

**Step 1: Separate Fields**
```typescript
scalarFields: { location: "North Pit" }
objectFields: {
  "equipment-1": { type: "Drill", status: "active", power: 500 },
  "equipment-2": { type: "Pump", status: "idle", power: 300 }
}
arrayFields: {}
```

**Step 2: Detect Numeric Suffixes**
```typescript
groupMap: {
  equipment: [
    { index: 1, key: "equipment-1", value: {...} },
    { index: 2, key: "equipment-2", value: {...} }
  ]
}
```

**Step 3: Check if Object**
```typescript
isObjectField = true
objectKeys = ["type", "status", "power"]
```

**Step 4: Flatten Properties**
```typescript
groupedArrays: {
  equipment_type: ["Drill", "Pump"],
  equipment_status: ["active", "idle"],
  equipment_power: [500, 300]
}
```

**Step 5: Create DataFrame**
```
rn | location    | equipment_type | equipment_status | equipment_power
---|-------------|----------------|------------------|----------------
1  | North Pit   | Drill          | active           | 500
2  | North Pit   | Pump           | idle             | 300
```

---

## ✅ Summary

**Problem:** Pre-flattening destroyed numeric suffix pattern
**Solution:** Pass objects directly to detectAndGroupNumericSuffixes
**Result:** Objects with numeric suffixes now properly flattened to arrays
**Status:** ✅ Fixed and Ready

