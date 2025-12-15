# Production Report Testing Guide

## Overview

This guide covers automated testing for production report data with the BI Analytics API. The test suite validates flattening, filtering, and chart query capabilities using real-world mining production data.

---

## Test Data Structure

### Production Report Fields

**Form Information:**
- `form_date` - Report date (2025-10-08)
- `foreman` - Foreman name (Charlie)
- `form_section` - Section details (J-4 Panel)
- `form_shift` - Shift information (Morning Shift)
- `time_in`, `arrive_time`, `on_coal_time`, `quit_time` - Time tracking

**Production Metrics:**
- `num_crew` - Number of crew members (5)
- `total_feet_mined` - Total feet mined (35)
- `total_feet_bolted` - Total feet bolted (35)
- `total_num_cars` - Total number of cars (10)

**Cut Data (Grouped Properties with Numeric Suffixes):**
- `cut_place-1`, `cut_place-2` - Cut locations (A, B)
- `cut_height-1`, `cut_height-2` - Cut heights (15, 20)
- `cut_start_time-1`, `cut_start_time-2` - Start times
- `cut_end_time-1`, `cut_end_time-2` - End times
- `cut_start_depth-1`, `cut_start_depth-2` - Start depths (0, 10)
- `cut_end_depth-1`, `cut_end_depth-2` - End depths (15, 30)
- `cut_total_feet-1`, `cut_total_feet-2` - Total feet per cut (15, 20)
- `cut_num_cars-1`, `cut_num_cars-2` - Cars per cut (2, 3)

**Downtime Data (Grouped Properties with Nested Objects):**
- `down_type-1`, `down_type-2` - Downtime types (Inspection, Unplanned)
- `down_duration-1`, `down_duration-2` - Duration in minutes (15, 30)
- `down_start_time-1`, `down_start_time-2` - Start times
- `down_end_time-1`, `down_end_time-2` - End times
- `down_production_lost_time-1`, `down_production_lost_time-2` - Lost time (15, 30)
- `down_equipment_id-1`, `down_equipment_id-2` - Equipment IDs (EQ_01, EQ_2)
- `down_reason-1`, `down_reason-2` - Downtime reasons

---

## Test Suite

### Test 1: Basic Flattening with Row Padding

**Purpose:** Validate that nested objects and grouped properties are flattened correctly

**Endpoint:** `POST /processor/flatten-json-polars`

**Expected Results:**
- ✅ Multiple rows created (one per cut/downtime record)
- ✅ Nested objects flattened (e.g., `form_section` → `form_section_itemId`, `form_section_answer`)
- ✅ Grouped properties detected (e.g., `cut_place-1`, `cut_place-2` → `cut_place` column)
- ✅ Row padding applied for shorter arrays

**Validation:**
```powershell
# Check for flattened columns
$firstRow.PSObject.Properties.Name -contains "cut_place"
$firstRow.PSObject.Properties.Name -contains "down_type_answer"
```

---

### Test 2: Filter by Number Type

**Purpose:** Extract only numeric fields from the production report

**Endpoint:** `POST /processor/get-fields-by-type`

**Request:**
```json
{
  "data": { /* production data */ },
  "filterType": "number"
}
```

**Expected Fields:**
- `num_crew`, `total_feet_mined`, `total_feet_bolted`, `total_num_cars`
- `cut_height`, `cut_start_depth`, `cut_end_depth`, `cut_total_feet`, `cut_num_cars`
- `down_duration`, `down_production_lost_time`

---

### Test 3: Chart Query - Total Feet by Cut Place

**Purpose:** Generate bar chart data showing total feet mined by cut location

**Chart Type:** Bar Chart

**Request:**
```json
{
  "data": { /* production data */ },
  "dimensions": ["cut_place"],
  "metrics": [
    {
      "field": "cut_total_feet",
      "aggregation": "sum",
      "alias": "total_feet"
    }
  ]
}
```

**Expected Response:**
```json
{
  "success": true,
  "data": [
    { "cut_place": "A", "total_feet": 15 },
    { "cut_place": "B", "total_feet": 20 }
  ],
  "metadata": {
    "rowCount": 2,
    "dimensions": ["cut_place"],
    "metrics": ["total_feet"]
  }
}
```

