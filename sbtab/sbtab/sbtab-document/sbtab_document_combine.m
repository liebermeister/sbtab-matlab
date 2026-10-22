function sbtab_document = sbtab_document_combine(doc1, doc2)

% sbtab_document = sbtab_document_combine(doc1, doc2)
%
% merge two sbtab documents

sbtab_document.attributes = join_struct(doc1.attributes, doc2.attributes);
common_names = intersect(doc1.table_names,doc2.table_names);
if length(common_names),
  error('Redundant Table IDs (%s) - SBtab documents cannot be combined', strjoin(common_names,', '));
else
  sbtab_document.table_names = [column(doc1.table_names); column(doc2.table_names)];
  sbtab_document.tables = join_struct(doc1.tables, doc2.tables);
end

unique_ids_1 = sbtab_document_get_ids(doc1);
unique_ids_2 = sbtab_document_get_ids(doc2);

common_ids = intersect(unique_ids_1, unique_ids_2);
if length(common_ids),
  error('Redundant Element IDs (%s) - SBtab documents cannot be combined', strjoin(common_ids,', '));
end