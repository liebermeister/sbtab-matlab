function sbtab_table = sbtab_document_get_table(sbtab_document,table_name)

% SBTAB_DOCUMENT_GET_TABLE Get table from SBtab document.
%
% sbtab_table = sbtab_document_get_table(sbtab_document,table_name)

table_name = strrep(table_name,' ','');

if isfield(sbtab_document.tables,table_name),
  sbtab_table = sbtab_document.tables.(table_name);
else
  warning(sprintf('Table "%s" not found in SBtab object',table_name));
  sbtab_table = [];
end
