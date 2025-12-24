# Test script for new 'first' and 'last' aggregation functions
Write-Host "=== Testing First/Last Aggregation Functions ===" -ForegroundColor Cyan

# Test data with scalar fields and array items
$testData = @{
    report_date = "2025-01-20"
    location = "North Pit"
    crew_id = "CREW-001"
    shifts = @(
        @{ shift_name = "Morning"; feet_mined = 150 }
        @{ shift_name = "Evening"; feet_mined = 120 }
        @{ shift_name = "Night"; feet_mined = 100 }
    )
}

Write-Host "`n1. Testing 'first' aggregation (get first scalar value):" -ForegroundColor Yellow
$query1 = @{
    data = $testData
    dimensions = @("location")
    metrics = @(
        @{
            field = "report_date"
            aggregation = "first"
            alias = "report_date"
        }
        @{
            field = "crew_id"
            aggregation = "first"
            alias = "crew_id"
        }
        @{
            field = "shifts_feet_mined"
            aggregation = "sum"
            alias = "total_feet"
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query1
    
    Write-Host "✅ Response received" -ForegroundColor Green
    Write-Host "Result:" -ForegroundColor Cyan
    $response.data | ConvertTo-Json
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n2. Testing 'last' aggregation (get last scalar value):" -ForegroundColor Yellow
$query2 = @{
    data = $testData
    dimensions = @("location")
    metrics = @(
        @{
            field = "report_date"
            aggregation = "last"
            alias = "report_date"
        }
        @{
            field = "crew_id"
            aggregation = "last"
            alias = "crew_id"
        }
        @{
            field = "shifts_feet_mined"
            aggregation = "sum"
            alias = "total_feet"
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query2
    
    Write-Host "✅ Response received" -ForegroundColor Green
    Write-Host "Result:" -ForegroundColor Cyan
    $response.data | ConvertTo-Json
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n3. Testing mixed aggregations:" -ForegroundColor Yellow
$query3 = @{
    data = $testData
    dimensions = @("location")
    metrics = @(
        @{ field = "report_date"; aggregation = "first"; alias = "date" }
        @{ field = "crew_id"; aggregation = "first"; alias = "crew" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total" }
        @{ field = "shifts_feet_mined"; aggregation = "avg"; alias = "avg_per_shift" }
        @{ field = "shifts_feet_mined"; aggregation = "count"; alias = "shift_count" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query3
    
    Write-Host "✅ Response received" -ForegroundColor Green
    Write-Host "Result:" -ForegroundColor Cyan
    $response.data | ConvertTo-Json
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n✅ All tests completed!" -ForegroundColor Green

