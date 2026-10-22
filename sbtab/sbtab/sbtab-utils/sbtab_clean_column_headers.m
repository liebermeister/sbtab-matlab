function column_names = sbtab_clean_column_headers(column_names)

% SBTAB_CLEAN_COLUMN_HEADERS Convert SBtab column names into Matlab field names
%
% column_names = sbtab_clean_column_headers(column_names)
%
% column_names: column name (string) or list of column names (cell array of strings)
%
% In SBtab table objects, the columns are stored in a struct (my_sbtab_table.column.column)
% whose field names are obtained from the column names by this function:
%  - a leading '!' is removed
%  - '>' is replaced by 'SAMPLE_'
%  - all other characters except letters, digits, and '_' are replaced by '_'
% Example: '!Compound:Identifiers:kegg.compound' -> 'Compound_Identifiers_kegg_compound'

column_names = regexprep(column_names, '^!', '');
column_names = strrep(column_names, '>', 'SAMPLE_');
column_names = regexprep(column_names, '[^A-Za-z0-9_]', '_');
