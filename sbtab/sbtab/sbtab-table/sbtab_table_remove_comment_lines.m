function my_sbtab_table = sbtab_table_remove_comment_lines(my_sbtab_table)

% SBTAB_TABLE_REMOVE_COMMENT_LINES Remove all comment lines from a table
%
% my_sbtab_table = sbtab_table_remove_comment_lines(my_sbtab_table)
%
% Comment lines are rows whose entry in the first column starts with '%'

fn = fieldnames(my_sbtab_table.column.column);

if isempty(fn), return; end

ind = ~strncmp(my_sbtab_table.column.column.(fn{1}),'%',1);

my_sbtab_table = select_rows(my_sbtab_table, find(ind));


% -----------------------------------------------------

function t = select_rows(t, ind)

fn = fieldnames(t.column.column);
for it = 1:length(fn),
  t.column.column.(fn{it}) = t.column.column.(fn{it})(ind);
end
if length(t.data.ind),
  t.data.data = t.data.data(ind,:);
end
if length(t.uncontrolled.ind),
  t.uncontrolled.data = t.uncontrolled.data(ind,:);
end
