# Polars Flatten Service

## Overview

A new JSON flattening service using **nodejs-polars** has been added to provide an alternative to the DuckDB-based flattening service. Both services provide the same functionality but use different underlying engines.

## Why Two Services?

- **DuckDB Service** (`/processor/flatten-json`): Uses DuckDB's SQL engine for advanced data processing
- **Polars Service** (`/processor/flatten-json-polars`): Uses nodejs-polars for pure JavaScript/TypeScript implementation

Both services support:

- ✅ Flattening nested objects (STRUCT types)
- ✅ Unnesting arrays with row padding
- ✅ Handling multiple arrays of different lengths
- ✅ Combining scalar fields, objects, and arrays

**Polars service exclusive features:**

- ✅ **Automatic grouping of properties with numeric suffixes** (e.g., `down_type-1`, `down_type-2`, `down_type-3`)
  - Detects properties with dash or underscore separators followed by numbers
  - Automatically groups them into rows instead of separate columns
  - See [GROUPED_PROPERTIES_GUIDE.md](./GROUPED_PROPERTIES_GUIDE.md) for details

## New Endpoint

**POST** `/processor/flatten-json-polars`

### Request Format

```json
{
  "data": {
    // Your JSON data here
  }
}
```

### Response Format

```json
{
  "success": true,
  "rowCount": 2,
  "engine": "polars",
  "data": [
    // Flattened rows here
  ]
}
```

## Examples

### Example 1: Simple Object (No Arrays)

**Request:**

```json
{
  "data": {
    "orderId": "12345",
    "customer": "John Doe",
    "total": 1225
  }
}
```

**Response:**

```json
{
  "success": true,
  "rowCount": 1,
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "orderId": "12345",
      "customer": "John Doe",
      "total": 1225
    }
  ]
}
```

### Example 2: Nested Object

**Request:**

```json
{
  "data": {
    "orderId": "12345",
    "customer": "John Doe",
    "form_section": {
      "itemId": "65",
      "answer": "Carloss_Sec3"
    }
  }
}
```

**Response:**

```json
{
  "success": true,
  "rowCount": 1,
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "orderId": "12345",
      "customer": "John Doe",
      "form_section_itemId": "65",
      "form_section_answer": "Carloss_Sec3"
    }
  ]
}
```

### Example 3: Array of Objects

**Request:**

```json
{
  "data": {
    "orderId": "12345",
    "customer": "John Doe",
    "items": [
      { "product": "Laptop", "price": 1200 },
      { "product": "Mouse", "price": 25 }
    ]
  }
}
```

**Response:**

```json
{
  "success": true,
  "rowCount": 2,
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "orderId": "12345",
      "customer": "John Doe",
      "items_product": "Laptop",
      "items_price": 1200
    },
    {
      "rn": 2,
      "orderId": "12345",
      "customer": "John Doe",
      "items_product": "Mouse",
      "items_price": 25
    }
  ]
}
```

### Example 4: Combined - Arrays + Nested Objects

**Request:**

```json
{
  "data": {
    "orderId": "12345",
    "customer": "John Doe",
    "form_section": {
      "itemId": "65",
      "answer": "Carloss_Sec3"
    },
    "items": [
      { "product": "Laptop", "price": 1200 },
      { "product": "Mouse", "price": 25 }
    ]
  }
}
```

**Response:**

```json
{
  "success": true,
  "rowCount": 2,
  "engine": "polars",
  "data": [
    {
      "rn": 1,
      "orderId": "12345",
      "customer": "John Doe",
      "form_section_itemId": "65",
      "form_section_answer": "Carloss_Sec3",
      "items_product": "Laptop",
      "items_price": 1200
    },
    {
      "rn": 2,
      "orderId": "12345",
      "customer": "John Doe",
      "form_section_itemId": "65",
      "form_section_answer": "Carloss_Sec3",
      "items_product": "Mouse",
      "items_price": 25
    }
  ]
}
```

## Testing

Run the Polars-specific test script:

```powershell
cd api-project
.\test-polars-api.ps1
```

This will run 5 comprehensive tests covering all scenarios.

## Implementation Details

### Files Created/Modified

1. **`src/processor/polars-rowpad.service.ts`** - New Polars service
2. **`src/processor/processor.module.ts`** - Updated to include Polars service
3. **`src/processor/processor.controller.ts`** - Added new `/flatten-json-polars` endpoint
4. **`test-polars-api.ps1`** - Test script for Polars endpoint

### Key Features

- Pure JavaScript/TypeScript implementation (no native dependencies like DuckDB)
- Same flattening logic as DuckDB service
- Handles BigInt conversion automatically
- Comprehensive error handling
- Detailed console logging for debugging
