function column = sbtab_table_get_column(my_sbtab_table,column_name,flag_numbers)

% column = sbtab_table_add_column(my_sbtab_table,column_name)

eval(default('flag_numbers','0'));

if find(strfind(column_name,'!')==1),
  column_name = column_name(2:end);
end

column_name = strrep(column_name,' ','_');
column_name = strrep(column_name,'.','_');
column_name = strrep(column_name,':','_');
column = my_sbtab_table.column.column.(column_name);

if flag_numbers,
  column = cell_string2num(column);
end