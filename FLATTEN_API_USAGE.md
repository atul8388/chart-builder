# Flatten JSON API Usage Guide

## Quick Test

### Test DuckDB Engine

Run the test script to verify the DuckDB API is working:

```powershell
cd api-project
.\test-flatten-api.ps1
```

### Test Polars Engine

Run the test script to verify the Polars API is working:

```powershell
cd api-project
.\test-polars-api.ps1
```

Both test scripts will test:

1. JSON without arrays (returns 1 row)
2. JSON with one array (returns multiple rows)
3. JSON with nested objects (flattens objects)
4. JSON with arrays and nested objects (flattens both)
5. JSON with multiple arrays of different lengths (pads shorter arrays with nulls)

## Endpoints

### DuckDB Engine (Default)

**POST** `/processor/flatten-json`

Uses DuckDB for JSON flattening with advanced SQL capabilities.

### Polars Engine (Alternative)

**POST** `/processor/flatten-json-polars`

Uses nodejs-polars for JSON flattening with pure JavaScript/TypeScript implementation.

Both endpoints accept the same request format and return the same response structure.

## Description

This endpoint flattens nested JSON data with arrays using DuckDB's row padding technique. It unnests arrays and pads rows to create a unified tabular structure.

## Request Format

```json
{
  "data": {
    // Your JSON object here
  }
}
```

## Example 1: Simple Array Flattening

### Request:

```bash
curl -X POST http://localhost:3000/processor/flatten-json \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "orderId": "12345",
      "customer": "John Doe",
      "items": [
        {"product": "Laptop", "price": 1200},
        {"product": "Mouse", "price": 25},
        {"product": "Keyboard", "price": 75}
      ]
    }
  }'
```

### Response:

```json
{
  "success": true,
  "rowCount": 3,
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
    },
    {
      "rn": 3,
      "orderId": "12345",
      "customer": "John Doe",
      "items_product": "Keyboard",
      "items_price": 75
    }
  ]
}
```

## Example 2: Multiple Arrays with Row Padding

### Request:

```bash
curl -X POST http://localhost:3000/processor/flatten-json \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "invoiceId": "INV-001",
      "products": [
        {"name": "Product A", "qty": 2},
        {"name": "Product B", "qty": 1}
      ],
      "payments": [
        {"method": "Credit Card", "amount": 100},
        {"method": "Cash", "amount": 50},
        {"method": "Gift Card", "amount": 25}
      ]
    }
  }'
```

### Response:

```json
{
  "success": true,
  "rowCount": 3,
  "data": [
    {
      "rn": 1,
      "invoiceId": "INV-001",
      "products_name": "Product A",
      "products_qty": 2,
      "payments_method": "Credit Card",
      "payments_amount": 100
    },
    {
      "rn": 2,
      "invoiceId": "INV-001",
      "products_name": "Product B",
      "products_qty": 1,
      "payments_method": "Cash",
      "payments_amount": 50
    },
    {
      "rn": 3,
      "invoiceId": "INV-001",
      "products_name": null,
      "products_qty": null,
      "payments_method": "Gift Card",
      "payments_amount": 25
    }
  ]
}
```

Note: When arrays have different lengths, shorter arrays are padded with `null` values.

## Example 3: Using PowerShell (Windows)

```powershell
$body = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        items = @(
            @{ product = "Laptop"; price = 1200 },
            @{ product = "Mouse"; price = 25 }
        )
    }
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json" `
    -Method Post `
    -ContentType "application/json" `
    -Body $body
```

## Response Format

### Success Response:

```json
{
  "success": true,
  "rowCount": <number>,
  "data": [<flattened rows>]
}
```

### Error Response:

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error information"
}
```

## Features

- ✅ Automatically detects and unnests array columns
- ✅ Pads shorter arrays with null values
- ✅ Preserves scalar (non-array) fields across all rows
- ✅ Adds row number (`rn`) for tracking
- ✅ Handles multiple arrays in the same JSON object
- ✅ Array fields are prefixed with array name (e.g., `items_product`)

## Notes

- The `data` field in the request body is required
- Arrays are automatically detected and unnested
- Scalar fields are repeated for each row
- Row numbers start from 1
- Empty arrays or missing data will result in an empty result set
