function sbtab_check_controlled(my_table)

% sbtab_check_controlled(my_table)

fn = fieldnames(my_table);
keys = my_table.(fn{1});

if length(unique(keys))<length(keys), 
  sort(keys)
  error('Redundant keys'); end
