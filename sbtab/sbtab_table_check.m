function sbtab_table_check(sbtab,type)

% sbtab_table_check(sbtab,type)

% test sbtab = sbtab_table_load('/home/wolfram/matlab/models/bsu_ccm_regulation/data/bsu_ccm2_regulation_reactions.csv');
% sbtab_check(sbtab)

eval(default('type','[]'));

if isempty(type), 
  if isfield(sbtab.meta_information,'Type');
    type = sbtab.meta_information.Type;
  else
    warning('No table type specified');
    end
end

fn = fieldnames(sbtab.columns);

for it = 1:length(fn)
   fn{it}
  end
