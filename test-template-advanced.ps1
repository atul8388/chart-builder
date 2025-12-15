# Advanced Test script for Template-based Field Filtering with Arrays

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Advanced Template Filtering Tests" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Wait for server to be ready
Start-Sleep -Seconds 2

# Define a complex form template with nested fields
$template = @{
    formId = "FORM002"
    fields = @{
        orderId = @{
            inputoptiontype = "text"
            label = "Order ID"
        }
        customer = @{
            inputoptiontype = "text"
            label = "Customer Name"
        }
        totalAmount = @{
            inputoptiontype = "number"
            label = "Total Amount"
        }
        product = @{
            inputoptiontype = "text"
            label = "Product Name"
        }
        price = @{
            inputoptiontype = "number"
            label = "Product Price"
        }
        quantity = @{
            inputoptiontype = "number"
            label = "Quantity"
        }
        category = @{
            inputoptiontype = "text"
            label = "Category"
        }
    }
}

# Define complex data with arrays
$data = @{
    orderId = "ORD-12345"
    customer = "Jane Smith"
    totalAmount = 2450
    items = @(
        @{
            product = "Laptop"
            price = 1200
            quantity = 1
            category = "Electronics"
        }
        @{
            product = "Mouse"
            price = 25
            quantity = 2
            category = "Accessories"
        }
        @{
            product = "Keyboard"
            price = 75
            quantity = 1
            category = "Accessories"
        }
    )
}

# Test 1: Flatten with template - all fields (including arrays)
Write-Host "`n--- Test 1: Flatten complex data - all fields ---" -ForegroundColor Yellow
$body1 = @{
    data = $data
    template = $template
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host "Flattening data with arrays - all fields..."

try {
    $response1 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-with-template" -Method Post -ContentType "application/json" -Body $body1
    Write-Host "`nResponse:" -ForegroundColor Green
    $response1 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 2: Flatten with template - only number fields
Write-Host "`n`n--- Test 2: Flatten complex data - only 'number' fields ---" -ForegroundColor Yellow
$body2 = @{
    data = $data
    template = $template
    filterType = "number"
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host "Flattening data with arrays - only number fields..."

try {
    $response2 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-with-template" -Method Post -ContentType "application/json" -Body $body2
    Write-Host "`nResponse:" -ForegroundColor Green
    $response2 | ConvertTo-Json -Depth 10
    
    Write-Host "`n--- Expected Result ---" -ForegroundColor Magenta
    Write-Host "Should show 3 rows (one per item) with only:" -ForegroundColor Magenta
    Write-Host "  - rn (row number)" -ForegroundColor Magenta
    Write-Host "  - totalAmount (number field)" -ForegroundColor Magenta
    Write-Host "  - items_price (number field from array)" -ForegroundColor Magenta
    Write-Host "  - items_quantity (number field from array)" -ForegroundColor Magenta
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 3: Flatten with template - only text fields
Write-Host "`n`n--- Test 3: Flatten complex data - only 'text' fields ---" -ForegroundColor Yellow
$body3 = @{
    data = $data
    template = $template
    filterType = "text"
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host "Flattening data with arrays - only text fields..."

try {
    $response3 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-with-template" -Method Post -ContentType "application/json" -Body $body3
    Write-Host "`nResponse:" -ForegroundColor Green
    $response3 | ConvertTo-Json -Depth 10
    
    Write-Host "`n--- Expected Result ---" -ForegroundColor Magenta
    Write-Host "Should show 3 rows (one per item) with only:" -ForegroundColor Magenta
    Write-Host "  - rn (row number)" -ForegroundColor Magenta
    Write-Host "  - orderId (text field)" -ForegroundColor Magenta
    Write-Host "  - customer (text field)" -ForegroundColor Magenta
    Write-Host "  - items_product (text field from array)" -ForegroundColor Magenta
    Write-Host "  - items_category (text field from array)" -ForegroundColor Magenta
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n`n========================================" -ForegroundColor Cyan
Write-Host "Advanced Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

