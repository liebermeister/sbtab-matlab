function sbtab_document_save(sbtab_document,filename,flag_latex,verbose,to_one_file)

% SBTAB_DOCUMENT_SAVE Save SBtab document to files (one for each table)
%
% sbtab_document_save(sbtab_document,filename)
% 
% filename has to be without extension

eval(default('flag_latex','0','verbose','1','to_one_file','0'));

if to_one_file,

  sbtab_document_save_to_one(sbtab_document,[filename '.tsv'],verbose,flag_latex);

else

fn = fieldnames(sbtab_document.tables);

for it = 1:length(fn),
  my_sbtab_table = sbtab_document.tables.(fn{it});
  switch flag_latex,
    case 0,  my_filename = [filename '_' fn{it} '.tsv'];
    case 1,  my_filename = [filename '_' fn{it} '.tex'];
  end
  if verbose,
    display(sprintf('Writing table %s to file %s', fn{it}, my_filename));
  end
  sbtab_table_save(my_sbtab_table,struct('filename',my_filename,'flag_latex',flag_latex));
end

end