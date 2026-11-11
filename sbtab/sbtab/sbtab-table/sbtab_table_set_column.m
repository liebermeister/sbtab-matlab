function sbtab_table = sbtab_table_set_column(sbtab_table, column_name, values)

% sbtab_table = sbtab_table_set_column(sbtab_table, column_name, values)
%
% Replace the entries of an existing column of an SBtab table object (SBtab column with '!',
% or column without '!'), or add the column if it does not exist yet.
% values: cell array of strings (one entry per row)

column_name = regexprep(column_name, '^!', '');
field_name  = sbtab_clean_column_headers(column_name);

if isfield(sbtab_table.column.column, field_name)
  sbtab_table.column.column.(field_name) = column(values);
  return
end

headers = sbtab_table.uncontrolled.headers;
if isempty(headers), headers = {}; end
ll = find(strcmp(sbtab_clean_column_headers(headers), field_name));
if length(ll)
  sbtab_table.uncontrolled.data(:, ll(1)) = column(values);
else
  sbtab_table = sbtab_table_add_column(sbtab_table, column_name, column(values));
end
