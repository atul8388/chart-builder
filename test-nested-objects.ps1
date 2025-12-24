# Test script to verify nested object flattening
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
} | ConvertTo-Json -Depth 10

Write-Host "=== Testing Nested Object Flattening ===" -ForegroundColor Cyan
Write-Host "Input Data:" -ForegroundColor Yellow
Write-Host $testData

Write-Host "`n=== Testing flatten-json-polars endpoint ===" -ForegroundColor Cyan
$response = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-json-polars" -Method Post -ContentType "application/json" -Body $testData

Write-Host "Response:" -ForegroundColor Green
$response | ConvertTo-Json -Depth 10

Write-Host "`nAvailable fields:" -ForegroundColor Yellow
if ($response.data -and $response.data.Count -gt 0) {
    $response.data[0].PSObject.Properties.Name | Sort-Object
}

