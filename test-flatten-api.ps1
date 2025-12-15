# Test script for the Flatten JSON API

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing Flatten JSON API" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Wait for server to be ready
Start-Sleep -Seconds 3

# Test 1: JSON without arrays (should return 1 row)
Write-Host "`n--- Test 1: JSON WITHOUT arrays ---" -ForegroundColor Yellow
$body1 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        total = 1225
    }
} | ConvertTo-Json

Write-Host "Request:" -ForegroundColor Green
Write-Host $body1

try {
    $response1 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json" -Method Post -ContentType "application/json" -Body $body1
    Write-Host "`nResponse:" -ForegroundColor Green
    $response1 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 2: JSON with one array (should return multiple rows)
Write-Host "`n`n--- Test 2: JSON WITH one array ---" -ForegroundColor Yellow
$body2 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        items = @(
            @{ product = "Laptop"; price = 1200 }
            @{ product = "Mouse"; price = 25 }
        )
    }
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body2

try {
    $response2 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json" -Method Post -ContentType "application/json" -Body $body2
    Write-Host "`nResponse:" -ForegroundColor Green
    $response2 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 3: JSON with nested object (should flatten object)
Write-Host "`n`n--- Test 3: JSON WITH nested object ---" -ForegroundColor Yellow
$body3 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        form_section = @{
            itemId = "65"
            answer = "Carloss_Sec3"
        }
    }
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body3

try {
    $response3 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json" -Method Post -ContentType "application/json" -Body $body3
    Write-Host "`nResponse:" -ForegroundColor Green
    $response3 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 4: JSON with array AND nested object (should flatten both)
Write-Host "`n`n--- Test 4: JSON WITH array AND nested object ---" -ForegroundColor Yellow
$body4 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        form_section = @{
            itemId = "65"
            answer = "Carloss_Sec3"
        }
        items = @(
            @{ product = "Laptop"; price = 1200 }
            @{ product = "Mouse"; price = 25 }
        )
    }
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body4

try {
    $response4 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json" -Method Post -ContentType "application/json" -Body $body4
    Write-Host "`nResponse:" -ForegroundColor Green
    $response4 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 5: JSON with multiple arrays of different lengths (should pad shorter arrays)
Write-Host "`n`n--- Test 5: JSON WITH multiple arrays (different lengths) ---" -ForegroundColor Yellow
$body5 = @{
    data = @{
        orderId = "12345"
        customer = "John Doe"
        items = @(
            @{ product = "Laptop"; price = 1200 }
            @{ product = "Mouse"; price = 25 }
            @{ product = "Keyboard"; price = 75 }
        )
        payments = @(
            @{ method = "Credit Card"; amount = 1000 }
            @{ method = "Cash"; amount = 300 }
        )
    }
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host $body3

try {
    $response5 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json" -Method Post -ContentType "application/json" -Body $body5
    Write-Host "`nResponse:" -ForegroundColor Green
    $response5 | ConvertTo-Json -Depth 10
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n`n========================================" -ForegroundColor Cyan
Write-Host "Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

