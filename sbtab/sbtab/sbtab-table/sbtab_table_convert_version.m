function my_sbtab_table = sbtab_table_convert_version(my_sbtab_table, v)

% SBTAB_TABLE_CONVERT_VERSION Adapt an SBtab table to an SBtab version (used when writing tables)
%
% my_sbtab_table = sbtab_table_convert_version(my_sbtab_table, v)
%
% v: SBtab version ('1.0' or '1.1'; default: see 'sbtab_version')
%
% The attribute SBtabVersion is set to v. In addition, the following changes are made:
%  - in tables of type 'Definition' whose SBtabVersion attribute is missing or differs
%    from v, the columns are renamed
%      1.0: !ComponentName !ComponentType !IsPartOf
%      1.1: !Name          !Type          !Parent
%  - for version 1.1, a warning is issued if the TableName is not a shortname
%    (letters, digits and '_', not starting with a digit); a longer name belongs in TableTitle
% Other differences between the versions (e.g. pointers '>Table:Column' in 1.0 and
% '!>Table:Row' in 1.1) are not converted.

eval(default('v','[]'));
v = sbtab_check_version(v);

version_unchanged = isfield(my_sbtab_table.attributes, 'SBtabVersion') && strcmp(num2str(my_sbtab_table.attributes.SBtabVersion), v);
my_sbtab_table.attributes.SBtabVersion = v;

if ~version_unchanged && isfield(my_sbtab_table.attributes, 'TableType') && strcmp(my_sbtab_table.attributes.TableType, 'Definition')
  names_10 = {'ComponentName', 'ComponentType', 'IsPartOf'};
  names_11 = {'Name', 'Type', 'Parent'};
  switch v
    case '1.0', [names_old, names_new] = deal(names_11, names_10);
    case '1.1', [names_old, names_new] = deal(names_10, names_11);
  end
  for it = 1:length(names_old)
    if sbtab_table_has_column(my_sbtab_table, names_old{it}) && ~sbtab_table_has_column(my_sbtab_table, names_new{it})
      my_sbtab_table = rename_column(my_sbtab_table, names_old{it}, names_new{it});
    end
  end
end

if strcmp(v, '1.1') && isfield(my_sbtab_table.attributes, 'TableName')
  table_name = my_sbtab_table.attributes.TableName;
  if ischar(table_name) && isempty(regexp(table_name, '^[A-Za-z_][A-Za-z0-9_]*$', 'once'))
    warning('SBtab 1.1: TableName ''%s'' is not a shortname (a longer name can be given in TableTitle)', table_name);
  end
end


% -----------------------------------------------------

function my_sbtab_table = rename_column(my_sbtab_table, name_old, name_new)

field_old = sbtab_clean_column_headers(name_old);
field_new = sbtab_clean_column_headers(name_new);
ind = find(strcmp(fieldnames(my_sbtab_table.column.column), field_old));
my_sbtab_table.column.column.(field_new) = my_sbtab_table.column.column.(field_old);
my_sbtab_table.column.column = rmfield(my_sbtab_table.column.column, field_old);
% restore the column order
fn = fieldnames(my_sbtab_table.column.column);
fn = [fn(1:ind-1); {field_new}; fn(ind:end-1)];
my_sbtab_table.column.column = orderfields(my_sbtab_table.column.column, fn);
my_sbtab_table.column.column_names{ind} = name_new;