**Use Case:** Visualize production by location

---

### Test 4: Chart Query - Downtime Analysis

**Purpose:** Analyze downtime by type for pie chart visualization

**Chart Type:** Pie Chart

**Request:**
```json
{
  "dimensions": ["down_type_answer"],
  "metrics": [
    { "field": "down_duration", "aggregation": "sum", "alias": "total_downtime" },
    { "field": "down_production_lost_time", "aggregation": "sum", "alias": "total_lost_time" }
  ]
}
```

**Expected Response:**
```json
{
  "data": [
    { "down_type_answer": "Inspection", "total_downtime": 15, "total_lost_time": 15 },
    { "down_type_answer": "Unplanned", "total_downtime": 30, "total_lost_time": 30 }
  ]
}
```

**Use Case:** Understand downtime distribution by type

---

### Test 5: Chart Query - Production KPIs

**Purpose:** Calculate key performance indicators for dashboard cards

**Chart Type:** KPI Cards

**Request:**
```json
{
  "metrics": [
    { "field": "cut_total_feet", "aggregation": "sum", "alias": "total_feet_mined" },
    { "field": "cut_num_cars", "aggregation": "sum", "alias": "total_cars" },
    { "field": "down_duration", "aggregation": "sum", "alias": "total_downtime" },
    { "field": "cut_total_feet", "aggregation": "avg", "alias": "avg_feet_per_cut" }
  ]
}
```

**Expected Response:**
```json
{
  "data": [
    {
      "total_feet_mined": 35,
      "total_cars": 5,
      "total_downtime": 45,
      "avg_feet_per_cut": 17.5
    }
  ]
}
```

**Use Case:** Display key metrics on production dashboard

---

### Test 6: Chart Query - Equipment Downtime

**Purpose:** Analyze downtime by equipment with sorting

**Chart Type:** Bar Chart (sorted)

**Request:**
```json
{
  "dimensions": ["down_equipment_id"],
  "metrics": [
    { "field": "down_duration", "aggregation": "sum", "alias": "total_downtime" },
    { "field": "down_equipment_id", "aggregation": "count", "alias": "incident_count" }
  ],
  "sort": [
    { "field": "total_downtime", "direction": "desc" }
  ]
}
```

**Expected Response:**
```json
{
  "data": [
    { "down_equipment_id": "EQ_2", "total_downtime": 30, "incident_count": 1 },
    { "down_equipment_id": "EQ_01", "total_downtime": 15, "incident_count": 1 }
  ]
}
```

**Use Case:** Identify equipment with most downtime

---

### Test 7: Chart Query - Cut Performance Analysis

**Purpose:** Multi-metric analysis of cut performance

**Chart Type:** Grouped Bar Chart

**Request:**
```json
{
  "dimensions": ["cut_place"],
  "metrics": [
    { "field": "cut_total_feet", "aggregation": "sum", "alias": "total_feet" },
    { "field": "cut_num_cars", "aggregation": "sum", "alias": "total_cars" },
    { "field": "cut_height", "aggregation": "avg", "alias": "avg_height" }
  ],
  "sort": [
    { "field": "total_feet", "direction": "desc" }
  ]
}
```

**Use Case:** Compare performance metrics across cut locations

---

## Running the Tests

### Prerequisites

1. **Start the server:**
   ```bash
   cd api-project
   npm run start:dev
   ```

2. **Verify server is running:**
   ```bash
   curl http://localhost:3000
   ```

### Execute Test Suite

```powershell
.\test-production-report.ps1
```

### Expected Output

