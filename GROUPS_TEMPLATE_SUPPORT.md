# Groups Template Structure Support

## ✅ Successfully Added Support for Groups Template Structure!

### Overview

The `extractFieldTypes` function now supports **two template formats**:

1. **Groups Structure** (NEW) - For form builders with groups and items
2. **Legacy Structure** - For simple field definitions with `inputoptiontype`

This allows the template filtering feature to work with complex form builder templates where fields are organized in groups.

---

## Template Formats

### 1. Groups Structure (New Format)

Used for form builders where fields are organized in groups and items:

```json
{
  "groups": [
    {
      "id": "group-0",
      "name": "group-0",
      "index": 0,
      "items": [
        {
          "id": "group-0-item-0",
          "index": 0,
          "groupId": "group-0",
          "properties": {
            "type": "Header",
            "text": "Section Production Report",
            "key": "74B7E81A-A478-4476-8BFF-763DF88D6879"
          },
          "key": "74B7E81A-A478-4476-8BFF-763DF88D6879"
        },
        {
          "id": "group-0-item-1",
          "properties": {
            "type": "Date",
            "label": "Form Date",
            "key": "form_date"
          }
        },
        {
          "id": "group-0-item-2",
          "properties": {
            "type": "Number",
            "label": "Crew Size",
            "key": "num_crew"
          }
        }
      ]
    }
  ]
}
```

**Key Points**:
- Field name is in `properties.key`
- Field type is in `properties.type`
- Fields are nested in `groups[].items[]`
- The function iterates through all groups and items to extract field types

### 2. Legacy Structure

Used for simple field definitions:

```json
{
  "fields": {
    "form_date": {
      "inputoptiontype": "date",
      "label": "Form Date"
    },
    "num_crew": {
      "inputoptiontype": "number",
      "label": "Crew Size"
    }
  }
}
```

**Key Points**:
- Field name is the object key
- Field type is in `inputoptiontype`
- Recursively searches for fields with `inputoptiontype`

---

## How It Works

The `extractFieldTypes` function automatically detects which format is being used:

```typescript
extractFieldTypes(template: any): Map<string, string> {
  const fieldTypes = new Map<string, string>();

  // Check if template has groups structure (new format)
  if (template && Array.isArray(template.groups)) {
    // Process groups structure
    template.groups.forEach((group, groupIndex) => {
      if (Array.isArray(group.items)) {
        group.items.forEach((item, itemIndex) => {
          if (item.properties) {
            const fieldKey = item.properties.key;
            const fieldType = item.properties.type;
            
            if (fieldKey && fieldType) {
              fieldTypes.set(fieldKey, fieldType);
            }
          }
        });
      }
    });
    return fieldTypes;
  }

  // Otherwise, use legacy format processing
  // ... (recursive search for inputoptiontype)
}
```

---

## Example Usage

### Get Fields from Groups Template

**Request**:
```json
{
  "template": {
    "groups": [
      {
        "items": [
          { "properties": { "type": "Number", "key": "num_crew" } },
          { "properties": { "type": "Number", "key": "total_feet" } },
          { "properties": { "type": "Text", "key": "foreman" } }
        ]
      }
    ]
  },
  "filterType": "Number"
}
```

**Response**:
```json
{
  "success": true,
  "filterType": "Number",
  "fieldCount": 2,
  "fields": ["num_crew", "total_feet"]
}
```

### Flatten with Groups Template

**Request**:
```json
{
  "data": {
    "num_crew": 5,
    "total_feet": 120,
    "foreman": "John Smith",
    "extra_field": "Will be filtered out"
  },
  "template": {
    "groups": [
      {
        "items": [
          { "properties": { "type": "Number", "key": "num_crew" } },
          { "properties": { "type": "Number", "key": "total_feet" } },
          { "properties": { "type": "Text", "key": "foreman" } }
        ]
      }
    ]
  },
  "filterType": "Number"
}
```

**Response**:
```json
{
  "success": true,
  "rowCount": 1,
  "filterType": "Number",
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "num_crew": 5,
      "total_feet": 120
    }
  ]
}
```

Note: `extra_field` is excluded because it's not in the template, and `foreman` is excluded because it's not a Number type.

---

## Testing

Run the groups template test:

```powershell
cd api-project
.\test-template-groups.ps1
```

This test includes:
1. Get all fields from groups template
2. Get only 'Number' fields
3. Flatten with template - only 'Number' fields
4. Flatten with template - all fields (filters out fields not in template)

---

## Key Features

✅ **Automatic Format Detection** - Detects groups vs legacy structure automatically
✅ **Field Filtering** - Only includes fields defined in the template
✅ **Type-Based Filtering** - Filter by specific field types (Number, Text, Date, etc.)
✅ **Backward Compatible** - Legacy templates still work
✅ **Logging** - Console logs show which format is being used and which fields are found

---

## Files Modified

- **`src/processor/polars-rowpad.service.ts`** - Updated `extractFieldTypes` and `filterFieldsByType` methods
- **`TEMPLATE_FILTERING_GUIDE.md`** - Updated with groups structure documentation

## Files Created

- **`test-template-groups.ps1`** - Test script for groups template structure
- **`GROUPS_TEMPLATE_SUPPORT.md`** - This documentation file

---

## Summary

The template filtering feature now supports complex form builder templates with groups structure, making it perfect for:
- Form builder applications
- Dynamic form processing
- Multi-section forms
- Grouped field definitions

All existing functionality remains backward compatible with legacy templates! 🎉

