# Test Production Report Data - Comprehensive Test Suite
# Tests flattening, filtering, and chart queries for production report data

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Production Report API Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$baseUrl = "http://localhost:3000/processor"
$testsPassed = 0
$testsFailed = 0

# Production Report Data
$productionData = @{
    filterType = "number"
    data = @{
        "74B7E81A-A478-4476-8BFF-763DF88D6879" = ""
        form_date = "2025-10-08"
        foreman = "Charlie"
        form_section = @{
            itemId = "127"
            answer = "J-4 Panel"
        }
        form_shift = @{
            itemId = "58"
            answer = "Morning Shift"
        }
        time_in = "07:00"
        arrive_time = "07:15"
        on_coal_time = "07:15"
        quit_time = "03:00"
        incidents = "Incident(s)"
        num_crew = "5"
        num_crew_off = ""
        end_track_x_cut = ""
        total_feet_mined = "35"
        total_feet_bolted = "35"
        total_num_cars = "10"
        cm_bits_used = ""

        # Cut data (grouped properties with numeric suffixes)
        "cut_place-1" = "A"
        "cut_place-2" = "B"
        "cut_height-1" = "15"
        "cut_height-2" = "20"
        "cut_start_time-1" = "08:00"
        "cut_start_time-2" = "10:00"
        "cut_end_time-1" = "09:30"
        "cut_end_time-2" = "12:00"
        "cut_start_depth-1" = "0"
        "cut_start_depth-2" = "10"
        "cut_end_depth-1" = "15"
        "cut_end_depth-2" = "30"
        "cut_total_feet-1" = "15"
        "cut_total_feet-2" = "20"
        "cut_num_cars-1" = "2"
        "cut_num_cars-2" = "3"

        # Downtime data (grouped properties)
        "down_type-1" = @{
            itemId = "1"
            answer = "Inspection"
        }
        "down_type-2" = @{
            itemId = "4"
            answer = "Unplanned"
        }
        "down_duration-1" = "15"
        "down_duration-2" = "30"
        "down_start_time-1" = "10:00"
        "down_start_time-2" = "12:00"
        "down_production_lost_time-1" = "15"
        "down_production_lost_time-2" = "30"
        "down_end_time-1" = "10:15"
        "down_end_time-2" = "12:30"
        "down_equipment_id-1" = "EQ_01"
        "down_equipment_id-2" = "EQ_2"
        "down_reason-1" = "MAchine inspection"
        "down_reason-2" = "MAchine repair"

        section_condition = ""
        supplies_needed = ""
        utility_work_notes = ""
    }
}

Write-Host "Test Data Summary:" -ForegroundColor Yellow
Write-Host "  - Form Date: 2025-10-08" -ForegroundColor Gray
Write-Host "  - Foreman: Charlie" -ForegroundColor Gray
Write-Host "  - Section: J-4 Panel" -ForegroundColor Gray
Write-Host "  - Shift: Morning Shift" -ForegroundColor Gray
Write-Host "  - Total Feet Mined: 35" -ForegroundColor Gray
Write-Host "  - Cut Records: 2" -ForegroundColor Gray
Write-Host "  - Downtime Records: 2" -ForegroundColor Gray
Write-Host ""

