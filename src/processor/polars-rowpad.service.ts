import { Injectable } from '@nestjs/common';
import * as pl from 'nodejs-polars';
import {
  ChartQueryDto,
  ChartQueryResponseDto,
  FilterDefinition,
  MetricDefinition,
  SortDefinition,
} from './dto/chart-query.dto';

@Injectable()
export class PolarsRowpadService {
  async flattenWithRowPadding(jsonDoc: object): Promise<any[]> {
    try {
      // Ensure we have an object to work with
      const data = jsonDoc || {};

      // Separate fields into scalars, objects, and arrays
      const scalarFields: Record<string, any> = {};
      const objectFields: Record<string, any> = {};
      const arrayFields: Record<string, any[]> = {};

      for (const [key, value] of Object.entries(data)) {
        if (value === null || value === undefined) {
          scalarFields[key] = value;
        } else if (Array.isArray(value)) {
          arrayFields[key] = value;
        } else if (typeof value === 'object') {
          objectFields[key] = value;
        } else {
          scalarFields[key] = value;
        }
      }

      // Flatten nested objects
      const flattenedObjects: Record<string, any> = {};
      for (const [objKey, objValue] of Object.entries(objectFields)) {
        if (objValue && typeof objValue === 'object') {
          for (const [nestedKey, nestedValue] of Object.entries(objValue)) {
            flattenedObjects[`${objKey}_${nestedKey}`] = nestedValue;
          }
        }
      }

      // Detect and group properties with numeric suffixes (e.g., down_type-1, down_type-2)
      const { groupedArrays, remainingFields } =
        this.detectAndGroupNumericSuffixes({
          ...scalarFields,
          ...flattenedObjects,
        });

      // Merge grouped arrays with existing array fields
      const allArrayFields = { ...arrayFields, ...groupedArrays };

      // Determine the maximum array length
      const arrayLengths = Object.values(allArrayFields).map(
        (arr) => arr.length,
      );
      const maxRows = Math.max(...arrayLengths, 1);

      // console.log('Polars - maxRows:', maxRows);

      // Build data structure for Polars DataFrame
      const dfData: Record<string, any[]> = {};

      // Add row number column
      dfData['rn'] = Array.from({ length: maxRows }, (_, i) => i + 1);

      // Add remaining fields (scalars and flattened objects) - repeated for each row
      for (const [key, value] of Object.entries(remainingFields)) {
        dfData[key] = Array(maxRows).fill(value == null ? 0 : value);
      }

      // Process array fields
      for (const [arrayKey, arrayValue] of Object.entries(allArrayFields)) {
        const isGroupedArray = arrayKey in groupedArrays;

        // Check if array contains objects
        const hasObjects =
          arrayValue.length > 0 &&
          arrayValue[0] !== null &&
          typeof arrayValue[0] === 'object' &&
          !Array.isArray(arrayValue[0]);

        if (hasObjects) {
          // Array of objects - flatten each object's properties
          const firstElement = arrayValue[0];
          const objectKeys = Object.keys(firstElement);

          for (const elemKey of objectKeys) {
            const columnName = `${arrayKey}_${elemKey}`;
            dfData[columnName] = Array.from({ length: maxRows }, (_, i) => {
              if (i < arrayValue.length && arrayValue[i] !== null) {
                return arrayValue[i][elemKey];
              }
              return 0;
            });
          }
        } else {
          // Array of scalars
          const columnName = isGroupedArray ? arrayKey : `${arrayKey}_value`;
          dfData[columnName] = Array.from({ length: maxRows }, (_, i) => {
            return i < arrayValue.length ? arrayValue[i] : 0;
          });
        }
      }

      // console.log(
      //   `Polars - Creating DataFrame with ${maxRows} rows and ${Object.keys(dfData).length} columns`,
      // );

      // Create Polars DataFrame
      const df = pl.DataFrame(dfData);

      // console.log(
      //   `Polars - DataFrame shape: ${df.height} rows x ${df.width} columns`,
      // );
      // console.log(`Polars - DataFrame columns: ${df.columns.join(', ')}`);

      // Convert DataFrame to array of records
      const result = df.toRecords();

      // console.log('Polars - Final result:', result);

      // Convert any BigInt values to numbers
      return this.convertBigIntToNumber(result);
    } catch (error) {
      console.error('Polars service error:', error);
      throw error;
    }
  }

