function result = sbtab_table_diff(SBtab_table_1, SBtab_table_2, sort_by_columns1, sort_by_columns2, show_columns_list)

% result = sbtab_table_diff(SBtab_table_1, SBtab_table_2, sort_by_columns1, sort_by_columns2, show_columns_list)
%
% Compare the contents of two SBtab tables
%
% SBtab_table_1 and SBtab_table_2 can be filenames or SBtab structs
%
% The rows of the two tables are matched by their entries in the key columns
% sort_by_columns1 (in table 1) and sort_by_columns2 (in table 2)
% (default: the first column of table 1, in both tables). Only rows that
% appear in both tables are compared.
%
% show_columns_list: columns to be compared (default: all common columns except for the key columns)
%
% Output: struct with one field for each compared column, containing a cell array
% with three columns: row key, entry in table 1, entry in table 2.
% If no output is requested, the results are displayed.

eval(default('sort_by_columns1','[]','sort_by_columns2','[]','show_columns_list','[]'));

if isstr(SBtab_table_1)
  t1 = sbtab_table_load(SBtab_table_1);
else
  t1 = SBtab_table_1;
end

if isstr(SBtab_table_2)
  t2 = sbtab_table_load(SBtab_table_2);
else
  t2 = SBtab_table_2;
end

if isempty(sort_by_columns1)
  sort_by_columns1 = t1.column.column_names(1);
end
if isstr(sort_by_columns1)
  sort_by_columns1 = {sort_by_columns1};
end
if isempty(sort_by_columns2)
  sort_by_columns2 = sort_by_columns1;
end
if isstr(sort_by_columns2)
  sort_by_columns2 = {sort_by_columns2};
end

if isempty(show_columns_list)
  show_columns_list = setdiff(intersect(t1.column.column_names,t2.column.column_names),sort_by_columns1);
end

keys1 = row_keys(t1, sort_by_columns1);
keys2 = row_keys(t2, sort_by_columns2);

[keys, order1, order2] = intersect(keys1, keys2);

result = struct;

for it = 1:length(show_columns_list)
  my_column_name = sbtab_clean_column_headers(show_columns_list{it});
  column_1 = sbtab_table_get_column(t1, show_columns_list{it});
  column_2 = sbtab_table_get_column(t2, show_columns_list{it});
  result.(my_column_name) = [keys, column_1(order1), column_2(order2)];
  if nargout == 0
    display(my_column_name)
    disp(result.(my_column_name))
  end
end


% -----------------------------------------------------

function keys = row_keys(t, key_columns)

  % join the entries of the key columns into one string per row

  keys = sbtab_table_get_column(t, key_columns{1});
  for it = 2:length(key_columns)
    keys = strcat(keys, '|', sbtab_table_get_column(t, key_columns{it}));
  end
