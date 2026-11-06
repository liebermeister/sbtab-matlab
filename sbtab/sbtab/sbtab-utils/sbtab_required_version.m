function v = sbtab_required_version(table_types)

% SBTAB_REQUIRED_VERSION SBtab version in which tables of given types are written by default
%
% v = sbtab_required_version(table_types)
%
% table_types: cell array of table types (or a single table type as a string),
%              e.g. the types of the tables in a document
% v:           '1.2' if one of the table types exists only in SBtab 1.2 (i.e., it is
%              in the 1.2 definitions table, but not in the 1.1 definitions table;
%              e.g. 'SBMLfbcObjective', 'SBMLlayout'); otherwise the default version
%              (see 'sbtab_version')

if ischar(table_types), table_types = {table_types}; end

persistent types_only_in_1_2
if isempty(types_only_in_1_2)
  types = struct;
  for version = {'1.1', '1.2'}
    d = sbtab_definitions(version{1});
    parent = sbtab_table_get_column(d, 'Parent');
    types.(['v' strrep(version{1}, '.', '_')]) = unique(parent(:)');
  end
  types_only_in_1_2 = setdiff(types.v1_2, types.v1_1);
end

if any(ismember(table_types, types_only_in_1_2))
  v = '1.2';
else
  v = sbtab_version;
end