  /**
   * Extracts field types from a form template JSON.
   * Supports two template structures:
   * 1. Legacy: properties with "inputoptiontype" (e.g., { fields: { fieldName: { inputoptiontype: "number" } } })
   * 2. New: groups[].items[] with properties.key and properties.type
   *
   * @param template - Form template JSON object
   * @returns Map of field names to their types
   */
  extractFieldTypes(template: any): Map<string, string> {
    const fieldTypes = new Map<string, string>();

    // Check if template has groups structure (new format)
    if (template && Array.isArray(template.groups)) {
      // console.log('Template - Using groups structure');

      template.groups.forEach((group: any, groupIndex: number) => {
        if (Array.isArray(group.items)) {
          group.items.forEach((item: any, itemIndex: number) => {
            if (item.properties) {
              let fieldType: string;
              const fieldKey = item.properties.key;
              if (item.properties.dateoptiontype) {
                fieldType = item.properties.dateoptiontype;
              } else {
                fieldType = item.properties.inputoptiontype;
              }
              if (fieldKey && fieldType) {
                fieldTypes.set(fieldKey, fieldType);
                // console.log(
                //   `Template - Found field: ${fieldKey} with type: ${fieldType} (group ${groupIndex}, item ${itemIndex})`,
                // );
              }
            }
          });
        }
      });

      return fieldTypes;
    }

    // Legacy format: recursively search for inputoptiontype
    // console.log('Template - Using legacy structure');

    const extractFromObject = (obj: any, prefix: string = '') => {
      if (!obj || typeof obj !== 'object') {
        return;
      }

      for (const [key, value] of Object.entries(obj)) {
        const fullKey = prefix ? `${prefix}_${key}` : key;

        // Check if this object has inputoptiontype
        if (value && typeof value === 'object' && 'inputoptiontype' in value) {
          const fieldType = (value as any).inputoptiontype;
          fieldTypes.set(key, fieldType);
          // console.log(`Template - Found field: ${key} with type: ${fieldType}`);
        }

        // Recursively process nested objects
        if (value && typeof value === 'object' && !Array.isArray(value)) {
          extractFromObject(value, fullKey);
        }

        // Process arrays
        if (Array.isArray(value)) {
          value.forEach((item, index) => {
            if (item && typeof item === 'object') {
              extractFromObject(item, `${fullKey}_${index}`);
            }
          });
        }
      }
    };

    extractFromObject(template);
    return fieldTypes;
  }

  /**
   * Filters fields from a flattened object based on field types from template.
   *
   * @param flattenedData - Flattened data object
   * @param fieldTypes - Map of field names to their types
   * @param filterType - Type to filter by (e.g., 'number', 'text', 'date'). If not specified, includes all fields from template.
   * @returns Filtered object containing only fields matching the filter type or all template fields
   */
  filterFieldsByType(
    flattenedData: Record<string, any>,
    fieldTypes: Map<string, string>,
    filterType?: string,
  ): Record<string, any> {
    const filtered: Record<string, any> = {};

    for (const [key, value] of Object.entries(flattenedData)) {
      // Always include the row number
      if (key === 'rn') {
        filtered[key] = value;
        continue;
      }

      // Check if this field matches the filter type
      // Handle both direct field names and flattened names (e.g., items_price)
      let fieldType = fieldTypes.get(key);

      // If not found, try to extract the base field name from flattened names
      if (!fieldType && key.includes('_')) {
        const parts = key.split('_');
        // Try the last part (e.g., 'price' from 'items_price')
        const baseName = parts[parts.length - 1];
        fieldType = fieldTypes.get(baseName);
      }

      // If field is not in template, skip it
      if (!fieldType) {
        continue;
      }

      // If no filter type specified, include all fields from template
      if (!filterType) {
        filtered[key] = value;
        continue;
      }

      // Include only if field type matches the filter
      if (fieldType === filterType) {
        filtered[key] = value;
      }
    }

    return filtered;
  }

  /**
   * Gets list of fields matching a specific type from template.
   *
   * @param template - Form template JSON object
   * @param filterType - Type to filter by (optional)
   * @returns Array of field names matching the filter type
   */
  getFieldsByType(template: any, filterType?: string): string[] {
    const fieldTypes = this.extractFieldTypes(template);
    const fields: string[] = [];

    for (const [fieldName, fieldType] of fieldTypes.entries()) {
      if (!filterType || fieldType === filterType) {
        fields.push(fieldName);
      }
    }

    return fields;
  }

