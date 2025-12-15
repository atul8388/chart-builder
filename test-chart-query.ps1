# Test script for Chart Query API - BI-style analytics
# This demonstrates filtering, grouping, and aggregation for dynamic charts

$baseUrl = "http://localhost:3000"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Chart Query API Tests - BI Analytics" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Sample sales data
$salesData = @{
    sales = @(
        @{
            orderId = "ORD-001"
            customer = "John Doe"
            region = "North"
            category = "Electronics"
            product = "Laptop"
            quantity = 2
            price = 1200
            discount = 100
            orderDate = "2025-01-15"
        }
        @{
            orderId = "ORD-002"
            customer = "Jane Smith"
            region = "South"
            category = "Electronics"
            product = "Phone"
            quantity = 3
            price = 800
            discount = 50
        }
        @{
            orderId = "ORD-003"
            customer = "Bob Johnson"
            region = "North"
            category = "Furniture"
            product = "Desk"
            quantity = 1
            price = 500
            discount = 0
            orderDate = "2025-01-16"
        }
        @{
            orderId = "ORD-004"
            customer = "Alice Brown"
            region = "East"
            category = "Electronics"
            product = "Tablet"
            quantity = 4
            price = 600
            discount = 80
            orderDate = "2025-01-17"
        }
        @{
            orderId = "ORD-005"
            customer = "Charlie Wilson"
            region = "South"
            category = "Furniture"
            product = "Chair"
            quantity = 6
            price = 150
            discount = 20
            orderDate = "2025-01-18"
        }
    )
}

# Test 1: Group by region, sum quantity and price
Write-Host "--- Test 1: Sales by Region (Group + Aggregate) ---" -ForegroundColor Yellow
$query1 = @{
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
        @{
            field = "sales_orderId"
            aggregation = "count"
            alias = "order_count"
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Request: Group by region, sum quantity and price" -ForegroundColor Gray
$response1 = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" -Method Post -ContentType "application/json" -Body $query1
Write-Host "`nResponse:" -ForegroundColor Green
$response1 | ConvertTo-Json -Depth 10

Write-Host "`n--- Expected: 3 regions (North, South, East) with aggregated totals ---`n" -ForegroundColor Gray

# Test 2: Group by category, calculate average price
Write-Host "`n--- Test 2: Average Price by Category ---" -ForegroundColor Yellow
$query2 = @{
    data = $salesData
    dimensions = @("sales_category")
    metrics = @(
        @{
            field = "sales_price"
            aggregation = "avg"
            alias = "avg_price"
        }
        @{
            field = "sales_price"
            aggregation = "min"
            alias = "min_price"
        }
        @{
            field = "sales_price"
            aggregation = "max"
            alias = "max_price"
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Request: Group by category, calculate avg/min/max price" -ForegroundColor Gray
$response2 = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" -Method Post -ContentType "application/json" -Body $query2
Write-Host "`nResponse:" -ForegroundColor Green
$response2 | ConvertTo-Json -Depth 10

Write-Host "`n--- Expected: 2 categories (Electronics, Furniture) with price stats ---`n" -ForegroundColor Gray

# Test 3: Filter + Group (Electronics only, by region)
Write-Host "`n--- Test 3: Electronics Sales by Region (Filter + Group) ---" -ForegroundColor Yellow
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
            field = "sales_category"
            operator = "equals"
            value = "Electronics"
        }
    )
} | ConvertTo-Json -Depth 10

Write-Host "Request: Filter category=Electronics, group by region" -ForegroundColor Gray
$response3 = Invoke-RestMethod -Uri "$baseUrl/processor/chart-query" -Method Post -ContentType "application/json" -Body $query3
Write-Host "`nResponse:" -ForegroundColor Green
$response3 | ConvertTo-Json -Depth 10

Write-Host "`n--- Expected: Only Electronics sales, grouped by region ---`n" -ForegroundColor Gray

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Chart Query Tests Complete!" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

