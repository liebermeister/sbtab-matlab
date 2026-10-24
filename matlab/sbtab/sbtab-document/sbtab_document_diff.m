function sbtab_document_diff(SBtab_document_1, SBtab_document_2)

% sbtab_document_diff(SBtab_document_1, SBtab_document_2)
%
% Compare the tables that appear in both SBtab documents (see sbtab_table_diff)
%
% SBtab_document_1 and SBtab_document_2 can be filenames or SBtab structs

d1 = sbtab_document_load(SBtab_document_1);
d2 = sbtab_document_load(SBtab_document_2);

table_names = intersect(fieldnames(d1.tables),fieldnames(d2.tables));

for it = 1:length(table_names)
  display(sprintf('Comparing tables %s',table_names{it}))
  sbtab_table_diff(d1.tables.(table_names{it}),d2.tables.(table_names{it}));
end
