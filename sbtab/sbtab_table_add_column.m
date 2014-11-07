function my_sbtab_table = sbtab_table_add_column(my_sbtab_table,column_name,column,is_sbtab_column)

% my_sbtab_table = sbtab_table_add_column(my_sbtab_table,column_name,column,is_sbtab_column)

eval(default('is_sbtab_column','1'));

my_sbtab_table.column.column_names = [my_sbtab_table.column.column_names, column_name];

if length(unique(my_sbtab_table.column.column_names)) < length(my_sbtab_table.column.column_names),
  error('The column name exists already');
end

column_name = strrep(column_name,' ','_');
column_name = strrep(column_name,'.','_');
column_name = strrep(column_name,':','_');

indices = [my_sbtab_table.column.ind, my_sbtab_table.uncontrolled.ind, my_sbtab_table.data.ind];

if is_sbtab_column,
  my_sbtab_table.column.column.(column_name) = column;
  my_sbtab_table.column.ind  = [my_sbtab_table.column.ind max(indices)+1];
else
  my_sbtab_table.uncontrolled.headers = [my_sbtab_table.uncontrolled.headers, column_name];
  my_sbtab_table.uncontrolled.data    = [my_sbtab_table.uncontrolled.data, column];
  my_sbtab_table.uncontrolled.ind     = [my_sbtab_table.uncontrolled.ind max(indices)+1];
end