  /**
   * Flattens JSON with row padding and filters fields based on template.
   * Uses Polars DataFrame select operation for efficient column filtering.
   *
   * @param jsonDoc - JSON document to flatten
   * @param template - Form template JSON object
   * @param filterType - Type to filter by (e.g., 'number')
   * @returns Array of flattened and filtered rows
   */
  async flattenWithTemplateFilter(
    jsonDoc: object,
    template: any,
    filterType?: string,
  ): Promise<any[]> {
    try {
      // First, flatten the data normally
      const flattenedRows = await this.flattenWithRowPadding(jsonDoc);
      // console.log('Template - Flattened rows:', flattenedRows);
      if (flattenedRows.length === 0) {
        return [];
      }

      // Extract field types from template
      const fieldTypes = this.extractFieldTypes(template);
      // console.log('Template - Field types extracted:', fieldTypes);
      // console.log(
      //   'Template - Field types extracted:',
      //   Array.from(fieldTypes.entries()),
      // );
      // console.log('Template - Filter type:', filterType);

      // Create DataFrame from flattened rows
      const df = pl.DataFrame(flattenedRows);

      // console.log(
      //   `Template - DataFrame created with ${df.height} rows x ${df.width} columns`,
      // );

      // Determine which columns to select
      const columnsToSelect: string[] = ['rn']; // Always include row number

      for (const column of df.columns) {
        if (column === 'rn') continue;

        // Check if this column matches the filter criteria
        let fieldType = fieldTypes.get(column);

        // If not found, try to extract the base field name from flattened names
        if (!fieldType && column.includes('_')) {
          const parts = column.split('_');
          // Try the last part (e.g., 'price' from 'items_price')
          const baseName = parts[parts.length - 1];
          fieldType = fieldTypes.get(baseName);
        }

        // If field is not in template, skip it
        if (!fieldType) {
          continue;
        }

        // If no filter type specified, include all fields from template
        if (!filterType) {
          columnsToSelect.push(column);
          continue;
        }

        // Include only if field type matches the filter
        if (fieldType === filterType) {
          columnsToSelect.push(column);
        }
      }

      // console.log(
      //   `Template - Selecting ${columnsToSelect.length} columns:`,
      //   columnsToSelect.join(', '),
      // );

      // Select only the desired columns using Polars
      const filteredDf = df.select(columnsToSelect);

      // ----------- NUMERIC TYPE FIX START -----------

      // Cast numeric fields (from template) to numbers with null → 0
      let castDf = filteredDf;

      for (const col of filteredDf.columns) {
        const fieldType = fieldTypes.get(col);

        if (fieldType === 'number') {
          castDf = castDf.withColumn(
            pl
              .col(col)
              .replace('', null) // empty string → null
              .cast(pl.Float64) // convert to number
              .fillNull(0) // null → 0
              .alias(col),
          );
        }
      }

      // console.log(
      //   `Template - Filtered DataFrame: ${filteredDf.height} rows x ${filteredDf.width} columns`,
      // );

      // Convert back to records
      const filteredRows = castDf.toRecords();

      return filteredRows;
    } catch (error) {
      console.error('Error in flattenWithTemplateFilter:', error);
      throw error;
    }
  }

