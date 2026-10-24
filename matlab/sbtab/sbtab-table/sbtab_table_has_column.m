function res = sbtab_table_has_column(my_sbtab_table,column_name)

% SBTAB_TABLE_HAS_COLUMN Check for existence of column in an SBtab table
%
% res = sbtab_table_has_column(my_sbtab_table,column_name)

column_name = sbtab_clean_column_headers(column_name);

res = isfield(my_sbtab_table.column.column,column_name);