```
========================================
Production Report API Test Suite
========================================

Test Data Summary:
  - Form Date: 2025-10-08
  - Foreman: Charlie
  - Section: J-4 Panel
  - Shift: Morning Shift
  - Total Feet Mined: 35
  - Cut Records: 2
  - Downtime Records: 2

Test 1: Basic Flattening with Row Padding
  ✓ PASSED - Flattened successfully
    Rows returned: 2
    Columns: 45
    ✓ Grouped properties detected (cut_place)
    ✓ Nested objects flattened (down_type_answer)

Test 2: Filter by Number Type Fields
  ✓ PASSED - Number fields extracted
    Number fields found: 12

Test 3: Chart Query - Total Feet by Cut Place (Bar Chart)
  ✓ PASSED - Chart data generated
    - Cut Place: A, Total Feet: 15
    - Cut Place: B, Total Feet: 20

Test 4: Chart Query - Downtime by Type (Pie Chart)
  ✓ PASSED - Downtime analysis generated
    - Type: Inspection, Duration: 15min, Lost Time: 15min
    - Type: Unplanned, Duration: 30min, Lost Time: 30min

Test 5: Chart Query - Production KPIs (Dashboard Cards)
  ✓ PASSED - KPIs calculated
    Total Feet Mined: 35
    Total Cars: 5
    Total Downtime: 45 minutes
    Avg Feet per Cut: 17.5

Test 6: Chart Query - Downtime by Equipment (Bar Chart)
  ✓ PASSED - Equipment downtime analysis
    - Equipment: EQ_2, Downtime: 30min, Incidents: 1
    - Equipment: EQ_01, Downtime: 15min, Incidents: 1

Test 7: Chart Query - Cut Performance (Multi-metric)
  ✓ PASSED - Cut performance analysis
    - Place: B, Feet: 20, Cars: 3, Avg Height: 20
    - Place: A, Feet: 15, Cars: 2, Avg Height: 15

========================================
Test Summary
========================================
Total Tests: 7
Passed: 7
Failed: 0

🎉 All tests passed!
```

---

## Chart Visualizations

### 1. Production by Location (Bar Chart)
- **X-Axis:** Cut Place (A, B)
- **Y-Axis:** Total Feet Mined
- **Data:** Test 3 results

### 2. Downtime Distribution (Pie Chart)
- **Segments:** Downtime Type (Inspection, Unplanned)
- **Values:** Total Downtime Minutes
- **Data:** Test 4 results

### 3. Dashboard KPIs (Cards)
- **Card 1:** Total Feet Mined (35)
- **Card 2:** Total Cars (5)
- **Card 3:** Total Downtime (45 min)
- **Card 4:** Avg Feet per Cut (17.5)
- **Data:** Test 5 results

### 4. Equipment Downtime (Horizontal Bar Chart)
- **Y-Axis:** Equipment ID
- **X-Axis:** Total Downtime (sorted desc)
- **Data:** Test 6 results

### 5. Cut Performance (Grouped Bar Chart)
- **X-Axis:** Cut Place
- **Y-Axis:** Multiple metrics (Feet, Cars, Height)
- **Data:** Test 7 results

---

## Integration Example

```javascript
// Fetch production KPIs
async function loadProductionKPIs(productionData) {
  const response = await fetch('/processor/chart-query', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      data: productionData,
      metrics: [
        { field: 'cut_total_feet', aggregation: 'sum', alias: 'total_feet' },
        { field: 'cut_num_cars', aggregation: 'sum', alias: 'total_cars' },
        { field: 'down_duration', aggregation: 'sum', alias: 'total_downtime' }
      ]
    })
  });
  
  const result = await response.json();
  const kpis = result.data[0];
  
  // Update dashboard
  document.getElementById('total-feet').textContent = kpis.total_feet;
  document.getElementById('total-cars').textContent = kpis.total_cars;
  document.getElementById('total-downtime').textContent = kpis.total_downtime + ' min';
}
```

---

## Troubleshooting

### Test Failures

**Issue:** "No data returned"
- **Solution:** Check if server is running on port 3000
- **Solution:** Verify data structure matches expected format

**Issue:** "Field not found"
- **Solution:** Check field names after flattening (use Test 1 to see column names)
- **Solution:** Verify grouped properties are being detected

**Issue:** "Aggregation failed"
- **Solution:** Ensure numeric fields contain valid numbers (not empty strings)
- **Solution:** Check for null/undefined values in data

---

## Next Steps

1. **Customize Tests** - Modify test data to match your production reports
2. **Add More Tests** - Create tests for specific chart types you need
3. **Integrate with Frontend** - Use test results to build actual charts
4. **Automate** - Run tests in CI/CD pipeline

---

**Happy Testing!** 🧪📊✅

