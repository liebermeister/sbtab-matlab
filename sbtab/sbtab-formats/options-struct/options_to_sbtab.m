function sbtab = options_to_sbtab(s,options)

% OPTIONS_TO_SBTAB - Convert "config" matlab struct (typically used for for tool options) to SBtab
%
% sbtab = options_to_sbtab(s,options)
%
% IMPORTANT: to allow for complex structures, in the SBtab all information is stored in JSON string
%
% options.filename:   (optional) filename for export 
% options.TableName:  (optional) TableName attribute, for SBtab
  
eval(default('options','struct'));
options_default = struct('TableName','Options');
options = join_struct(options_default,options); 

column_options = {};
column_values  = {};
fn = fieldnames(s);
for it = 1:length(fn),
  if ~isempty(s.(fn{it})),
    s.(fn{it}) = jsonencode(s.(fn{it}));
    column_options = [ column_options; fn(it)];
    column_values  = [ column_values;  s.(fn{it})];
  end
end

sbtab = sbtab_table_construct(struct('TableType','Config','TableName',options.TableName), {'Option','Value'},{column_options,column_values});

if isfield(options,'filename'),
  sbtab_table_save(sbtab,options.filename);
  display(sprintf('Writing options to SBtab file %s', options.filename));
end
