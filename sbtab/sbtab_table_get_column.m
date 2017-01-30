function my_column = sbtab_table_get_column(my_sbtab_table,column_name,flag_numbers,verbose)

% SBTAB_TABLE_GET_COLUMN Get column from an SBtab table
%
% my_column = sbtab_table_get_column(my_sbtab_table,column_name,flag_numbers)
% 
% If the column does not exist, an empty element is returned
% If flag_numbers is set to 1, the table entries are returned as numbers (otherwise as strings)

eval(default('flag_numbers','0','verbose','1'));

if find(strfind(column_name,'!')==1),
  column_name = column_name(2:end);
end

column_name = strrep(column_name,' ','_');
column_name = strrep(column_name,'.','_');
column_name = strrep(column_name,':','_');
column_name = strrep(column_name,'[','_');
column_name = strrep(column_name,']','_');

if isfield(my_sbtab_table.column.column,column_name),
  my_column = my_sbtab_table.column.column.(column_name);
  my_column = column(my_column);
else
  if verbose,
    warning(sprintf('Column %s not found in table',column_name));
  end
  my_column = [];
end

if flag_numbers,
  my_column = cell_string2num(my_column);
end
