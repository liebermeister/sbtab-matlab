function sbtab_check_controlled(my_table)

% SBTAB_CHECK_CONTROLLED Check uniqueness of keys in first table column
%
% sbtab_check_controlled(my_table)

fn = fieldnames(my_table);
keys = my_table.(fn{1});

if length(unique(keys))<length(keys)
  [~, ind_unique] = unique(keys);
  redundant = unique(keys(setdiff(1:length(keys), ind_unique)));
  warning('Redundant keys: %s', strjoin(cellfun(@num2str, redundant(:)', 'UniformOutput', false), ', '));
end
