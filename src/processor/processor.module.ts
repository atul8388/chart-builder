import { Module } from '@nestjs/common';
import { ProcessorController } from './processor.controller';
import { DuckdbRowpadService } from './duckdb-rowpad.service';
import { PolarsRowpadService } from './polars-rowpad.service';

@Module({
  controllers: [ProcessorController],
  providers: [DuckdbRowpadService, PolarsRowpadService],
  exports: [DuckdbRowpadService, PolarsRowpadService],
})
export class ProcessorModule {}
