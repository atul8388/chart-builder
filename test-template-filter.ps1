# Test script for Template-based Field Filtering

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing Template-Based Field Filtering" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Wait for server to be ready
Start-Sleep -Seconds 2

# Define a sample form template
$template = @{
    formId = "FORM001"
    fields = @{
        orderId = @{
            inputoptiontype = "text"
            label = "Order ID"
        }
        customer = @{
            inputoptiontype = "text"
            label = "Customer Name"
        }
        amount = @{
            inputoptiontype = "number"
            label = "Order Amount"
        }
        quantity = @{
            inputoptiontype = "number"
            label = "Quantity"
        }
        orderDate = @{
            inputoptiontype = "date"
            label = "Order Date"
        }
        notes = @{
            inputoptiontype = "text"
            label = "Notes"
        }
        discount = @{
            inputoptiontype = "number"
            label = "Discount"
        }
    }
}

# Define sample data
$data = @{
    orderId = "12345"
    customer = "John Doe"
    amount = 1500
    quantity = 3
    orderDate = "2025-12-10"
    notes = "Express delivery"
    discount = 150
}

# Test 1: Get all fields from template
Write-Host "`n--- Test 1: Get all fields from template ---" -ForegroundColor Yellow
$body1 = @{
    template = $template
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host "Getting all fields from template..."

try {
    $response1 = Invoke-RestMethod -Uri "http://localhost:3000/processor/get-fields-by-type" -Method Post -ContentType "application/json" -Body $body1
    Write-Host "`nResponse:" -ForegroundColor Green
    $response1 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 2: Get only number fields from template
Write-Host "`n`n--- Test 2: Get only 'number' fields from template ---" -ForegroundColor Yellow
$body2 = @{
    template = $template
    filterType = "number"
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host "Getting only 'number' type fields..."

try {
    $response2 = Invoke-RestMethod -Uri "http://localhost:3000/processor/get-fields-by-type" -Method Post -ContentType "application/json" -Body $body2
    Write-Host "`nResponse:" -ForegroundColor Green
    $response2 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 3: Get only text fields from template
Write-Host "`n`n--- Test 3: Get only 'text' fields from template ---" -ForegroundColor Yellow
$body3 = @{
    template = $template
    filterType = "text"
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host "Getting only 'text' type fields..."

try {
    $response3 = Invoke-RestMethod -Uri "http://localhost:3000/processor/get-fields-by-type" -Method Post -ContentType "application/json" -Body $body3
    Write-Host "`nResponse:" -ForegroundColor Green
    $response3 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 4: Flatten with template - no filter (all fields)
Write-Host "`n`n--- Test 4: Flatten with template - all fields ---" -ForegroundColor Yellow
$body4 = @{
    data = $data
    template = $template
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body4

try {
    $response4 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-with-template" -Method Post -ContentType "application/json" -Body $body4
    Write-Host "`nResponse:" -ForegroundColor Green
    $response4 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 5: Flatten with template - only number fields
Write-Host "`n`n--- Test 5: Flatten with template - only 'number' fields ---" -ForegroundColor Yellow
$body5 = @{
    data = $data
    template = $template
    filterType = "number"
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body5

try {
    $response5 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-with-template" -Method Post -ContentType "application/json" -Body $body5
    Write-Host "`nResponse:" -ForegroundColor Green
    $response5 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n`n========================================" -ForegroundColor Cyan
Write-Host "Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

