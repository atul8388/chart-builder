# Advanced Chart Query Tests - Multiple dimensions, complex filters, sorting

$baseUrl = "http://localhost:3000"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Advanced Chart Query Tests" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Sample sales data with more fields
$salesData = @{
    sales = @(
        @{ region = "North"; category = "Electronics"; product = "Laptop"; quantity = 2; price = 1200; discount = 100 }
        @{ region = "South"; category = "Electronics"; product = "Phone"; quantity = 3; price = 800; discount = 50 }
        @{ region = "North"; category = "Furniture"; product = "Desk"; quantity = 1; price = 500; discount = 0 }
        @{ region = "East"; category = "Electronics"; product = "Tablet"; quantity = 4; price = 600; discount = 80 }
        @{ region = "South"; category = "Furniture"; product = "Chair"; quantity = 6; price = 150; discount = 20 }
        @{ region = "North"; category = "Electronics"; product = "Monitor"; quantity = 2; price = 400; discount = 40 }
        @{ region = "East"; category = "Furniture"; product = "Table"; quantity = 1; price = 800; discount = 0 }
        @{ region = "South"; category = "Electronics"; product = "Keyboard"; quantity = 5; price = 100; discount = 10 }
    )
}

# Test 1: Multi-dimensional grouping (region + category)
Write-Host "--- Test 1: Sales by Region AND Category (2D Grouping) ---" -ForegroundColor Yellow
$query1 = @{
    data = $salesData
    dimensions = @("sales_region", "sales_category")
    metrics = @(
        @{
            field = "sales_quantity"
            aggregation = "sum"
            alias = "total_quantity"
        }
        @{
            field = "sales_price"
            aggregation = "sum"
            alias = "total_revenue"
        }
    )
    sort = @(
        @{
            field = "total_revenue"
            direction = "desc"
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Request: Group by region AND category, sort by revenue desc" -ForegroundColor Gray
$response1 = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" -Method Post -ContentType "application/json" -Body $query1
Write-Host "`nResponse:" -ForegroundColor Green
$response1 | ConvertTo-Json -Depth 10

Write-Host "`n--- Expected: Multiple groups (North-Electronics, North-Furniture, etc.) sorted by revenue ---`n" -ForegroundColor Gray

# Test 2: Aggregate without grouping (overall totals)
Write-Host "`n--- Test 2: Overall Totals (No Grouping) ---" -ForegroundColor Yellow
$query2 = @{
    data = $salesData
    metrics = @(
        @{
            field = "sales_quantity"
            aggregation = "sum"
            alias = "grand_total_quantity"
        }
        @{
            field = "sales_price"
            aggregation = "sum"
            alias = "grand_total_revenue"
        }
        @{
            field = "sales_price"
            aggregation = "avg"
            alias = "avg_price"
        }
        @{
            field = "sales_product"
            aggregation = "countDistinct"
            alias = "unique_products"
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Request: Calculate overall totals without grouping" -ForegroundColor Gray
$response2 = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" -Method Post -ContentType "application/json" -Body $query2
Write-Host "`nResponse:" -ForegroundColor Green
$response2 | ConvertTo-Json -Depth 10

Write-Host "`n--- Expected: Single row with grand totals ---`n" -ForegroundColor Gray

# Test 3: Multiple filters with comparison operators
Write-Host "`n--- Test 3: High-Value Orders (Multiple Filters) ---" -ForegroundColor Yellow
$query3 = @{
    data = $salesData
    dimensions = @("sales_region")
    metrics = @(
        @{
            field = "sales_quantity"
            aggregation = "sum"
            alias = "total_quantity"
        }
        @{
            field = "sales_price"
            aggregation = "sum"
            alias = "total_revenue"
        }
    )
    filters = @(
        @{
            field = "sales_price"
            operator = "greaterThan"
            value = 300
        }
        @{
            field = "sales_quantity"
            operator = "greaterThanOrEqual"
            value = 2
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Request: Filter price > 300 AND quantity >= 2, group by region" -ForegroundColor Gray
$response3 = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" -Method Post -ContentType "application/json" -Body $query3
Write-Host "`nResponse:" -ForegroundColor Green
$response3 | ConvertTo-Json -Depth 10

Write-Host "`n--- Expected: Only high-value orders grouped by region ---`n" -ForegroundColor Gray

# Test 4: Top N results with limit
Write-Host "`n--- Test 4: Top 3 Products by Revenue ---" -ForegroundColor Yellow
$query4 = @{
    data = $salesData
    dimensions = @("sales_product")
    metrics = @(
        @{
            field = "sales_price"
            aggregation = "sum"
            alias = "revenue"
        }
        @{
            field = "sales_quantity"
            aggregation = "sum"
            alias = "units_sold"
        }
    )
    sort = @(
        @{
            field = "revenue"
            direction = "desc"
        }
    )
    limit = 3
} | ConvertTo-Json -Depth 10

Write-Host "Request: Group by product, sort by revenue desc, limit to top 3" -ForegroundColor Gray
$response4 = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" -Method Post -ContentType "application/json" -Body $query4
Write-Host "`nResponse:" -ForegroundColor Green
$response4 | ConvertTo-Json -Depth 10

Write-Host "`n--- Expected: Top 3 products by revenue ---`n" -ForegroundColor Gray

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Advanced Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

