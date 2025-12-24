# Nested Object Flattening Fix

## Problem

When sending a `/chart-query` API request with nested objects in the data, the flattened object fields were not appearing in the response.

### Example Issue

Input data:

```json
{
  "form_section": {
    "itemId": "127",
    "answer": "J-4 Panel"
  },
  "form_shift": {
    "itemId": "58",
    "answer": "Morning Shift"
  }
}
```

Expected flattened fields:

- `form_section_itemId`
- `form_section_answer`
- `form_shift_itemId`
- `form_shift_answer`

**But these fields were missing from the response!**

## Root Cause

Two methods in `polars-rowpad.service.ts` were filtering out columns that were not explicitly defined in the form template:

1. **`flattenWithTemplateFilter()`** (lines 300-404) - Used by `/chart-query` endpoint
2. **`filterFieldsByType()`** (lines 223-269) - Used by `/flatten-with-template` endpoint

When a nested object field like `form_section_answer` was not in the template's field types, it was being excluded from the final DataFrame.

## Solution

Modified the column selection logic in **both methods** to preserve flattened object fields:

### Change 1: `flattenWithTemplateFilter()` (lines 346-350)

**Before:**

```typescript
// If field is not in template, skip it
if (!fieldType) {
  continue; // ❌ This was skipping flattened object fields
}
```

**After:**

```typescript
// If field is not in template, include it anyway (flattened object fields)
// This ensures nested object fields like form_section_answer are preserved
if (!fieldType) {
  // Always include columns that are not in template (they're flattened object fields)
  columnsToSelect.push(column);
  continue;
}
```

### Change 2: `filterFieldsByType()` (lines 249-254)

**Before:**

```typescript
// If field is not in template, skip it
if (!fieldType) {
  continue; // ❌ This was skipping flattened object fields
}
```

**After:**

```typescript
// If field is not in template, include it anyway (flattened object fields)
// This ensures nested object fields like form_section_answer are preserved
if (!fieldType) {
  filtered[key] = value;
  continue;
}
```

## How It Works Now

1. **Flattening** (lines 35-43): Nested objects are flattened correctly
   - `form_section` → `form_section_itemId`, `form_section_answer`
   - `form_shift` → `form_shift_itemId`, `form_shift_answer`

2. **Template Filtering** (lines 327-362): All columns are now included
   - Fields in template: included based on filter type
   - Fields NOT in template: included anyway (these are flattened object fields)

3. **Result**: All flattened fields appear in the response

## Affected Endpoints

- ✅ `POST /processor/chart-query` - Now includes nested object fields
- ✅ `POST /processor/flatten-with-template` - Now includes nested object fields
- ✅ `POST /processor/flatten-json-polars` - Already working (no template filtering)

## Testing

Run the test script to verify:

```powershell
.\test-nested-object-fix.ps1
```

This will test:

1. Basic flattening with `flatten-json-polars` endpoint
2. Chart query with nested objects and template filtering

## Impact

- ✅ Nested object fields are now preserved in responses
- ✅ No breaking changes to existing functionality
- ✅ Works with both template-filtered and non-filtered queries
- ✅ Consistent behavior across all flattening endpoints

## Files Modified

- `src/processor/polars-rowpad.service.ts` - Updated 2 methods
