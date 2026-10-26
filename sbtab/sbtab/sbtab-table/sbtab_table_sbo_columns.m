function [names, columns] = sbtab_table_sbo_columns(my_sbtab_table)

% SBTAB_TABLE_SBO_COLUMNS Columns represented by !SBO:... column headers of an SBtab table
%
% [names, columns] = sbtab_table_sbo_columns(my_sbtab_table)
%
% A column with header !SBO:<quantity> [<unit>:<Scale>]:<ValueType> (see 'sbtab_parse_sbo_header')
% stands for the columns
%   QuantityType : <quantity> in every row
%   <ValueType>  : the values of the column (ValueType 'Value' if not given)
%   Unit, Scale  : <unit> and <Scale> in every row (if given)
% If a table has several such columns (e.g. for Mean and Std), QuantityType, Unit and Scale
% are only given if they are the same in all of them.
%
% names:   column names (Matlab field names, as in my_sbtab_table.column.column)
% columns: cell array of columns (cell arrays of strings)
%
% Columns that exist in the table are not included (they take precedence).

names   = {};
columns = {};

column_names = my_sbtab_table.column.column_names;
if isempty(column_names), return; end

sbo = {};
fields = {};
for it = 1:length(column_names)
  s = sbtab_parse_sbo_header(column_names{it});
  if ~isempty(s)
    sbo{end+1}    = s;
    fields{end+1} = sbtab_clean_column_headers(column_names{it});
  end
end
if isempty(sbo), return; end

values = my_sbtab_table.column.column.(fields{1});
nr = length(values);

for it = 1:length(sbo)
  names{end+1}   = sbo{it}.ValueType;
  columns{end+1} = column(my_sbtab_table.column.column.(fields{it}));
end
for property = {'QuantityType', 'Unit', 'Scale'}
  p = cellfun(@(s) s.(property{1}), sbo, 'UniformOutput', false);
  if ~isempty(p{1}) && all(strcmp(p, p{1}))
    names{end+1}   = property{1};
    columns{end+1} = repmat(p(1), nr, 1);
  end
end

% existing columns take precedence; a value type that occurs twice is ambiguous
[~, ind_unique] = unique(names, 'stable');
duplicates = names(setdiff(1:length(names), ind_unique));
keep = ~isfield(my_sbtab_table.column.column, names) & ~ismember(names, duplicates);
names   = names(keep);
columns = columns(keep);


% -----------------------------------------------------

function c = column(c)

c = c(:);
