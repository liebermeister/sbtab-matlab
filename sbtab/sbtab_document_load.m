function my_sbtab_document = sbtab_document_load(table_names,filenames)

% my_sbtab_document = sbtab_document_load({'Reactions'},{'/home/wolfram/matlab/models/bsu_ccm_regulation/data/bsu_ccm2_regulation_reactions.csv'})

my_sbtab_document = struct('attributes',struct,'tables',struct);

for it = 1:length(table_names),
  my_sbtab_table = sbtab_table_load(filenames{it});
  my_sbtab_document.tables = setfield(my_sbtab_document.tables,table_names{it}, my_sbtab_table);
end
