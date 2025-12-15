# Test script for Polars Grouped Properties (Numeric Suffixes)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing Polars Grouped Properties" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Wait for server to be ready
Start-Sleep -Seconds 2

# Test 1: Simple grouped properties (down_type-1, down_type-2, down_type-3)
Write-Host "`n--- Test 1: Grouped properties with dash separator ---" -ForegroundColor Yellow
$body1 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        "down_type-1" = "Type A"
        "down_type-2" = "Type B"
        "down_type-3" = "Type C"
    }
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body1

try {
    $response1 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json-polars" -Method Post -ContentType "application/json" -Body $body1
    Write-Host "`nResponse:" -ForegroundColor Green
    $response1 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 2: Grouped properties with underscore separator
Write-Host "`n`n--- Test 2: Grouped properties with underscore separator ---" -ForegroundColor Yellow
$body2 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        "payment_method_1" = "Credit Card"
        "payment_method_2" = "PayPal"
        "payment_method_3" = "Cash"
    }
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body2

try {
    $response2 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json-polars" -Method Post -ContentType "application/json" -Body $body2
    Write-Host "`nResponse:" -ForegroundColor Green
    $response2 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 3: Multiple grouped properties
Write-Host "`n`n--- Test 3: Multiple grouped properties ---" -ForegroundColor Yellow
$body3 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        "down_type-1" = "Type A"
        "down_type-2" = "Type B"
        "down_type-3" = "Type C"
        "amount-1" = 100
        "amount-2" = 200
        "amount-3" = 300
    }
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body3

try {
    $response3 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json-polars" -Method Post -ContentType "application/json" -Body $body3
    Write-Host "`nResponse:" -ForegroundColor Green
    $response3 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 4: Grouped properties with different lengths (should pad with nulls)
Write-Host "`n`n--- Test 4: Grouped properties with different lengths ---" -ForegroundColor Yellow
$body4 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        "down_type-1" = "Type A"
        "down_type-2" = "Type B"
        "down_type-3" = "Type C"
        "down_type-4" = "Type D"
        "amount-1" = 100
        "amount-2" = 200
    }
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body4

try {
    $response4 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json-polars" -Method Post -ContentType "application/json" -Body $body4
    Write-Host "`nResponse:" -ForegroundColor Green
    $response4 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 5: Grouped properties combined with regular arrays
Write-Host "`n`n--- Test 5: Grouped properties + regular arrays ---" -ForegroundColor Yellow
$body5 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        "down_type-1" = "Type A"
        "down_type-2" = "Type B"
        "down_type-3" = "Type C"
        items = @(
            @{ product = "Laptop"; price = 1200 }
            @{ product = "Mouse"; price = 25 }
        )
    }
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body5

try {
    $response5 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json-polars" -Method Post -ContentType "application/json" -Body $body5
    Write-Host "`nResponse:" -ForegroundColor Green
    $response5 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 6: Grouped properties + nested objects + arrays (complete test)
Write-Host "`n`n--- Test 6: Complete test (grouped + nested objects + arrays) ---" -ForegroundColor Yellow
$body6 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        form_section = @{
            itemId = "65"
            answer = "Carloss_Sec3"
        }
        "down_type-1" = "Type A"
        "down_type-2" = "Type B"
        "down_type-3" = "Type C"
        items = @(
            @{ product = "Laptop"; price = 1200 }
            @{ product = "Mouse"; price = 25 }
        )
    }
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body6

try {
    $response6 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json-polars" -Method Post -ContentType "application/json" -Body $body6
    Write-Host "`nResponse:" -ForegroundColor Green
    $response6 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n`n========================================" -ForegroundColor Cyan
Write-Host "Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