  /**
   * Detects properties with numeric suffixes (e.g., down_type-1, down_type-2, down_type-3)
   * and groups them into arrays for row expansion.
   *
   * Pattern: propertyName-1, propertyName-2, propertyName-3, etc.
   *
   * @param fields - Object containing all flattened fields
   * @returns Object with groupedArrays and remainingFields
   */
  private detectAndGroupNumericSuffixes(fields: Record<string, any>): {
    groupedArrays: Record<string, any[]>;
    remainingFields: Record<string, any>;
  } {
    const groupedArrays: Record<string, any[]> = {};
    const remainingFields: Record<string, any> = {};
    const processedKeys = new Set<string>();

    // Pattern to match: propertyName-1, propertyName-2, etc.
    // Supports both dash (-) and underscore (_) as separators before the number
    const numericSuffixPattern = /^(.+?)[-_](\d+)$/;

    // First pass: identify all properties with numeric suffixes
    const groupMap: Record<
      string,
      Array<{ index: number; key: string; value: any }>
    > = {};

    for (const [key, value] of Object.entries(fields)) {
      const match = key.match(numericSuffixPattern);

      if (match) {
        const baseName = match[1]; // e.g., "down_type" from "down_type-1"
        const index = parseInt(match[2], 10); // e.g., 1 from "down_type-1"

        if (!groupMap[baseName]) {
          groupMap[baseName] = [];
        }

        groupMap[baseName].push({ index, key, value });
        processedKeys.add(key);
      }
    }

    // Second pass: convert groups to arrays (only if there are multiple items)
    for (const [baseName, items] of Object.entries(groupMap)) {
      if (items.length > 1) {
        // Sort by index to ensure correct order
        items.sort((a, b) => a.index - b.index);

        // Create array from grouped items
        groupedArrays[baseName] = items.map((item) => item.value);

        // console.log(
        //   `Polars - Grouped ${items.length} properties into array: ${baseName}`,
        // );
      } else {
        // If only one item, treat it as a regular field
        const item = items[0];
        remainingFields[item.key] = item.value;
        processedKeys.delete(item.key);
      }
    }

    // Third pass: add all non-grouped fields to remainingFields
    for (const [key, value] of Object.entries(fields)) {
      if (!processedKeys.has(key)) {
        remainingFields[key] = value;
      }
    }

    return { groupedArrays, remainingFields };
  }

  private convertBigIntToNumber(obj: any): any {
    if (obj === null || obj === undefined) {
      return obj;
    }

    if (typeof obj === 'bigint') {
      return Number(obj);
    }

    if (Array.isArray(obj)) {
      return obj.map((item) => this.convertBigIntToNumber(item));
    }

    if (typeof obj === 'object') {
      const converted: any = {};
      for (const key in obj) {
        if (obj.hasOwnProperty(key)) {
          converted[key] = this.convertBigIntToNumber(obj[key]);
        }
      }
      return converted;
    }

    return obj;
  }

  /**
   * BI-style chart query with filtering, grouping, and aggregation
   * This is the main method for dynamic chart building
   *
   * @param query - Chart query configuration
   * @returns Aggregated data ready for charting
   */
  async executeChartQuery(
    query: ChartQueryDto,
  ): Promise<ChartQueryResponseDto> {
    const startTime = Date.now();

    try {
      console.log('Chart Query - Starting execution');
      console.log('Chart Query - Dimensions:', query.dimensions);
      console.log('Chart Query - Metrics:', query.metrics);
      console.log('Chart Query - Filters:', query.filters?.length || 0);

      // Step 1: Flatten the data
      const flattenedRows = await this.flattenWithTemplateFilter(
        query.data,
        query.template,
      );

      // console.log('Chart Query - Flattened rows:', flattenedRows);

      if (flattenedRows.length === 0) {
        return {
          success: true,
          data: [],
          metadata: {
            rowCount: 0,
            dimensions: query.dimensions || [],
            metrics: query.metrics?.map((m) => m.alias || m.field) || [],
            filtersApplied: 0,
            engine: 'polars',
            executionTime: Date.now() - startTime,
          },
        };
      }

      // Step 2: Create DataFrame
      let df = pl.DataFrame(flattenedRows);

      console.log(
        `Chart Query - Initial DataFrame: ${df.height} rows x ${df.width} columns`,
      );

      // Step 3: Apply filters
      if (query.filters && query.filters.length > 0) {
        df = this.applyFilters(df, query.filters);
        // console.log(`Chart Query - After filters: ${df.height} rows`);
      }

      // Step 4: Apply date range filter
      if (query.dateRange) {
        df = this.applyDateRangeFilter(df, query.dateRange);
        // console.log(`Chart Query - After date range: ${df.height} rows`);
      }

      // Step 5: Group and aggregate
      let result: any[];
      if (
        query.dimensions &&
        query.dimensions.length > 0 &&
        query.metrics &&
        query.metrics.length > 0
      ) {
        result = this.groupAndAggregate(df, query.dimensions, query.metrics);
        console.log(`Chart Query - After aggregation: ${result.length} groups`);
      } else if (query.metrics && query.metrics.length > 0) {
        // Aggregate without grouping (single row result)
        result = this.aggregateAll(df, query.metrics);
        console.log(`Chart Query - Aggregated to single row`, result);
      } else {
        // No aggregation, just return filtered data
        result = df.toRecords();
      }

      // Step 6: Sort results
      if (query.sort && query.sort.length > 0 && result.length > 0) {
        result = this.sortResults(result, query.sort);
      }

      // Step 7: Apply limit
      if (query.limit && query.limit > 0) {
        result = result.slice(0, query.limit);
      }

      const executionTime = Date.now() - startTime;

      console.log(`Chart Query - Completed in ${executionTime}ms`);

      return {
        success: true,
        data: result,
        metadata: {
          rowCount: result.length,
          dimensions: query.dimensions || [],
          metrics: query.metrics?.map((m) => m.alias || m.field) || [],
          filtersApplied:
            (query.filters?.length || 0) + (query.dateRange ? 1 : 0),
          engine: 'polars',
          executionTime,
        },
      };
    } catch (error) {
      console.error('Chart Query - Error:', error);
      return {
        success: false,
        data: [],
        metadata: {
          rowCount: 0,
          dimensions: query.dimensions || [],
          metrics: query.metrics?.map((m) => m.alias || m.field) || [],
          filtersApplied: 0,
          engine: 'polars',
          executionTime: Date.now() - startTime,
        },
        error: error.message,
      };
    }
  }

