# Nested Object Flattening Fix - Verification Guide

## Quick Summary
Fixed the issue where nested object fields were being excluded from `/chart-query` responses when they weren't explicitly defined in the form template.

## What Was Changed

### File: `src/processor/polars-rowpad.service.ts`

**Method 1: `filterFieldsByType()` (Line 249-254)**
- Changed: Skip fields not in template → Include fields not in template
- Reason: Flattened object fields need to be preserved

**Method 2: `flattenWithTemplateFilter()` (Line 346-350)**
- Changed: Skip columns not in template → Include columns not in template
- Reason: Flattened object fields need to be preserved

## Before vs After

### Before (❌ Missing nested object fields)
```json
{
  "data": [
    {
      "rn": 1,
      "cut_place": "North Pit",
      "cut_height": 45
      // ❌ form_section_itemId, form_section_answer missing!
      // ❌ form_shift_itemId, form_shift_answer missing!
    }
  ]
}
```

### After (✅ All fields included)
```json
{
  "data": [
    {
      "rn": 1,
      "cut_place": "North Pit",
      "cut_height": 45,
      "form_section_itemId": "127",
      "form_section_answer": "J-4 Panel",
      "form_shift_itemId": "58",
      "form_shift_answer": "Morning Shift"
    }
  ]
}
```

## How to Verify

### Test 1: Basic Flattening (No Template)
```powershell
$data = @{
    form_section = @{ itemId = "127"; answer = "J-4 Panel" }
    form_shift = @{ itemId = "58"; answer = "Morning Shift" }
}

$body = @{ data = $data } | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json-polars" `
    -Method Post -ContentType "application/json" -Body $body

# Should see: form_section_itemId, form_section_answer, form_shift_itemId, form_shift_answer
$response.data[0].PSObject.Properties.Name
```

### Test 2: Chart Query (With Template)
```powershell
$data = @{
    form_date = "2025-01-20"
    total_feet_mined = 150
    form_section = @{ itemId = "127"; answer = "J-4 Panel" }
    form_shift = @{ itemId = "58"; answer = "Morning Shift" }
    cut_place = "North Pit"
    cut_height = 45
}

$template = @{
    content = @{
        groups = @(
            @{
                items = @(
                    @{ properties = @{ key = "form_date"; type = "Date"; dateoptiontype = "date" } }
                    @{ properties = @{ key = "total_feet_mined"; inputoptiontype = "number" } }
                    @{ properties = @{ key = "cut_place"; inputoptiontype = "text" } }
                    @{ properties = @{ key = "cut_height"; inputoptiontype = "number" } }
                )
            }
        )
    }
}

$body = @{
    data = $data
    template = $template
    dimensions = @("cut_place")
    metrics = @(@{ field = "cut_height"; aggregation = "sum"; alias = "Total Height" })
} | ConvertTo-Json -Depth 10

$response = Invoke-RestMethod -Uri "http://localhost:3000/processor/chart-query" `
    -Method Post -ContentType "application/json" -Body $body

# Should see: form_section_itemId, form_section_answer, form_shift_itemId, form_shift_answer
$response.data[0].PSObject.Properties.Name
```

## Expected Results

✅ All nested object fields should appear in the response
✅ Fields are properly flattened with underscore separator
✅ No errors or warnings in console
✅ Works with both template-filtered and non-filtered queries

## Backward Compatibility

✅ No breaking changes
✅ Existing queries continue to work
✅ Only adds missing fields, doesn't remove anything
✅ Template filtering still works as expected

