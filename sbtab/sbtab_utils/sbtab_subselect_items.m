function t = sbtab_subselect_items(t,column,sbtab_file_out)

% t = sbtab_subselect_items(t,column,sbtab_file_out)

if isstr(t),
  t = sbtab_table_load(t);
end

ind = find(cellfun('length',t.column.column.(column)));

fn = fieldnames(t.column.column);
for it = 1:length(fn),
  t.column.column.(fn{it}) = t.column.column.(fn{it})(ind);
end

if exist('sbtab_file_out','var'),
  sbtab_table_save(t,struct('filename',sbtab_file_out));
end
