function SBtab_table = sbtab_table_combine_horizontally(SBtab_table_1, SBtab_table_2)

% SBtab_table = sbtab_table_combine_horizontally(SBtab_table_1, SBtab_table_2)
%
% SBtab_table_1 and  SBtab_table_2 can be filenames or SBtab structs
  
if isstr(SBtab_table_1),
  t1 = sbtab_table_load(SBtab_table_1);
else
  t1 = SBtab_table_1;
end

if isstr(SBtab_table_2),
  t2 = sbtab_table_load(SBtab_table_2);
else
  t2 = SBtab_table_2;
end

col_1 = t1.column.column_names;
col_2 = t2.column.column_names;

for it = 1:length(col_1),
  if ~strcmp(col_1{it},col_2{it}),
    error('SBtab tables cannot be vertically combined - the colunm names do not match');
  end
end

if length(t1.uncontrolled.ind) + length(t1.uncontrolled.ind),
  error('Tables with uncontrolled columns cannot be combined'); 
end

t1 = SBtab_table_1;
t1.attributes = join_struct(t2.attributes,t1.attributes);

cols = fieldnames(t1.column.column); 
for it = 1:length(cols),
  t1.column.column.(cols{it}) = [t1.column.column.(cols{it}); t2.column.column.(cols{it})];
end

SBtab_table = t1;