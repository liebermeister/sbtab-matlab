function my_table = sbtab_table_to_table(my_sbtab_table)

% SBTAB_TABLE_TO_TABLE Convert SBtab table to matlab table object
%
% my_table = sbtab_table_to_table(my_sbtab_table)

column_names = {};
column_names(my_sbtab_table.column.ind) = my_sbtab_table.column.column_names;
if length(my_sbtab_table.data.ind)
  column_names(my_sbtab_table.data.ind) = my_sbtab_table.data.headers;
end
if length(my_sbtab_table.uncontrolled.ind)
  column_names(my_sbtab_table.uncontrolled.ind) = my_sbtab_table.uncontrolled.headers;
end
column_names = sbtab_clean_column_headers(column_names);

% table contents without the declaration line, the header line, and the row attribute lines
my_sbtab_cell = sbtab_table_to_cell(my_sbtab_table, struct('omit_declarations',1));
ind = 1 + length(fieldnames(my_sbtab_table.rows)) + 1 : size(my_sbtab_cell,1);

if length(column_names)
  my_table = cell2table(my_sbtab_cell(ind,:),'VariableNames', column_names);
else
  my_table = {};
end
