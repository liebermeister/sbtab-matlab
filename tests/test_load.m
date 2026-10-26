% Tests for loading SBtab files: file formats, declaration lines, table IDs, and
% problems that lead to warnings instead of errors

setup_test_path;
tab = sprintf('\t');
write_file = @(filename, text) fileread_write(filename, text);
d = tempname;
mkdir(d);
cleanup = onCleanup(@() rmdir(d, 's'));

doc_10 = [ ...
  '!!SBtab SBtabVersion=''1.0'' TableType=''Reaction'' TableName=''Reaction''' newline ...
  '!ID' tab '!ReactionFormula' newline ...
  'R1' tab 'A <=> B' newline ...
  newline ...
  '!!SBtab SBtabVersion=''1.0'' TableType=''Compound'' TableName=''Compound''' newline ...
  '!ID' tab '!Name' newline ...
  'A' tab 'a' newline ...
  'B' tab 'b' newline];

%% documents whose tables have a TableName but no TableID (SBtab 1.0)
f = fullfile(d, 'doc_10.tsv');
write_file(f, doc_10);
lastwarn('');
doc = sbtab_document_load(f);
assert(isequal(doc.table_names, {'Reaction'; 'Compound'}));
assert(strcmp(doc.tables.Compound.attributes.TableID, 'Compound'));
assert(isempty(lastwarn));

%% a TableID that only repeats the TableName is not written when saving
f = fullfile(d, 'doc_10.tsv');
write_file(f, doc_10);
f2 = fullfile(d, 'doc_10_saved.tsv');
sbtab_document_save_to_one(sbtab_document_load(f), f2, 0);
assert(~contains(fileread(f2), 'TableID'));
doc2 = sbtab_document_load(f2);
assert(isequal(doc2.table_names, {'Reaction'; 'Compound'}));

%% non-unique table IDs give a warning, and the tables are stored under different IDs
f = fullfile(d, 'doc_same_names.tsv');
write_file(f, strrep(doc_10, 'TableName=''Compound''', 'TableName=''Reaction'''));
lastwarn('');
doc = sbtab_document_load(f);
assert(contains(lastwarn, 'Non-unique table ID'));
assert(isequal(doc.table_names, {'Reaction'; 'Reaction_2'}));

%% a missing TableName gives a warning; the table type is used as table ID
f = fullfile(d, 'no_name.tsv');
write_file(f, ['!!SBtab TableType=''Compound''' newline '!ID' newline 'A' newline]);
lastwarn('');
t = sbtab_table_load(f);
assert(contains(lastwarn, 'Table name missing'));
assert(strcmp(t.attributes.TableID, 'Compound'));

%% comma- and semicolon-separated files, with quoted fields
f = fullfile(d, 'compound.csv');
write_file(f, ['!!SBtab TableType=''Compound'',TableName=''Compound''' newline ...
               '!ID,!Name' newline 'A,"a, with comma"' newline 'B,"say ""b"""' newline]);
t = sbtab_table_load(f);
assert(isequal(sbtab_table_get_column(t, 'Name'), {'a, with comma'; 'say "b"'}));
f = fullfile(d, 'compound_semicolon.csv');
write_file(f, ['!!SBtab TableType=''Compound'';TableName=''Compound''' newline ...
               '!ID;!Name' newline 'A;1,5' newline]);
t = sbtab_table_load(f);
assert(isequal(sbtab_table_get_column(t, 'Name'), {'1,5'}));

%% a tab-separated file whose declaration line contains a comma, but no tab
f = fullfile(d, 'comma_in_declaration.tsv');
write_file(f, ['!!SBtab TableType=''Compound'' TableName=''Compounds, with charges''' newline ...
               '!ID' tab '!Charge' newline 'A' tab '1' newline]);
t = sbtab_table_load(f);
assert(isequal(sbtab_table_get_column(t, 'Charge'), {'1'}));

%% byte order mark and Windows line endings
f = fullfile(d, 'bom_crlf.tsv');
write_file(f, [char(65279) strrep(doc_10, newline, sprintf('\r\n'))]);
doc = sbtab_document_load(f);
assert(isequal(doc.table_names, {'Reaction'; 'Compound'}));
assert(isequal(sbtab_table_get_column(doc.tables.Compound, 'Name'), {'a'; 'b'}));

%% attributes in the declaration line
a = sbtab_parse_attributes({'!!SBtab TableType=''Quantity'' TableName="Wolfram''s table"', ...
                            'Formula=''A = B''', ':Unit=''mM''', '>Sample=''s1''', 'Plain=value'});
assert(strcmp(a.TableType, 'Quantity'));
assert(strcmp(a.TableName, 'Wolfram''s table'));
assert(strcmp(a.Formula, 'A = B'));
assert(strcmp(a.Unit, 'mM'));
assert(strcmp(a.SAMPLE_Sample, 's1'));
assert(strcmp(a.Plain, 'value'));
a = sbtab_parse_attributes(['!!SBtab TableType=' char(8217) 'Compound' char(8217)]);
assert(strcmp(a.TableType, 'Compound'));

%% attributes written with ':' act as columns; attributes without ':' do not
f = fullfile(d, 'unit.tsv');
write_file(f, ['!!SBtab TableType=''Quantity'' TableName=''Conc'' :Unit=''mM'' ValueType=''Mean''' newline ...
               '!ID' tab '!Value' newline 'c1' tab '1' newline 'c2' tab '2' newline]);
t = sbtab_table_load(f);
assert(sbtab_table_has_column(t, 'Unit'));
assert(isequal(sbtab_table_get_column(t, 'Unit'), {'mM'; 'mM'}));
assert(strcmp(t.attributes.Unit, 'mM'));
assert(~sbtab_table_has_column(t, 'ValueType'));
assert(isempty(sbtab_table_get_column(t, 'ValueType', 0, 0)));
f2 = fullfile(d, 'unit_saved.tsv');
sbtab_table_save(t, f2);
text = fileread(f2);
assert(contains(text, ':Unit=''mM''') && contains(text, ' ValueType=''Mean'''));
assert(isequal(sbtab_table_get_column(sbtab_table_load(f2), 'Unit'), {'mM'; 'mM'}));

%% problems that lead to warnings instead of errors
my_table = {'!!SBtab TableType=''Compound'' TableName=''C''', '', '';
            '!ID', '', '!Name';
            'A', 'x', 'a'};
lastwarn('');
t = sbtab_table_load('', my_table);
assert(contains(lastwarn, 'Column header missing'));
assert(isequal(sbtab_table_get_column(t, 'Name'), {'a'}));

f = fullfile(d, 'two_tables.tsv');
write_file(f, doc_10);
lastwarn('');
t = sbtab_table_load(f);
assert(contains(lastwarn, 'several tables'));
assert(strcmp(t.attributes.TableType, 'Reaction'));

lastwarn('');
t = sbtab_table_construct(struct('TableType', 'Compound', 'TableName', 'C'), {'ID'}, {{'A'}});
assert(strcmp(t.attributes.TableID, 'C'));
assert(isempty(lastwarn));

lastwarn('');
sbtab_check_controlled(struct('ID', {{'A'; 'B'; 'A'}}));
assert(contains(lastwarn, 'Redundant keys: A'));


% -----------------------------------------------------

function fileread_write(filename, text)

fid = fopen(filename, 'w', 'n', 'UTF-8');
fprintf(fid, '%s', text);
fclose(fid);
end
