function my_sbtab_document = sbtab_document_add_table(my_sbtab_document,table_name,table)

% SBTAB_DOCUMENT_ADD_TABLE Add table to SBtab document.
%
% my_sbtab_document = sbtab_document_add_table(my_sbtab_document,table_name,table)

my_sbtab_document.tables.(table_name) = table;
