function my_sbtab_table = sbtab_document_add_table(my_sbtab_document,table_name)

% SBTAB_DOCUMENT_GET_TABLE Get table from SBtab document.
%
% my_sbtab_document = sbtab_document_add_table(my_sbtab_document,table_name,table)

my_sbtab_table = my_sbtab_document.tables.(table_name);
