# Test script for Template-based Field Filtering with Groups Structure

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Template Groups Structure Tests" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Wait for server to be ready
Start-Sleep -Seconds 2

# Define template with groups structure (new format)
$template = @{
    groups = @(
        @{
            id = "group-0"
            name = "group-0"
            index = 0
            items = @(
                @{
                    id = "group-0-item-0"
                    index = 0
                    groupId = "group-0"
                    content = ""
                    properties = @{
                        inputoptiontype = "Header"
                        text = "Section Production Report"
                        key = "74B7E81A-A478-4476-8BFF-763DF88D6879"
                    }
                    key = "74B7E81A-A478-4476-8BFF-763DF88D6879"
                }
                @{
                    id = "group-0-item-1"
                    index = 1
                    groupId = "group-0"
                    content = ""
                    properties = @{
                        inputoptiontype = "Date"
                        label = "Form Date"
                        key = "form_date"
                    }
                    key = "form_date"
                }
                @{
                    id = "group-0-item-2"
                    index = 2
                    groupId = "group-0"
                    content = ""
                    properties = @{
                        inputoptiontype = "Text"
                        label = "Foreman"
                        key = "foreman"
                    }
                    key = "foreman"
                }
                @{
                    id = "group-0-item-3"
                    index = 3
                    groupId = "group-0"
                    content = ""
                    properties = @{
                        inputoptiontype = "Number"
                        label = "Number of Crew"
                        key = "num_crew"
                    }
                    key = "num_crew"
                }
                @{
                    id = "group-0-item-4"
                    index = 4
                    groupId = "group-0"
                    content = ""
                    properties = @{
                        inputoptiontype = "Number"
                        label = "Total Feet Mined"
                        key = "total_feet_mined"
                    }
                    key = "total_feet_mined"
                }
            )
        }
    )
}

# Define sample data
$data = @{
    "74B7E81A-A478-4476-8BFF-763DF88D6879" = ""
    form_date = "2025-10-14"
    foreman = "John Smith"
    num_crew = 5
    total_feet_mined = 120
    extra_field = "This should be filtered out"
}

# Test 1: Get all fields from template
Write-Host "`n--- Test 1: Get all fields from groups template ---" -ForegroundColor Yellow
$body1 = @{
    template = $template
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host "Getting all fields from template..."

try {
    $response1 = Invoke-RestMethod -Uri "http://localhost:3000/processor/get-fields-by-type" -Method Post -ContentType "application/json" -Body $body1
    Write-Host "`nResponse:" -ForegroundColor Green
    $response1 | ConvertTo-Json -Depth 10
    
    Write-Host "`n--- Expected Result ---" -ForegroundColor Magenta
    Write-Host "Should show 5 fields:" -ForegroundColor Magenta
    Write-Host "  - 74B7E81A-A478-4476-8BFF-763DF88D6879 (Header)" -ForegroundColor Magenta
    Write-Host "  - form_date (Date)" -ForegroundColor Magenta
    Write-Host "  - foreman (Text)" -ForegroundColor Magenta
    Write-Host "  - num_crew (Number)" -ForegroundColor Magenta
    Write-Host "  - total_feet_mined (Number)" -ForegroundColor Magenta
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 2: Get only 'Number' fields
Write-Host "`n`n--- Test 2: Get only 'Number' fields ---" -ForegroundColor Yellow
$body2 = @{
    template = $template
    filterType = "Number"
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host "Getting only 'Number' fields..."

try {
    $response2 = Invoke-RestMethod -Uri "http://localhost:3000/processor/get-fields-by-type" -Method Post -ContentType "application/json" -Body $body2
    Write-Host "`nResponse:" -ForegroundColor Green
    $response2 | ConvertTo-Json -Depth 10
    
    Write-Host "`n--- Expected Result ---" -ForegroundColor Magenta
    Write-Host "Should show 2 fields:" -ForegroundColor Magenta
    Write-Host "  - num_crew" -ForegroundColor Magenta
    Write-Host "  - total_feet_mined" -ForegroundColor Magenta
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 3: Flatten with template - only Number fields
Write-Host "`n`n--- Test 3: Flatten with template - only 'Number' fields ---" -ForegroundColor Yellow
$body3 = @{
    data = $data
    template = $template
    filterType = "Number"
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host "Flattening data with template filter (Number fields only)..."

try {
    $response3 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-with-template" -Method Post -ContentType "application/json" -Body $body3
    Write-Host "`nResponse:" -ForegroundColor Green
    $response3 | ConvertTo-Json -Depth 10
    
    Write-Host "`n--- Expected Result ---" -ForegroundColor Magenta
    Write-Host "Should show 1 row with only:" -ForegroundColor Magenta
    Write-Host "  - rn: 1" -ForegroundColor Magenta
    Write-Host "  - num_crew: 5" -ForegroundColor Magenta
    Write-Host "  - total_feet_mined: 120" -ForegroundColor Magenta
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

# Test 4: Flatten with template - all fields
Write-Host "`n`n--- Test 4: Flatten with template - all fields ---" -ForegroundColor Yellow
$body4 = @{
    data = $data
    template = $template
} | ConvertTo-Json -Depth 10

Write-Host "Request:" -ForegroundColor Green
Write-Host "Flattening data with template (all fields)..."

try {
    $response4 = Invoke-RestMethod -Uri "http://localhost:3000/processor/flatten-with-template" -Method Post -ContentType "application/json" -Body $body4
    Write-Host "`nResponse:" -ForegroundColor Green
    $response4 | ConvertTo-Json -Depth 10
    
    Write-Host "`n--- Expected Result ---" -ForegroundColor Magenta
    Write-Host "Should show 1 row with all template fields (extra_field excluded):" -ForegroundColor Magenta
    Write-Host "  - rn: 1" -ForegroundColor Magenta
    Write-Host "  - 74B7E81A-A478-4476-8BFF-763DF88D6879: ''" -ForegroundColor Magenta
    Write-Host "  - form_date: '2025-10-14'" -ForegroundColor Magenta
    Write-Host "  - foreman: 'John Smith'" -ForegroundColor Magenta
    Write-Host "  - num_crew: 5" -ForegroundColor Magenta
    Write-Host "  - total_feet_mined: 120" -ForegroundColor Magenta
} catch {
    Write-Host "`nError:" -ForegroundColor Red
    Write-Host $_.Exception.Message
}

Write-Host "`n`n========================================" -ForegroundColor Cyan
Write-Host "Groups Template Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

