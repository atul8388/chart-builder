import { Injectable } from '@nestjs/common';
import * as duckdb from 'duckdb';
import { promisify } from 'util';

@Injectable()
export class DuckdbRowpadService {
  private db: duckdb.Database;
  private conn: duckdb.Connection;

  constructor() {
    this.db = new duckdb.Database(':memory:');
    this.conn = this.db.connect();
  }

  async flattenWithRowPadding(jsonDoc: object) {
    const run = promisify(this.conn.run.bind(this.conn));
    const all = promisify(this.conn.all.bind(this.conn));

    const table = `t_${Date.now()}`;

    // Create table and insert JSON data
    // First, create a table from the JSON structure
    const jsonArray = Array.isArray(jsonDoc) ? jsonDoc : [jsonDoc];
    const jsonStr = JSON.stringify(jsonArray);

    // Use a temporary file approach or direct insertion
    const fs = require('fs');
    const path = require('path');
    const tmpFile = path.join(require('os').tmpdir(), `${table}.json`);

    try {
      fs.writeFileSync(tmpFile, jsonStr);

      await run(`
        CREATE TABLE ${table} AS
        SELECT * FROM read_json_auto('${tmpFile.replace(/\\/g, '/')}');
      `);

      fs.unlinkSync(tmpFile);
    } catch (error) {
      if (fs.existsSync(tmpFile)) {
        fs.unlinkSync(tmpFile);
      }
      throw error;
    }

    // Find list/array columns and struct columns
    const cols: any[] = await all(`PRAGMA table_info('${table}');`);
    console.log('Table columns:', cols);

    // Detect array columns: type contains 'LIST' or ends with '[]'
    const arrayCols = cols
      .filter((c) => c.type.includes('LIST') || c.type.endsWith('[]'))
      .map((c) => c.name);

    // Detect struct/object columns: type starts with 'STRUCT(' but doesn't end with '[]'
    const structCols = cols
      .filter((c) => c.type.startsWith('STRUCT(') && !c.type.endsWith('[]'))
      .map((c) => c.name);

    // Scalar columns are those that are neither arrays nor structs
    const scalarCols = cols
      .filter(
        (c) =>
          !c.type.includes('LIST') &&
          !c.type.endsWith('[]') &&
          !c.type.startsWith('STRUCT('),
      )
      .map((c) => c.name);

    console.log('arrayCols:', arrayCols);
    console.log('structCols:', structCols);
    console.log('scalarCols:', scalarCols);
    // UNNEST each array
    const unnestedMap: Record<string, any[]> = {};
    for (const arr of arrayCols) {
      console.log(`Unnesting array column: ${arr}`);
      try {
        // Try to unnest with element expansion
        unnestedMap[arr] = await all(`
          SELECT
             row_number() OVER () AS rn,
             unnest(${arr}) AS element
          FROM ${table};
        `);

        // If element is a struct, expand it
        if (
          unnestedMap[arr].length > 0 &&
          typeof unnestedMap[arr][0].element === 'object'
        ) {
          const expandedRows = [];
          for (let i = 0; i < unnestedMap[arr].length; i++) {
            const row: any = { rn: i + 1 };
            const element = unnestedMap[arr][i].element;
            if (element && typeof element === 'object') {
              Object.assign(row, element);
            } else {
              row.value = element;
            }
            expandedRows.push(row);
          }
          unnestedMap[arr] = expandedRows;
        }

        console.log(`Unnested ${arr}:`, unnestedMap[arr]);
      } catch (error) {
        console.error(`Error unnesting ${arr}:`, error);
        unnestedMap[arr] = [];
      }
    }

    // Determine maximum row count among arrays
    // If no arrays, we still want at least 1 row
    const maxRows = Math.max(...arrayCols.map((a) => unnestedMap[a].length), 1);

    // Build padded unified rows
    const unified = [];

    // Get scalar/root fields once
    const rootData: any[] = await all(`SELECT * FROM ${table} LIMIT 1`);
    const root = rootData[0] || {};

    // Flatten struct columns
    const flattenedStructs: Record<string, any> = {};
    for (const structCol of structCols) {
      const structValue = root[structCol];
      if (structValue && typeof structValue === 'object') {
        // Flatten the struct by prefixing keys with the struct column name
        for (const key in structValue) {
          if (structValue.hasOwnProperty(key)) {
            flattenedStructs[`${structCol}_${key}`] = structValue[key];
          }
        }
      }
    }

    for (let i = 1; i <= maxRows; i++) {
      const row: any = { rn: i };

      // Add scalar/root fields (repeat)
      for (const s of scalarCols) {
        row[s] = root[s];
      }

      // Add flattened struct fields (repeat)
      Object.assign(row, flattenedStructs);

      // Add each array's row (or null)
      for (const arr of arrayCols) {
        const arrRow = unnestedMap[arr].find((r: any) => r.rn === i);
        if (arrRow) {
          for (const k of Object.keys(arrRow)) {
            if (k === 'rn') continue;
            row[`${arr}_${k}`] = arrRow[k];
          }
        } else {
          // fill nulls for all fields of this array
          const sample = unnestedMap[arr][0];
          if (sample) {
            for (const k of Object.keys(sample)) {
              if (k === 'rn') continue;
              row[`${arr}_${k}`] = null;
            }
          }
        }
      }

      unified.push(row);
    }

    console.log('Final unified rows:', unified);

    await run(`DROP TABLE IF EXISTS ${table}`);

    // Convert BigInt values to numbers to avoid JSON serialization errors
    return this.convertBigIntToNumber(unified);
  }

  private convertBigIntToNumber(obj: any): any {
    if (obj === null || obj === undefined) {
      return obj;
    }

    if (typeof obj === 'bigint') {
      // Convert BigInt to number (or string if too large)
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
}
