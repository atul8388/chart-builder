/**
 * DTO for Chart Query - BI-style data aggregation and filtering
 */

export class ChartQueryDto {
  /**
   * Raw JSON data to process
   */
  data: any;

  /**
   * Optional template for field type definitions
   */
  template?: any;

  /**
   * Dimensions - fields to group by (e.g., ['category', 'region'])
   */
  dimensions?: string[];

  /**
   * Metrics - fields to aggregate with their aggregation functions
   * Example: [{ field: 'amount', aggregation: 'sum' }, { field: 'quantity', aggregation: 'avg' }]
   */
  metrics?: MetricDefinition[];

  /**
   * Filters to apply before aggregation
   * Example: [{ field: 'status', operator: 'equals', value: 'active' }]
   */
  filters?: FilterDefinition[];

  /**
   * Sort configuration
   * Example: [{ field: 'total_amount', direction: 'desc' }]
   */
  sort?: SortDefinition[];

  /**
   * Limit number of results
   */
  limit?: number;

  /**
   * Date range filter (if applicable)
   */
  dateRange?: DateRangeDefinition;
}

export class MetricDefinition {
  /**
   * Field name to aggregate
   */
  field: string;

  /**
   * Aggregation function: sum, avg, count, min, max, median, std
   */
  aggregation: 'sum' | 'avg' | 'count' | 'min' | 'max' | 'median' | 'std' | 'countDistinct';

  /**
   * Optional alias for the result column
   */
  alias?: string;
}

export class FilterDefinition {
  /**
   * Field name to filter on
   */
  field: string;

  /**
   * Filter operator
   */
  operator: 'equals' | 'notEquals' | 'greaterThan' | 'lessThan' | 'greaterThanOrEqual' | 'lessThanOrEqual' | 'contains' | 'notContains' | 'in' | 'notIn' | 'isNull' | 'isNotNull' | 'between';

  /**
   * Value to compare against (can be single value or array for 'in', 'notIn', 'between')
   */
  value?: any;
}

export class SortDefinition {
  /**
   * Field name to sort by
   */
  field: string;

  /**
   * Sort direction
   */
  direction: 'asc' | 'desc';
}

export class DateRangeDefinition {
  /**
   * Date field name
   */
  field: string;

  /**
   * Start date (ISO string or Date)
   */
  startDate: string | Date;

  /**
   * End date (ISO string or Date)
   */
  endDate: string | Date;
}

/**
 * Response DTO for Chart Query
 */
export class ChartQueryResponseDto {
  /**
   * Success status
   */
  success: boolean;

  /**
   * Processed data ready for charting
   */
  data: any[];

  /**
   * Metadata about the query
   */
  metadata: {
    /**
     * Number of rows returned
     */
    rowCount: number;

    /**
     * Dimensions used
     */
    dimensions: string[];

    /**
     * Metrics calculated
     */
    metrics: string[];

    /**
     * Filters applied
     */
    filtersApplied: number;

    /**
     * Processing engine
     */
    engine: string;

    /**
     * Execution time in milliseconds
     */
    executionTime?: number;
  };

  /**
   * Optional error message
   */
  error?: string;
}

