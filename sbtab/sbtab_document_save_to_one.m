function sbtab_document_save_to_one(sbtab_document,filename,verbose)

% SBTAB_DOCUMENT_SAVE Save SBtab document to one file (with concatenated tables)
%
% sbtab_document_save(sbtab_document,filename)

eval(default('flag_latex','0','verbose','1'));

fn = fieldnames(sbtab_document.tables);

my_table = {};

for it = 1:length(fn),
  my_sbtab_table      = sbtab_document.tables.(fn{it});
  my_sbtab_table_flat = sbtab_table_save(my_sbtab_table);
  if it>1,
    my_sbtab_table_flat = [[{sprintf('%%')}, repmat({''},1,size(my_sbtab_table_flat,2)-1) ]; my_sbtab_table_flat];
  end
  [ni,nj] = size(my_table);
  [mi,mj] = size(my_sbtab_table_flat);
  my_table(ni+(1:mi),1:mj) = my_sbtab_table_flat;
end

if verbose,
  display(sprintf('Writing SBtab document to file %s', filename));
end
mytable(my_table,0,filename);
