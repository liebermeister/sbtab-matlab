function my_sbtab_table = sbtab_table_add_column(my_sbtab_table,column_name,column)

% my_sbtab_table = sbtab_table_add_column(my_sbtab_table,column_name,column)

my_sbtab_table.column.column_names = [my_sbtab_table.column.column_names; column_name];

column_name = strrep(column_name,' ','_');
column_name = strrep(column_name,'.','_');
column_name = strrep(column_name,':','_');

my_sbtab_table.column.column.(column_name) = column;

indices = [my_sbtab_table.column.ind, my_sbtab_table.uncontrolled.ind, my_sbtab_table.data.ind];
my_sbtab_table.column.ind  = [my_sbtab_table.column.ind max(indices)+1];