  /**
   * Apply filters to DataFrame
   * Note: Treats null values as 0 for numeric comparisons
   */
  private applyFilters(
    df: pl.DataFrame,
    filters: FilterDefinition[],
  ): pl.DataFrame {
    let filteredDf = df;

    for (const filter of filters) {
      const column = filter.field;

      // Check if column exists
      if (!df.columns.includes(column)) {
        console.warn(`Filter - Column '${column}' not found, skipping filter`);
        continue;
      }

      try {
        switch (filter.operator) {
          case 'equals':
            filteredDf = filteredDf.filter(
              pl.col(column).fillNull(0).eq(filter.value),
            );
            break;
          case 'notEquals':
            filteredDf = filteredDf.filter(
              pl.col(column).fillNull(0).neq(filter.value),
            );
            break;
          case 'greaterThan':
            filteredDf = filteredDf.filter(
              pl.col(column).fillNull(0).gt(filter.value),
            );
            break;
          case 'lessThan':
            filteredDf = filteredDf.filter(
              pl.col(column).fillNull(0).lt(filter.value),
            );
            break;
          case 'greaterThanOrEqual':
            filteredDf = filteredDf.filter(
              pl.col(column).fillNull(0).gtEq(filter.value),
            );
            break;
          case 'lessThanOrEqual':
            filteredDf = filteredDf.filter(
              pl.col(column).fillNull(0).ltEq(filter.value),
            );
            break;
        }
      } catch (error) {
        console.error(
          `Filter - Error applying filter on '${column}':`,
          error.message,
        );
      }
    }

    return filteredDf;
  }

  /**
   * Apply date range filter to DataFrame
   */
  private applyDateRangeFilter(df: pl.DataFrame, dateRange: any): pl.DataFrame {
    const { field, startDate, endDate } = dateRange;

    if (!df.columns.includes(field)) {
      console.warn(`Date Range - Column '${field}' not found, skipping filter`);
      return df;
    }

    try {
      // Filter by date range
      let filteredDf = df;
      if (startDate) {
        filteredDf = filteredDf.filter(pl.col(field).gtEq(startDate));
      }
      if (endDate) {
        filteredDf = filteredDf.filter(pl.col(field).ltEq(endDate));
      }
      return filteredDf;
    } catch (error) {
      console.error(`Date Range - Error applying filter:`, error.message);
      return df;
    }
  }

