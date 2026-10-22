function my_table_sub = sbtab_remove_keys(my_table,remove_keys)

% SBTAB_REMOVE_KEYS Remove rows from SBtab table
%
% my_table_sub = sbtab_remove_keys(my_table,remove_keys)

if length(remove_keys),

fn = fieldnames(my_table);
keys = my_table.(fn{1});

ind_keep = find(~ismember(keys,remove_keys));

for itt = 1:length(fn),
  my_table_sub.(fn{itt}) = my_table.(fn{itt})(ind_keep);
end

else, 
  my_table_sub = my_table;
end