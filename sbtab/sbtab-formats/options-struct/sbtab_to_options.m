[options,attributes] = sbtab_to_struct_simple(sbtab,'Option','Value');

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
