# Test script for non-empty value filters
Write-Host "=== Testing Non-Empty Value Filters ===" -ForegroundColor Cyan

$baseUrl = "http://localhost:3000"

# Sample data with some empty/null values and empty strings
$testData = @{
    reports = @(
        @{
            location = "North Pit"
            crew_id = "CREW-001"
            supervisor = "John Smith"
            notes = "Good production"
            shifts = @(
                @{ shift_name = "Morning"; feet_mined = 150 }
                @{ shift_name = "Evening"; feet_mined = 120 }
            )
        },
        @{
            location = ""
            crew_id = "CREW-002"
            supervisor = "Jane Doe"
            notes = ""
            shifts = @(
                @{ shift_name = "Morning"; feet_mined = 100 }
            )
        },
        @{
            location = $null
            crew_id = $null
            supervisor = "Bob Wilson"
            notes = $null
            shifts = @(
                @{ shift_name = "Morning"; feet_mined = 200 }
            )
        },
        @{
            location = "East Pit"
            crew_id = "CREW-003"
            supervisor = ""
            notes = "Needs review"
            shifts = @(
                @{ shift_name = "Morning"; feet_mined = 80 }
            )
        }
    )
}

Write-Host "`n1. Show All Data (No Filters):" -ForegroundColor Yellow
$query1 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query1
    
    Write-Host "✅ All Data (including nulls):" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
    Write-Host "Row Count: $($response.metadata.rowCount)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n2. Filter: Show Only Non-Empty Locations (isNotNull):" -ForegroundColor Yellow
$query2 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{ field = "location"; operator = "isNotNull" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query2
    
    Write-Host "✅ Non-Empty Locations:" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
    Write-Host "Row Count: $($response.metadata.rowCount)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n3. Filter: Show Only Non-Empty Crew IDs (isNotNull):" -ForegroundColor Yellow
$query3 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{ field = "crew_id"; operator = "isNotNull" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query3
    
    Write-Host "✅ Non-Empty Crew IDs:" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
    Write-Host "Row Count: $($response.metadata.rowCount)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n4. Filter: Multiple Non-Empty Fields:" -ForegroundColor Yellow
$query4 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{ field = "location"; operator = "isNotNull" }
        @{ field = "crew_id"; operator = "isNotNull" }
        @{ field = "supervisor"; operator = "isNotNull" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query4
    
    Write-Host "✅ All Three Fields Non-Empty:" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
    Write-Host "Row Count: $($response.metadata.rowCount)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n5. Filter: Show Only Empty Locations (isNull):" -ForegroundColor Yellow
$query5 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{ field = "location"; operator = "isNull" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query5
    
    Write-Host "✅ Empty Locations:" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
    Write-Host "Row Count: $($response.metadata.rowCount)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n6. Filter: Non-Empty + Production > 100:" -ForegroundColor Yellow
$query6 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{ field = "location"; operator = "isNotNull" }
        @{ field = "shifts_feet_mined"; operator = "greaterThan"; value = 100 }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query6
    
    Write-Host "✅ Non-Empty Location + Production > 100:" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
    Write-Host "Row Count: $($response.metadata.rowCount)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n7. Filter: Show Only Non-Empty Strings (isNotEmpty):" -ForegroundColor Yellow
$query7 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{ field = "location"; operator = "isNotEmpty" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query7

    Write-Host "✅ Non-Empty Strings (isNotEmpty):" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
    Write-Host "Row Count: $($response.metadata.rowCount)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n8. Filter: Show Only Empty Strings (isEmpty):" -ForegroundColor Yellow
$query8 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{ field = "location"; operator = "isEmpty" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query8

    Write-Host "✅ Empty Strings (isEmpty):" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
    Write-Host "Row Count: $($response.metadata.rowCount)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n9. Filter: Non-Empty Location + Non-Empty Notes:" -ForegroundColor Yellow
$query9 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{ field = "location"; operator = "isNotEmpty" }
        @{ field = "notes"; operator = "isNotEmpty" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query9

    Write-Host "✅ Non-Empty Location + Non-Empty Notes:" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
    Write-Host "Row Count: $($response.metadata.rowCount)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n10. Filter: Show Records with Empty Notes (isEmpty):" -ForegroundColor Yellow
$query10 = @{
    data = $testData
    dimensions = @("location", "crew_id")
    metrics = @(
        @{ field = "supervisor"; aggregation = "first" }
        @{ field = "shifts_feet_mined"; aggregation = "sum"; alias = "total_feet" }
    )
    filters = @(
        @{ field = "notes"; operator = "isEmpty" }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $query10

    Write-Host "✅ Records with Empty Notes (isEmpty):" -ForegroundColor Green
    $response.data | Format-Table -AutoSize
    Write-Host "Row Count: $($response.metadata.rowCount)" -ForegroundColor Cyan
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n✅ All tests completed!" -ForegroundColor Green

