import {
  Controller,
  Post,
  Body,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { DuckdbRowpadService } from './duckdb-rowpad.service';
import { PolarsRowpadService } from './polars-rowpad.service';
import { FlattenJsonDto } from './dto/flatten-json.dto';
import { FormTemplateDto, FilteredFlattenDto } from './dto/form-template.dto';
import { ChartQueryDto } from './dto/chart-query.dto';

@Controller('processor')
export class ProcessorController {
  constructor(
    private readonly duckdbService: DuckdbRowpadService,
    private readonly polarsService: PolarsRowpadService,
  ) {}

  @Post('flatten-json')
  async flattenJson(@Body() flattenJsonDto: FlattenJsonDto) {
    try {
      if (!flattenJsonDto.data) {
        throw new HttpException(
          'Missing "data" field in request body',
          HttpStatus.BAD_REQUEST,
        );
      }

      console.log('flattenJsonDto.data:', flattenJsonDto.data);
      const result = await this.duckdbService.flattenWithRowPadding(
        flattenJsonDto.data,
      );

      return {
        success: true,
        rowCount: result.length,
        data: result,
      };
    } catch (error) {
      throw new HttpException(
        {
          success: false,
          message: error.message || 'Failed to flatten JSON',
          error: error.toString(),
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Post('flatten-json-polars')
  async flattenJsonPolars(@Body() flattenJsonDto: FlattenJsonDto) {
    try {
      if (!flattenJsonDto.data) {
        throw new HttpException(
          'Missing "data" field in request body',
          HttpStatus.BAD_REQUEST,
        );
      }

      console.log('Polars - flattenJsonDto.data:', flattenJsonDto.data);
      const result = await this.polarsService.flattenWithRowPadding(
        flattenJsonDto.data,
      );

      return {
        success: true,
        rowCount: result.length,
        data: result,
        engine: 'polars',
      };
    } catch (error) {
      throw new HttpException(
        {
          success: false,
          message: error.message || 'Failed to flatten JSON with Polars',
          error: error.toString(),
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Post('get-fields-by-type')
  async getFieldsByType(@Body() formTemplateDto: FormTemplateDto) {
    try {
      if (!formTemplateDto.template) {
        throw new HttpException(
          'Missing "template" field in request body',
          HttpStatus.BAD_REQUEST,
        );
      }

      const filterType = (formTemplateDto as any).filterType;
      console.log('Template - Getting fields by type:', filterType);

      const fields = this.polarsService.getFieldsByType(
        formTemplateDto.template,
        filterType,
      );

      return {
        success: true,
        filterType: filterType || 'all',
        fieldCount: fields.length,
        fields: fields,
      };
    } catch (error) {
      throw new HttpException(
        {
          success: false,
          message: error.message || 'Failed to extract fields from template',
          error: error.toString(),
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  @Post('flatten-with-template')
  async flattenWithTemplate(@Body() filteredFlattenDto: FilteredFlattenDto) {
    try {
      if (!filteredFlattenDto.data) {
        throw new HttpException(
          'Missing "data" field in request body',
          HttpStatus.BAD_REQUEST,
        );
      }

      if (!filteredFlattenDto.template) {
        throw new HttpException(
          'Missing "template" field in request body',
          HttpStatus.BAD_REQUEST,
        );
      }

      console.log('Template - Flattening with template filter');
      console.log('Template - Filter type:', filteredFlattenDto.filterType);

      const result = await this.polarsService.flattenWithTemplateFilter(
        filteredFlattenDto.data,
        filteredFlattenDto.template,
        filteredFlattenDto.filterType,
      );

      return {
        success: true,
        rowCount: result.length,
        filterType: filteredFlattenDto.filterType || 'all',
        data: result,
        engine: 'polars',
      };
    } catch (error) {
      throw new HttpException(
        {
          success: false,
          message:
            error.message || 'Failed to flatten JSON with template filter',
          error: error.toString(),
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }

  /**
   * BI-style chart query endpoint with filtering, grouping, and aggregation
   * This endpoint provides full analytics capabilities for dynamic chart building
   */
  @Post('chart-query')
  async chartQuery(@Body() chartQueryDto: ChartQueryDto) {
    try {
      if (!chartQueryDto.data) {
        throw new HttpException(
          'Missing "data" field in request body',
          HttpStatus.BAD_REQUEST,
        );
      }

      console.log('Chart Query - Received request');
      console.log('Chart Query - Dimensions:', chartQueryDto.dimensions);
      console.log('Chart Query - Metrics:', chartQueryDto.metrics);
      console.log('Chart Query - Filters:', chartQueryDto.filters?.length || 0);

      const result = await this.polarsService.executeChartQuery(chartQueryDto);

      return result;
    } catch (error) {
      throw new HttpException(
        {
          success: false,
          message: error.message || 'Failed to execute chart query',
          error: error.toString(),
        },
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }
  }
}
