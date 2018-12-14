function sbtab = config2sbtab(s,options)

% CONFIG2SBTAB - Convert "config" matlab struct (for tool options) to SBtab
%
% sbtab = config2sbtab(s,options)
%
% IMPORTANT: SOME FIELDS cannot be translated to SBtab and therefore removed
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
    if isstruct(s.(fn{it})), 
      warning(sprintf('Ignoring field %s',fn{it}));
    elseif [ischar(s.(fn{it})) + isnumeric(s.(fn{it}))],
      column_options = [ column_options; fn(it)];
      column_values  = [ column_values;  s.(fn{it})];
    else
      warning(sprintf('Ignoring field %s',fn{it}));
    end
  end
end

sbtab = sbtab_table_construct(struct('TableType','Config','TableName',options.TableName), {'Option','Value'},{column_options,column_values});

if isfield(options,'filename'),
  sbtab_table_save(sbtab,options.filename);
  display(sprintf('Writing options to SBtab file %s', options.filename));
end