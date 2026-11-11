function n = sbtab_table_n_rows(sbtab_table)

% n = sbtab_table_n_rows(sbtab_table)
%
% Number of rows of an SBtab table object

n = 0;
fn = fieldnames(sbtab_table.column.column);
if length(fn)
  n = length(sbtab_table.column.column.(fn{1}));
elseif isfield(sbtab_table, 'uncontrolled') && ~isempty(sbtab_table.uncontrolled.data)
  n = size(sbtab_table.uncontrolled.data, 1);
end
