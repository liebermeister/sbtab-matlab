function sbtab_document_save(sbtab_document,filename,flag_latex,verbose,to_one_file,sbtab_version)

% SBTAB_DOCUMENT_SAVE Save SBtab document to files (one for each table)
%
% sbtab_document_save(sbtab_document,filename,flag_latex,verbose,to_one_file,sbtab_version)
%
% If to_one_file==1 (default), the document is saved to one file [filename].tsv;
% otherwise, each table is saved to a file [filename]_[TableID].tsv
% (or .tex, if flag_latex==1). The extension .tsv in filename is optional.
% sbtab_version: SBtab version to be written ('1.0' or '1.1'; default: see 'sbtab_version');
%                it is always written in the declaration lines

eval(default('flag_latex','0','verbose','1','to_one_file','1','sbtab_version','[]'));
sbtab_version = sbtab_check_version(sbtab_version);
add_date_and_sbtab_version = 1;

if endsWith(filename,'.tsv')
  filename = filename(1:end-4);
end

if to_one_file

  sbtab_document_save_to_one(sbtab_document,[filename '.tsv'],verbose,flag_latex,sbtab_version);

else

  fn = fieldnames(sbtab_document.tables);

  if add_date_and_sbtab_version
    sbtab_document.attributes.Date = datestr(date,29);
  end

  for it = 1:length(fn)
    my_sbtab_table = sbtab_document.tables.(fn{it});
    switch flag_latex
      case 0,  my_filename = [filename '_' fn{it} '.tsv'];
      case 1,  my_filename = [filename '_' fn{it} '.tex'];
    end
    if ~isfield(my_sbtab_table.attributes, 'TableID')
      warning('Table ID is missing');
    end
    if verbose
      display(sprintf('Writing table %s to file %s', fn{it}, my_filename));
    end
    sbtab_table_save(my_sbtab_table,struct('filename',my_filename,'flag_latex',flag_latex,'add_date_and_sbtab_version',0,'sbtab_version',sbtab_version));
  end

end
