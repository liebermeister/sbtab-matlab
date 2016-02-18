function sbtab_table_show(sbtab_table)

% SBTAB_TABLE_SHOW Show contents of Sbtab table
%
% sbtab_table_show(sbtab_table)
%
% display contents of an SBtab table

if isempty(fieldnames(sbtab_table.attributes)),
  display(['The table has no attributes']);
else,
  display(['- Table attributes:']);
  attr = fieldnames(sbtab_table.attributes);
  for it = 1:length(attr)
    display(sprintf('    %s="%s"',attr{it}, sbtab_table.attributes.(attr{it})))
  end
end

column_names = sbtab_table.column.column_names;
uncontrolled_column_names = sbtab_table.uncontrolled.headers;

if isempty(column_names),
  display('The SBtab table contains no columns');
else,
  display('- SBtab columns:');
  for it = 1:length(column_names),
    display(sprintf('    !%s',column_names{it}));
  end
  if length(uncontrolled_column_names),
  display('- Uncontrolled columns:');
  for it = 1:length(uncontrolled_column_names),
    display(sprintf('    %s',uncontrolled_column_names{it}));
  end
  end
  display(sprintf('- Number of rows: %d',length(sbtab_table.column.column.(column_names{1}))));
  
end

