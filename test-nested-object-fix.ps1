# Test script to verify nested object flattening fix
Write-Host "=== Testing Nested Object Flattening Fix ===" -ForegroundColor Cyan

# Test data with nested objects
$testData = @{
    form_date = "2025-01-20"
    total_feet_mined = 150
    form_section = @{
        itemId = "127"
        answer = "J-4 Panel"
    }
    form_shift = @{
        itemId = "58"
        answer = "Morning Shift"
    }
    cut_place = "North Pit"
    cut_height = 45
}

$requestBody = @{
    data = $testData
} | ConvertTo-Json -Depth 10

Write-Host "`n1. Testing flatten-json-polars endpoint (basic flattening):" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json-polars" `
        -Method Post -ContentType "application/json" -Body $requestBody
    
    Write-Host "✅ Response received" -ForegroundColor Green
    Write-Host "Available fields:" -ForegroundColor Cyan
    if ($response.data -and $response.data.Count -gt 0) {
        $response.data[0].PSObject.Properties.Name | Sort-Object | ForEach-Object {
            Write-Host "  - $_"
        }
    }
    
    Write-Host "`nFirst row data:" -ForegroundColor Cyan
    $response.data[0] | ConvertTo-Json
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n2. Testing chart-query endpoint (with template filtering):" -ForegroundColor Yellow

# Simple template
$template = @{
    content = @{
        groups = @(
            @{
                items = @(
                    @{ properties = @{ key = "form_date"; type = "Date"; dateoptiontype = "date" } }
                    @{ properties = @{ key = "total_feet_mined"; inputoptiontype = "number" } }
                    @{ properties = @{ key = "cut_place"; inputoptiontype = "text" } }
                    @{ properties = @{ key = "cut_height"; inputoptiontype = "number" } }
                )
            }
        )
    }
}

$chartQueryBody = @{
    data = $testData
    template = $template
    dimensions = @("cut_place")
    metrics = @(
        @{
            field = "cut_height"
            aggregation = "sum"
            alias = "Total Height"
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $response = Invoke-RestMethod -Uri "http://localhost:3000/processor/chart-query" `
        -Method Post -ContentType "application/json" -Body $chartQueryBody
    
    Write-Host "✅ Chart query response received" -ForegroundColor Green
    Write-Host "Response:" -ForegroundColor Cyan
    $response | ConvertTo-Json -Depth 5
    
    Write-Host "`nAvailable fields in response:" -ForegroundColor Cyan
    if ($response.data -and $response.data.Count -gt 0) {
        $response.data[0].PSObject.Properties.Name | Sort-Object | ForEach-Object {
            Write-Host "  - $_"
        }
    }
} catch {
    Write-Host "❌ Error: $_" -ForegroundColor Red
}

Write-Host "`n✅ Test completed!" -ForegroundColor Green

