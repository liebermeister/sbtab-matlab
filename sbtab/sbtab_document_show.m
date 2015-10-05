function sbtab_document_show(sbtab_document)

% SBTAB_DOCUMENT_SHOW Display contents of an SBtab document
%
% sbtab_document_show(sbtab_document)

if isempty(fieldnames(sbtab_document.attributes)),
  display(sprintf('The SBtab document has no document attributes'));
else,
  sbtab_document.attributes
end

tables = fieldnames(sbtab_document.tables);

if isfield(sbtab_document,'table_names'),
  table_names = sbtab_document.table_names;
else
  table_names = tables;
end

if isempty(tables),
  display('The SBtab document contains no tables');
else,
  for it = 1:length(tables);
  display(sprintf('\no Table "%s"',table_names{it}))
  sbtab_table_show(sbtab_document.tables.(tables{it}))
  end
end
