function sbtab_document_show(sbtab_document)

% sbtab_document_show(sbtab_document)
%
% display contents of an SBtab document

if isempty(fieldnames(sbtab_document.attributes)),
  display(sprintf('The SBtab document has no document attributes'));
else,
  sbtab_document.attributes
end

table_names = fieldnames(sbtab_document.tables);

if isempty(table_names),
  display('The SBtab document contains no tables');
else,
  for it = 1:length(table_names);
  display(sprintf('\no Table "%s"',table_names{it}))
  sbtab_table_show(sbtab_document.tables.(table_names{it}))
  end
end