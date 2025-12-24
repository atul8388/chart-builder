# Test script for getting distinct values for table filters
Write-Host "=== Testing Distinct Values for Table Filters ===" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"

# Sample data with multiple locations and crews
$testData = @{
    reports = @(
        @{
            report_date = "2025-01-20"
            location = "North Pit"
            crew_id = "CREW-001"
            supervisor = "John Smith"
            shifts = @(
                @{ shift_name = "Morning"; feet_mined = 150 }
                @{ shift_name = "Evening"; feet_mined = 120 }
            )
        },
        @{
            report_date = "2025-01-20"
            location = "South Pit"
            crew_id = "CREW-002"
            supervisor = "Jane Doe"
            shifts = @(
                @{ shift_name = "Morning"; feet_mined = 100 }
                @{ shift_name = "Evening"; feet_mined = 80 }
            )
        },
        @{
            report_date = "2025-01-20"
            location = "North Pit"
            crew_id = "CREW-003"
            supervisor = "Bob Wilson"
            shifts = @(
                @{ shift_name = "Morning"; feet_mined = 200 }
            )
        }
    )
}

Write-Host "`n1. Get Distinct Locations:" -ForegroundColor Yellow
$query1 = @{
    data = $testData
    dimensions = @("location")
    metrics = @(
        @{
            field = "location"
            aggregation = "countDistinct"
            alias = "count"
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query1
    
    Write-Host "✅ Distinct Locations:" -ForegroundColor Green
    $locations = $response.data | ForEach-Object { $_.location }
    $locations | ForEach-Object { Write-Host "  - $_" }
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n2. Get Distinct Crew IDs:" -ForegroundColor Yellow
$query2 = @{
    data = $testData
    dimensions = @("crew_id")
    metrics = @(
        @{
            field = "crew_id"
            aggregation = "countDistinct"
            alias = "count"
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query2
    
    Write-Host "✅ Distinct Crew IDs:" -ForegroundColor Green
    $crews = $response.data | ForEach-Object { $_.crew_id }
    $crews | ForEach-Object { Write-Host "  - $_" }
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n3. Get Table Data (All Rows):" -ForegroundColor Yellow
$query3 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "report_date"; aggregation = "first"; alias = "date" }
        @{ field = "supervisor"; aggregation = "first"; alias = "supervisor" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
        @{ field = "shifts_feet_mined"; aggregation = "avg"; alias = "avg_per_shift" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query3
    
    Write-Host "✅ Table Data:" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n4. Get Table Data (Filtered by Location = 'North Pit'):" -ForegroundColor Yellow
$query4 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "report_date"; aggregation = "first"; alias = "date" }
        @{ field = "supervisor"; aggregation = "first"; alias = "supervisor" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{
            field = "location"
            operator = "equals"
            value = "North Pit"
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query4
    
    Write-Host "✅ Filtered Table Data:" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n5. Get Table Data (Multiple Filters):" -ForegroundColor Yellow
$query5 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{ field = "location"; operator = "equals"; value = "North Pit" },
        @{ field = "crew_id"; operator = "equals"; value = "CREW-001" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query5
    
    Write-Host "✅ Multi-Filter Results:" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n✅ All tests completed!" -ForegroundColor Green

