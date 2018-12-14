function [options,attributes] = sbtab2config(sbtab,default_options)

% SBTAB2CONFIG - Convert tool options from SBtab (data structure or filename) to matlab struct
%
% [options,attributes] = sbtab2config(sbtab,default_options)

eval(default('default_options','struct'));
  
if ischar(sbtab),
  display(sprintf('Reading SBtab file %s', sbtab));
  sbtab = sbtab_table_load(sbtab);
end

[options,attributes] = sbtab_table_convert_to_simple_struct(sbtab,'Option','Value');

fn = fieldnames(options);
for it = 1:length(fn),
  options.(fn{it})
  upper(options.(fn{it}))
  if strcmp(upper(options.(fn{it})),'TRUE'),
    options.(fn{it}) = 1;
  end
  if strcmp(upper(options.(fn{it})),'FALSE'),
    options.(fn{it}) = 0;
  end
end

options = join_struct(default_options,options);
