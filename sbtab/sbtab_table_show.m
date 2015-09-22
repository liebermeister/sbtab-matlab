function sbtab_table_show(sbtab_table)

% sbtab_table_show(sbtab_table)
%
% display contents of an SBtab table

if isempty(fieldnames(sbtab_table.attributes)),
  display(['The table has no attributes']);
else,
  display(['- Attributes:']);
  attr = fieldnames(sbtab_table.attributes);
  for it = 1:length(attr)
    display(sprintf('    %s="%s"',attr{it}, sbtab_table.attributes.(attr{it})))
  end
end

column_names = sbtab_table.column.column_names;

if isempty(column_names),
  display('The SBtab table contains no columns');
else,
  display('- Columns:');
  for it = 1:length(column_names),
    display(sprintf('    %s',column_names{it}));
  end
end