# ============================================
# Test 1: Basic Flattening with Row Padding
# ============================================
Write-Host "Test 1: Basic Flattening with Row Padding" -ForegroundColor Yellow
try {
    $body = $productionData | ConvertTo-Json -Depth 10
    $response = Invoke-RestMethod -Uri "$baseUrl/flatten-json-polars" -Method Post -ContentType "application/json" -Body $body

    if ($response.success -and $response.data.Count -gt 0) {
        Write-Host "  ✓ PASSED - Flattened successfully" -ForegroundColor Green
        Write-Host "    Rows returned: $($response.data.Count)" -ForegroundColor Gray
        Write-Host "    Columns: $($response.data[0].PSObject.Properties.Name.Count)" -ForegroundColor Gray

        # Check if grouped properties were flattened
        $firstRow = $response.data[0]
        if ($firstRow.PSObject.Properties.Name -contains "cut_place") {
            Write-Host "    ✓ Grouped properties detected (cut_place)" -ForegroundColor Green
        }
        if ($firstRow.PSObject.Properties.Name -contains "down_type_answer") {
            Write-Host "    ✓ Nested objects flattened (down_type_answer)" -ForegroundColor Green
        }

        $testsPassed++
    } else {
        Write-Host "  ✗ FAILED - No data returned" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  ✗ FAILED - $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# ============================================
# Test 2: Filter by Number Type
# ============================================
Write-Host "Test 2: Filter by Number Type Fields" -ForegroundColor Yellow
try {
    $body = @{
        data = $productionData.data
        filterType = "number"
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri "$baseUrl/get-fields-by-type" -Method Post -ContentType "application/json" -Body $body

    if ($response.success -and $response.fields.Count -gt 0) {
        Write-Host "  ✓ PASSED - Number fields extracted" -ForegroundColor Green
        Write-Host "    Number fields found: $($response.fields.Count)" -ForegroundColor Gray
        Write-Host "    Fields: $($response.fields -join ', ')" -ForegroundColor Gray
        $testsPassed++
    } else {
        Write-Host "  ✗ FAILED - No number fields found" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  ✗ FAILED - $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# ============================================
# Test 3: Chart Query - Total Feet by Cut Place
# ============================================
Write-Host "Test 3: Chart Query - Total Feet by Cut Place (Bar Chart)" -ForegroundColor Yellow
try {
    $body = @{
        data = $productionData.data
        dimensions = @("cut_place")
        metrics = @(
            @{
                field = "cut_total_feet"
                aggregation = "sum"
                alias = "total_feet"
            }
        )
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri "$baseUrl/chart-query" -Method Post -ContentType "application/json" -Body $body

    if ($response.success -and $response.data.Count -gt 0) {
        Write-Host "  ✓ PASSED - Chart data generated" -ForegroundColor Green
        Write-Host "    Rows: $($response.data.Count)" -ForegroundColor Gray
        Write-Host "    Execution time: $($response.metadata.executionTime)ms" -ForegroundColor Gray

        foreach ($row in $response.data) {
            Write-Host "    - Cut Place: $($row.cut_place), Total Feet: $($row.total_feet)" -ForegroundColor Gray
        }

        $testsPassed++
    } else {
        Write-Host "  ✗ FAILED - No chart data returned" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  ✗ FAILED - $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# ============================================
# Test 4: Chart Query - Downtime Analysis
# ============================================
Write-Host "Test 4: Chart Query - Downtime by Type (Pie Chart)" -ForegroundColor Yellow
try {
    $body = @{
        data = $productionData.data
        dimensions = @("down_type_answer")
        metrics = @(
            @{
                field = "down_duration"
                aggregation = "sum"
                alias = "total_downtime"
            },
            @{
                field = "down_production_lost_time"
                aggregation = "sum"
                alias = "total_lost_time"
            }
        )
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri "$baseUrl/chart-query" -Method Post -ContentType "application/json" -Body $body

    if ($response.success -and $response.data.Count -gt 0) {
        Write-Host "  ✓ PASSED - Downtime analysis generated" -ForegroundColor Green
        Write-Host "    Downtime types: $($response.data.Count)" -ForegroundColor Gray

        foreach ($row in $response.data) {
            Write-Host "    - Type: $($row.down_type_answer), Duration: $($row.total_downtime)min, Lost Time: $($row.total_lost_time)min" -ForegroundColor Gray
        }

        $testsPassed++
    } else {
        Write-Host "  ✗ FAILED - No downtime data returned" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  ✗ FAILED - $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# ============================================
# Test 5: Chart Query - Production KPIs
# ============================================
Write-Host "Test 5: Chart Query - Production KPIs (Dashboard Cards)" -ForegroundColor Yellow
try {
    $body = @{
        data = $productionData.data
        metrics = @(
            @{
                field = "cut_total_feet"
                aggregation = "sum"
                alias = "total_feet_mined"
            },
            @{
                field = "cut_num_cars"
                aggregation = "sum"
                alias = "total_cars"
            },
            @{
                field = "down_duration"
                aggregation = "sum"
                alias = "total_downtime"
            },
            @{
                field = "cut_total_feet"
                aggregation = "avg"
                alias = "avg_feet_per_cut"
            }
        )
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri "$baseUrl/chart-query" -Method Post -ContentType "application/json" -Body $body

    if ($response.success -and $response.data.Count -gt 0) {
        Write-Host "  ✓ PASSED - KPIs calculated" -ForegroundColor Green
        $kpis = $response.data[0]
        Write-Host "    Total Feet Mined: $($kpis.total_feet_mined)" -ForegroundColor Gray
        Write-Host "    Total Cars: $($kpis.total_cars)" -ForegroundColor Gray
        Write-Host "    Total Downtime: $($kpis.total_downtime) minutes" -ForegroundColor Gray
        Write-Host "    Avg Feet per Cut: $($kpis.avg_feet_per_cut)" -ForegroundColor Gray

        $testsPassed++
    } else {
        Write-Host "  ✗ FAILED - No KPI data returned" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  ✗ FAILED - $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""


# ============================================
# Test 6: Chart Query - Equipment Downtime
# ============================================
Write-Host "Test 6: Chart Query - Downtime by Equipment (Bar Chart)" -ForegroundColor Yellow
try {
    $body = @{
        data = $productionData.data
        dimensions = @("down_equipment_id")
        metrics = @(
            @{
                field = "down_duration"
                aggregation = "sum"
                alias = "total_downtime"
            },
            @{
                field = "down_equipment_id"
                aggregation = "count"
                alias = "incident_count"
            }
        )
        sort = @(
            @{
                field = "total_downtime"
                direction = "desc"
            }
        )
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri "$baseUrl/chart-query" -Method Post -ContentType "application/json" -Body $body

    if ($response.success -and $response.data.Count -gt 0) {
        Write-Host "  ✓ PASSED - Equipment downtime analysis" -ForegroundColor Green

        foreach ($row in $response.data) {
            Write-Host "    - Equipment: $($row.down_equipment_id), Downtime: $($row.total_downtime)min, Incidents: $($row.incident_count)" -ForegroundColor Gray
        }

        $testsPassed++
    } else {
        Write-Host "  ✗ FAILED - No equipment data returned" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  ✗ FAILED - $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# ============================================
# Test 7: Chart Query - Cut Performance Analysis
# ============================================
Write-Host "Test 7: Chart Query - Cut Performance (Multi-metric)" -ForegroundColor Yellow
try {
    $body = @{
        data = $productionData.data
        dimensions = @("cut_place")
        metrics = @(
            @{
                field = "cut_total_feet"
                aggregation = "sum"
                alias = "total_feet"
            },
            @{
                field = "cut_num_cars"
                aggregation = "sum"
                alias = "total_cars"
            },
            @{
                field = "cut_height"
                aggregation = "avg"
                alias = "avg_height"
            }
        )
        sort = @(
            @{
                field = "total_feet"
                direction = "desc"
            }
        )
    } | ConvertTo-Json -Depth 10

    $response = Invoke-RestMethod -Uri "$baseUrl/chart-query" -Method Post -ContentType "application/json" -Body $body

    if ($response.success -and $response.data.Count -gt 0) {
        Write-Host "  ✓ PASSED - Cut performance analysis" -ForegroundColor Green

        foreach ($row in $response.data) {
            Write-Host "    - Place: $($row.cut_place), Feet: $($row.total_feet), Cars: $($row.total_cars), Avg Height: $($row.avg_height)" -ForegroundColor Gray
        }

        $testsPassed++
    } else {
        Write-Host "  ✗ FAILED - No cut performance data returned" -ForegroundColor Red
        $testsFailed++
    }
} catch {
    Write-Host "  ✗ FAILED - $($_.Exception.Message)" -ForegroundColor Red
    $testsFailed++
}
Write-Host ""

# ============================================
# Test Summary
# ============================================
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Tests: $($testsPassed + $testsFailed)" -ForegroundColor White
Write-Host "Passed: $testsPassed" -ForegroundColor Green
Write-Host "Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "🎉 All tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "❌ Some tests failed. Please check the output above." -ForegroundColor Red
    exit 1
}