  /**
   * Group by dimensions and aggregate metrics
   * Note: Treats null values as 0 for numeric aggregations
   */
  private groupAndAggregate(
    df: pl.DataFrame,
    dimensions: string[],
    metrics: MetricDefinition[],
  ): any[] {
    try {
      // Validate dimensions exist
      const validDimensions = dimensions.filter((dim) => {
        if (!df.columns.includes(dim)) {
          console.warn(`GroupBy - Dimension '${dim}' not found, skipping`);
          return false;
        }
        return true;
      });

      if (validDimensions.length === 0) {
        console.warn('GroupBy - No valid dimensions found');
        return df.toRecords();
      }

      // Build aggregation expressions
      const aggExprs: any[] = [];

      for (const metric of metrics) {
        if (!df.columns.includes(metric.field)) {
          console.warn(
            `Aggregate - Field '${metric.field}' not found, skipping`,
          );
          continue;
        }

        const alias = metric.alias || `${metric.field}_${metric.aggregation}`;

        // Treat null as 0 for numeric aggregations
        switch (metric.aggregation) {
          case 'sum':
            aggExprs.push(pl.col(metric.field).fillNull(0).sum().alias(alias));
            break;
          case 'avg':
            aggExprs.push(pl.col(metric.field).fillNull(0).mean().alias(alias));
            break;
          case 'count':
            aggExprs.push(pl.col(metric.field).count().alias(alias));
            break;
          case 'min':
            aggExprs.push(pl.col(metric.field).fillNull(0).min().alias(alias));
            break;
          case 'max':
            aggExprs.push(pl.col(metric.field).fillNull(0).max().alias(alias));
            break;
          case 'median':
            aggExprs.push(
              pl.col(metric.field).fillNull(0).median().alias(alias),
            );
            break;
          case 'std':
            aggExprs.push(pl.col(metric.field).fillNull(0).std().alias(alias));
            break;
          case 'countDistinct':
            aggExprs.push(pl.col(metric.field).nUnique().alias(alias));
            break;
        }
      }

      if (aggExprs.length === 0) {
        console.warn('Aggregate - No valid metrics found');
        return df.toRecords();
      }

      console.log(`GroupBy - Grouping by: ${validDimensions.join(', ')}`);
      console.log(`Aggregate - Applying ${aggExprs.length} aggregations`);

      // Perform groupBy and aggregation
      const aggregatedDf = df.groupBy(validDimensions).agg(...aggExprs);

      return aggregatedDf.toRecords();
    } catch (error) {
      console.error('GroupBy/Aggregate - Error:', error);
      return df.toRecords();
    }
  }

  /**
   * Aggregate all rows without grouping (returns single row)
   * Note: Treats null values as 0 for numeric aggregations
   */
  private aggregateAll(df: pl.DataFrame, metrics: MetricDefinition[]): any[] {
    try {
      const aggExprs: any[] = [];

      for (const metric of metrics) {
        if (!df.columns.includes(metric.field)) {
          console.warn(
            `Aggregate - Field '${metric.field}' not found, skipping`,
          );
          continue;
        }

        const alias = metric.alias || `${metric.field}_${metric.aggregation}`;

        // Treat null as 0 for numeric aggregations
        switch (metric.aggregation) {
          case 'sum':
            aggExprs.push(pl.col(metric.field).fillNull(0).sum().alias(alias));
            break;
          case 'avg':
            aggExprs.push(pl.col(metric.field).fillNull(0).mean().alias(alias));
            break;
          case 'count':
            aggExprs.push(pl.col(metric.field).count().alias(alias));
            break;
          case 'min':
            aggExprs.push(pl.col(metric.field).fillNull(0).min().alias(alias));
            break;
          case 'max':
            aggExprs.push(pl.col(metric.field).fillNull(0).max().alias(alias));
            break;
          case 'median':
            aggExprs.push(
              pl.col(metric.field).fillNull(0).median().alias(alias),
            );
            break;
          case 'std':
            aggExprs.push(pl.col(metric.field).fillNull(0).std().alias(alias));
            break;
          case 'countDistinct':
            aggExprs.push(pl.col(metric.field).nUnique().alias(alias));
            break;
        }
      }

      if (aggExprs.length === 0) {
        return [];
      }

      console.log(
        `Aggregate - Applying ${aggExprs.length} aggregations (no grouping)`,
      );

      // Perform aggregation on entire DataFrame
      const aggregatedDf = df.select(...aggExprs);

      return aggregatedDf.toRecords();
    } catch (error) {
      console.error('Aggregate - Error:', error);
      return [];
    }
  }

  /**
   * Sort results by specified fields
   * Note: Treats null values as 0 for numeric comparisons
   */
  private sortResults(data: any[], sortDefs: SortDefinition[]): any[] {
    try {
      return data.sort((a, b) => {
        for (const sortDef of sortDefs) {
          let aVal = a[sortDef.field];
          let bVal = b[sortDef.field];

          // Treat null/undefined as 0 for numeric comparisons
          if (aVal === null || aVal === undefined) aVal = 0;
          if (bVal === null || bVal === undefined) bVal = 0;

          if (aVal === bVal) continue;

          const comparison = aVal < bVal ? -1 : 1;
          return sortDef.direction === 'asc' ? comparison : -comparison;
        }
        return 0;
      });
    } catch (error) {
      console.error('Sort - Error:', error);
      return data;
    }
  }
}
