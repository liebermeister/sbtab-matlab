function table_id = sbtab_clean_table_id(table_id)

% SBTAB_CLEAN_TABLE_ID Convert an SBtab table ID into a Matlab field name
%
% table_id = sbtab_clean_table_id(table_id)
%
% In SBtab document objects, the tables are stored in a struct (my_sbtab_document.tables)
% whose field names are obtained from the table IDs by this function:
% spaces are removed, and all other characters except letters, digits, and '_' are replaced by '_'
% Example: 'Quantity-species' -> 'Quantity_species'

table_id = strrep(table_id, ' ', '');
table_id = regexprep(table_id, '[^A-Za-z0-9_]', '_');
