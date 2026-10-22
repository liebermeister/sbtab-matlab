% Tests for SBtab documents

setup_test_path;
example_file = fullfile(sbtab_resourcedir, 'examples', 'sbtab', 'ecoli', 'ecoli_noor_2016_model.tsv');

d = sbtab_document_load(example_file);
reaction_table = sbtab_document_get_table(d, 'Reaction');
d2 = sbtab_document_construct(struct('Document','Test'), {'Compound'}, {example_table});
d2 = sbtab_document_add_table(d2, 'Reaction', reaction_table);
d2 = sbtab_document_add_column(d2, 'Compound', 'Charge', {'0';'0';'0'});

%% load a document
assert(strcmp(sbtab_object_type(d), 'document'));
assert(all(ismember({'Reaction','Compound'}, sbtab_document_get_table_names(d))));
assert(strcmp(reaction_table.attributes.TableType, 'Reaction'));

%% load a single table from a document file
t = sbtab_table_load(example_file, [], 0, 'Compound');
assert(strcmp(t.attributes.TableID, 'Compound'));

%% construct a document and add tables
assert(isequal(d2.table_names, {'Compound';'Reaction'}));
assert(sbtab_table_has_column(d2.tables.Compound, 'Charge'));

%% save to one file and load again
filename = [tempname '.tsv'];
sbtab_document_save(d2, filename, 0, 0);
d3 = sbtab_document_load(filename);
assert(isequal(d3.table_names, {'Compound';'Reaction'}));
assert(isfield(d3.attributes, 'Date'));
assert(isequal(sbtab_table_get_column(d3.tables.Compound,'Charge'), {'0';'0';'0'}));
delete(filename);

%% save to separate files and load them
basename = tempname;
sbtab_document_save(d2, basename, 0, 0, 0);
d4 = sbtab_document_load({'Compound','Reaction'}, {[basename '_Compound.tsv'], [basename '_Reaction.tsv']});
assert(isequal(d4.table_names, {'Compound';'Reaction'}));
delete([basename '_Compound.tsv']); delete([basename '_Reaction.tsv']);

%% table IDs that are not valid Matlab names
filename = fullfile(sbtab_resourcedir, 'examples', 'sbtab', 'hynne', 'hynne_quantity_concentration.tsv');
d5 = sbtab_document_load(filename);
assert(~isempty(sbtab_document_get_table(d5, d5.table_names{1})));

%% combine documents
d6 = sbtab_document_combine(sbtab_document_construct(struct, {'A'}, {example_table}), ...
                            sbtab_document_construct(struct, {'R'}, {reaction_table}));
assert(isequal(d6.table_names, {'A';'R'}));
failed = 0;
try, sbtab_document_combine(d6, d6); catch, failed = 1; end
assert(failed);
