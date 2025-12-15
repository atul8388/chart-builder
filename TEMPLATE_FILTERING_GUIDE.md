# Template-Based Field Filtering Guide

## Overview

The Polars service now supports **template-based field filtering** that allows you to:

1. Define field types in a form template JSON
2. Extract a list of fields by type from the template
3. Flatten JSON data and filter fields based on their types from the template

This is particularly useful when you want to process only specific types of fields (e.g., only numeric fields for calculations, only text fields for text analysis).

## How It Works

### Template Structure

The service supports **two template formats**:

#### 1. Groups Structure (New Format)

Used for form builders with groups and items:

```json
{
  "groups": [
    {
      "id": "group-0",
      "name": "group-0",
      "items": [
        {
          "id": "item-0",
          "properties": {
            "type": "Number",
            "label": "Field Label",
            "key": "fieldName"
          }
        }
      ]
    }
  ]
}
```

The field name is in `properties.key` and the field type is in `properties.type`.

#### 2. Legacy Structure

Used for simple field definitions:

```json
{
  "fields": {
    "fieldName": {
      "inputoptiontype": "number",
      "label": "Field Label"
    }
  }
}
```

The field name is the object key and the field type is in `inputoptiontype`.

### Supported Field Types

Common field types include:

- `"Number"` or `"number"` - Numeric fields
- `"Text"` or `"text"` - Text fields
- `"Date"` or `"date"` - Date fields
- `"Header"` - Header fields
- Any custom type you define

### API Endpoints

#### 1. Get Fields by Type

**Endpoint**: `POST /processor/get-fields-by-type`

Extracts a list of field names from the template, optionally filtered by type.

**Request Body**:

```json
{
  "template": {
    /* your template */
  },
  "filterType": "number" // optional
}
```

**Response**:

```json
{
  "success": true,
  "filterType": "number",
  "fieldCount": 3,
  "fields": ["amount", "quantity", "discount"]
}
```

#### 2. Flatten with Template Filter

**Endpoint**: `POST /processor/flatten-with-template`

Flattens JSON data and filters fields based on the template.

**Request Body**:

```json
{
  "data": {
    /* your data */
  },
  "template": {
    /* your template */
  },
  "filterType": "number" // optional
}
```

**Response**:

```json
{
  "success": true,
  "rowCount": 1,
  "filterType": "number",
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "amount": 1500,
      "quantity": 3,
      "discount": 150
    }
  ]
}
```

## Examples

### Example 1: Groups Structure Template

**Template** (Groups Format):

```json
{
  "groups": [
    {
      "id": "group-0",
      "items": [
        {
          "properties": {
            "type": "Header",
            "key": "page_header"
          }
        },
        {
          "properties": {
            "type": "Date",
            "label": "Form Date",
            "key": "form_date"
          }
        },
        {
          "properties": {
            "type": "Text",
            "label": "Foreman",
            "key": "foreman"
          }
        },
        {
          "properties": {
            "type": "Number",
            "label": "Crew Size",
            "key": "num_crew"
          }
        },
        {
          "properties": {
            "type": "Number",
            "label": "Total Feet",
            "key": "total_feet"
          }
        }
      ]
    }
  ]
}
```

**Data**:

```json
{
  "page_header": "Production Report",
  "form_date": "2025-10-14",
  "foreman": "John Smith",
  "num_crew": 5,
  "total_feet": 120,
  "extra_field": "This will be filtered out"
}
```

**Request** (filter only Number fields):

```json
{
  "data": {
    /* data above */
  },
  "template": {
    /* template above */
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

Note: `extra_field` is excluded because it's not in the template.

### Example 2: Legacy Structure - Simple Field Filtering

**Template**:

```json
{
  "formId": "FORM001",
  "fields": {
    "orderId": {
      "inputoptiontype": "text",
      "label": "Order ID"
    },
    "customer": {
      "inputoptiontype": "text",
      "label": "Customer Name"
    },
    "amount": {
      "inputoptiontype": "number",
      "label": "Order Amount"
    },
    "quantity": {
      "inputoptiontype": "number",
      "label": "Quantity"
    }
  }
}
```

**Data**:

```json
{
  "orderId": "12345",
  "customer": "John Doe",
  "amount": 1500,
  "quantity": 3
}
```

**Request** (filter only number fields):

```json
{
  "data": {
    "orderId": "12345",
    "customer": "John Doe",
    "amount": 1500,
    "quantity": 3
  },
  "template": {
    /* template above */
  },
  "filterType": "number"
}
```

**Response**:

```json
{
  "success": true,
  "rowCount": 1,
  "filterType": "number",
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "amount": 1500,
      "quantity": 3
    }
  ]
}
```

### Example 3: Filtering with Arrays

**Template**:

```json
{
  "fields": {
    "orderId": { "inputoptiontype": "text" },
    "customer": { "inputoptiontype": "text" },
    "product": { "inputoptiontype": "text" },
    "price": { "inputoptiontype": "number" },
    "quantity": { "inputoptiontype": "number" }
  }
}
```

**Data**:

```json
{
  "orderId": "ORD-12345",
  "customer": "Jane Smith",
  "items": [
    { "product": "Laptop", "price": 1200, "quantity": 1 },
    { "product": "Mouse", "price": 25, "quantity": 2 }
  ]
}
```

**Request** (filter only number fields):

```json
{
  "data": {
    /* data above */
  },
  "template": {
    /* template above */
  },
  "filterType": "number"
}
```

**Response**:

```json
{
  "success": true,
  "rowCount": 2,
  "filterType": "number",
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "items_price": 1200,
      "items_quantity": 1
    },
    {
      "rn": 2,
      "items_price": 25,
      "items_quantity": 2
    }
  ]
}
```

### Example 4: Get Fields List

**Request**:

```json
{
  "template": {
    "fields": {
      "name": { "inputoptiontype": "text" },
      "age": { "inputoptiontype": "number" },
      "email": { "inputoptiontype": "text" },
      "salary": { "inputoptiontype": "number" }
    }
  },
  "filterType": "number"
}
```

**Response**:

```json
{
  "success": true,
  "filterType": "number",
  "fieldCount": 2,
  "fields": ["age", "salary"]
}
```

## Use Cases

1. **Numeric Analysis**: Filter only numeric fields for calculations, aggregations, or statistical analysis
2. **Text Processing**: Extract only text fields for NLP, search indexing, or text analysis
3. **Data Validation**: Validate specific field types separately
4. **Selective Export**: Export only certain types of fields to different systems
5. **Form Processing**: Process form submissions based on field types defined in form templates

## Testing

### Basic Test (Legacy Structure)

```powershell
cd api-project
.\test-template-filter.ps1
```

### Advanced Test (with arrays)

```powershell
cd api-project
.\test-template-advanced.ps1
```

### Groups Structure Test

```powershell
cd api-project
.\test-template-groups.ps1
```

## Technical Details

### Field Name Matching

The filtering logic handles both:

- **Direct field names**: `amount`, `quantity`
- **Flattened field names**: `items_price`, `items_quantity`

When a flattened field name is encountered (contains `_`), the system extracts the base field name (the part after the last `_`) and looks it up in the template.

### Reusable Service Methods

The implementation provides three reusable methods:

1. **`extractFieldTypes(template)`**: Extracts field types from template
2. **`filterFieldsByType(data, fieldTypes, filterType)`**: Filters a single data object
3. **`getFieldsByType(template, filterType)`**: Gets list of field names by type
4. **`flattenWithTemplateFilter(data, template, filterType)`**: Complete flatten + filter operation

These methods can be used independently or combined as needed.
