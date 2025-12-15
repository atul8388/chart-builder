export class FormTemplateDto {
  template: any;
}

export class FilteredFlattenDto {
  data: any;
  template: any;
  filterType?: string; // e.g., 'number', 'text', 'date', etc.
}

