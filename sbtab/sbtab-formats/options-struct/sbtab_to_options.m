function options = sbtab_to_options(sbtab)

% SBTAB_TO_OPTIONS - Convert SBtab object into "config" matlab struct (typically used for tool options)
%
% options = sbtab_to_options(sbtab)
%
% Convert SBtab Config table into matlab struct (used for tool options)
%
% For the conversion in the other direction, see 'options_to_sbtab'

[options,attributes] = sbtab_table_to_simple_struct(sbtab,'Option','Value');

fn = fieldnames(options);

for it = 1:length(fn),
  my_option = options.(fn{it});
  if ~ischar(my_option) || isempty(my_option),
    continue
  end
  if strcmpi(my_option,'TRUE'),
    my_option = 1;
  elseif strcmpi(my_option,'FALSE'),
    my_option = 0;
  elseif strcmp(my_option(1),'[') || strcmp(my_option(1),'{'),
    my_option = jsondecode(my_option);
  else
    my_num = str2double(my_option);
    if ~isnan(my_num) || strcmpi(my_option,'NaN'),
      my_option = my_num;
    end
  end
  options.(fn{it}) = my_option;
end
