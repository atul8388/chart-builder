# Grouped Properties Feature Guide

## Overview

The Polars flatten service now supports **automatic grouping of properties with numeric suffixes**. This feature detects properties like `down_type-1`, `down_type-2`, `down_type-3` and automatically groups them into rows instead of treating them as separate columns.

## How It Works

### Pattern Detection

The service detects properties that follow these patterns:
- **Dash separator**: `propertyName-1`, `propertyName-2`, `propertyName-3`
- **Underscore separator**: `propertyName_1`, `propertyName_2`, `propertyName_3`

### Grouping Logic

1. Properties with the same base name and numeric suffixes are identified
2. They are grouped together into an array
3. The array is expanded into multiple rows (just like regular arrays)
4. Each row gets one value from the grouped array

### Minimum Requirement

- At least **2 properties** with the same base name are required for grouping
- If only 1 property exists (e.g., only `down_type-1`), it's treated as a regular field

## Examples

### Example 1: Simple Grouped Properties

**Input:**
```json
{
  "data": {
    "orderId": "12345",
    "customer": "John Doe",
    "down_type-1": "Type A",
    "down_type-2": "Type B",
    "down_type-3": "Type C"
  }
}
```

**Output:**
```json
{
  "success": true,
  "rowCount": 3,
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type A"
    },
    {
      "rn": 2,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type B"
    },
    {
      "rn": 3,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type C"
    }
  ]
}
```

### Example 2: Multiple Grouped Properties

**Input:**
```json
{
  "data": {
    "orderId": "12345",
    "customer": "John Doe",
    "down_type-1": "Type A",
    "down_type-2": "Type B",
    "down_type-3": "Type C",
    "amount-1": 100,
    "amount-2": 200,
    "amount-3": 300
  }
}
```

**Output:**
```json
{
  "success": true,
  "rowCount": 3,
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type A",
      "amount": 100
    },
    {
      "rn": 2,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type B",
      "amount": 200
    },
    {
      "rn": 3,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type C",
      "amount": 300
    }
  ]
}
```

### Example 3: Different Lengths (Row Padding)

When grouped properties have different lengths, shorter groups are padded with `null`:

**Input:**
```json
{
  "data": {
    "orderId": "12345",
    "customer": "John Doe",
    "down_type-1": "Type A",
    "down_type-2": "Type B",
    "down_type-3": "Type C",
    "down_type-4": "Type D",
    "amount-1": 100,
    "amount-2": 200
  }
}
```

**Output:**
```json
{
  "success": true,
  "rowCount": 4,
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type A",
      "amount": 100
    },
    {
      "rn": 2,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type B",
      "amount": 200
    },
    {
      "rn": 3,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type C",
      "amount": null
    },
    {
      "rn": 4,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type D",
      "amount": null
    }
  ]
}
```

### Example 4: Combined with Regular Arrays

Grouped properties work seamlessly with regular arrays:

**Input:**
```json
{
  "data": {
    "orderId": "12345",
    "customer": "John Doe",
    "down_type-1": "Type A",
    "down_type-2": "Type B",
    "down_type-3": "Type C",
    "items": [
      {"product": "Laptop", "price": 1200},
      {"product": "Mouse", "price": 25}
    ]
  }
}
```

**Output:**
```json
{
  "success": true,
  "rowCount": 3,
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type A",
      "items_product": "Laptop",
      "items_price": 1200
    },
    {
      "rn": 2,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type B",
      "items_product": "Mouse",
      "items_price": 25
    },
    {
      "rn": 3,
      "orderId": "12345",
      "customer": "John Doe",
      "down_type": "Type C",
      "items_product": null,
      "items_price": null
    }
  ]
}
```

## Testing

Run the grouped properties test script:

```powershell
cd api-project
.\test-polars-grouped.ps1
```

This will run 6 comprehensive tests:
1. Grouped properties with dash separator
2. Grouped properties with underscore separator
3. Multiple grouped properties
4. Grouped properties with different lengths
5. Grouped properties + regular arrays
6. Complete test (grouped + nested objects + arrays)

## Use Cases

This feature is particularly useful for:
- **Form data** with repeated fields (e.g., `question-1`, `question-2`, `question-3`)
- **Survey responses** with numbered answers
- **Dynamic fields** generated with numeric suffixes
- **Legacy data** that uses numbered properties instead of arrays

## Technical Details

- **Regex Pattern**: `/^(.+?)[-_](\d+)$/`
- **Supported Separators**: Dash (`-`) and underscore (`_`)
- **Minimum Group Size**: 2 properties
- **Sorting**: Properties are sorted by their numeric index
- **Column Name**: Uses the base name without the numeric suffix

