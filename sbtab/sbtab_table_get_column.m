function column = sbtab_table_get_column(my_sbtab_table,column_name)

% column = sbtab_table_add_column(my_sbtab_table,column_name)

column = my_sbtab_table.column.column.(column_name);