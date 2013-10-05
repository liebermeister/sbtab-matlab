function t = sbtab_table_add_annotation(t,column_old,column_new,item_old,item_new,sbtab_file_out)

% t = sbtab_table_add_annotation(t,column_old,column_new,item_old,item_new,sbtab_file_out)
%
% insert an annotation column into a table

if isstr(t),
  t = sbtab_table_load(t);
end

t.column.column_names = [t.column.column_names; column_new];

column_old = strrep(column_old,' ','_');
column_old = strrep(column_old,'.','_');
column_old = strrep(column_old,':','_');

column_new = strrep(column_new,' ','_');
column_new = strrep(column_new,'.','_');
column_new = strrep(column_new,':','_');

ind = label_names(item_old,t.column.column.(column_old));
t.column.column.(column_new) = repmat({''},length(t.column.column.(column_old)),1);
t.column.ind = [t.column.ind, max([t.column.ind, t.data.ind, t.uncontrolled.ind])+1];

t.column.column.(column_new)(ind(find(ind))) = item_new(find(ind));

if exist('sbtab_file_out','var'),
  sbtab_table_save(t,sbtab_file_out);
end
