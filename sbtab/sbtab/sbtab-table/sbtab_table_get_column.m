function my_column = sbtab_table_get_column(my_sbtab_table,column_name,flag_numbers,verbose)

% SBTAB_TABLE_GET_COLUMN Get column from an SBtab table
%
% my_column = sbtab_table_get_column(my_sbtab_table,column_name,flag_numbers)
%
% If the column does not exist, an empty element is returned.
% A table attribute written with ':' (e.g. ':Unit=''mM''') is treated as a column
% that contains the attribute value in every row.
% If flag_numbers is set to 1, the table entries are returned as numbers (otherwise as strings)

eval(default('flag_numbers','0','verbose','1'));

column_name = sbtab_clean_column_headers(column_name);

if isfield(my_sbtab_table.column.column,column_name)
  my_column = my_sbtab_table.column.column.(column_name);
  my_column = column(my_column);
else
  my_headers = my_sbtab_table.uncontrolled.headers;
  if isempty(my_headers)
    my_headers = {};
  end
  my_headers = sbtab_clean_column_headers(my_headers);
  ll = find(strcmp(my_headers,column_name));
  if length(ll)
    my_column = my_sbtab_table.uncontrolled.data(:,ll);
  elseif isfield(my_sbtab_table.column,'constant_names') && sum(strcmp(my_sbtab_table.column.constant_names,column_name))
    fn = fieldnames(my_sbtab_table.column.column);
    if length(fn)
      nr = length(my_sbtab_table.column.column.(fn{1}));
    else
      nr = size(my_sbtab_table.uncontrolled.data,1);
    end
    my_column = repmat({my_sbtab_table.attributes.(column_name)}, nr, 1);
  else
    if verbose
      warning(sprintf('Column %s not found in table',column_name));
    end
    my_column = [];
  end
end

if flag_numbers && iscell(my_column)
  if sum(strcmpi('true',my_column)+strcmpi('false',my_column))
    %% Convert Boolean values to numbers 0 or 1
    dum = nan*ones(size(my_column));
    dum(find(strcmpi('true',my_column))) = 1;
    dum(find(strcmpi('false',my_column))) = 0;
    my_column = dum;
  else
    my_column = sbtab_cell_to_numbers(my_column);
  end
end
