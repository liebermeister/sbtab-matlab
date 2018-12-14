function my_table = sbtab_table_display(my_sbtab_table, options)

% SBTAB_TABLE_SAVE Display SBtab table
%
% my_table = sbtab_table_save(my_sbtab_table, options)
%
% options.omit_declarations
% options.flag_latex

eval(default('options','struct'));

if isfield(options,'filename'),
  options = rmfield(options,'filename');
end

my_table = sbtab_table_save(my_sbtab_table, options);