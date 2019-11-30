function sbtab = options_to_sbtab(s,options)

% OPTIONS_TO_SBTAB - Convert "config" matlab struct (typically used for tool options) into SBtab object
%
% sbtab = options_to_sbtab(s,options)
%
% IMPORTANT: to allow for complex structures, in the SBtab all information is stored in JSON string
%
% options.filename:   (optional) filename for export 
% options.TableName:  (optional) TableName attribute, for SBtab
%
% see also sbtab_to_options

eval(default('options','struct'));
options_default = struct('TableName','Config','CalculationMethod','unknown');
options = join_struct(options_default,options); 
column_options = {};
column_values  = {};
fn = fieldnames(s);
for it = 1:length(fn),
  my_string = s.(fn{it});
  if ~isempty(my_string),
    my_string = jsonencode(my_string);
    if strcmp(my_string(1),'"') * strcmp(my_string(end),'"'),
      my_string = my_string(2:end-1);
    end
    column_options = [ column_options; fn(it)];
    column_values  = [ column_values;  my_string];
  end
end


sbtab = sbtab_table_construct(struct('TableID','Config','TableType','Config','TableName',options.TableName,'CalculationMethod',options.CalculationMethod), {'Option','Value'},{column_options,column_values});

if isfield(options,'filename'),
  sbtab_table_save(sbtab,options.filename);
  display(sprintf('Writing options to SBtab file %s', options.filename));
end
