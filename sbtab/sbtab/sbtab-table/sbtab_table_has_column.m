function res = sbtab_table_has_column(my_sbtab_table,column_name)

% SBTAB_TABLE_HAS_COLUMN Check for existence of column in an SBtab table
%
% res = sbtab_table_has_column(my_sbtab_table,column_name)

column_name = sbtab_clean_column_headers(column_name);

res = isfield(my_sbtab_table.column.column,column_name);

% attributes like ':Unit' count as columns (see sbtab_table_get_column)
if ~res && isfield(my_sbtab_table.column,'constant_names')
  res = sum(strcmp(my_sbtab_table.column.constant_names,column_name)) > 0;
end

% columns represented by !SBO:... headers (see sbtab_table_sbo_columns)
if ~res
  res = sum(strcmp(sbtab_table_sbo_columns(my_sbtab_table),column_name)) > 0;
end
