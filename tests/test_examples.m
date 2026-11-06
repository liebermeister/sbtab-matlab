% Tests with the example files in resources/examples/sbtab-1.0, sbtab-1.1, sbtab-1.2:
% each file can be loaded, saved and loaded again without changes
%
% By default only the examples of SBtab 1.1 are tested; the environment variable
% SBTAB_TEST_VERSIONS selects others, e.g. SBTAB_TEST_VERSIONS=1.0,1.1 or SBTAB_TEST_VERSIONS=all

setup_test_path;

%% load, save and reload all example files
versions = getenv('SBTAB_TEST_VERSIONS');
if isempty(versions), versions = '1.1'; end
if strcmp(versions, 'all')
  versions = {'1.0', '1.1', '1.2'};
else
  versions = strtrim(strsplit(versions, ','));
end
files = [];
for v = versions
  files = [files; dir(fullfile(sbtab_resourcedir, 'examples', ['sbtab-' v{1}], '**', '*.tsv'))];
end
assert(numel(files) > 0);
filename = [tempname '.tsv'];
for i = 1:numel(files)
  example_file = fullfile(files(i).folder, files(i).name);
  % save in the SBtab version of the example folder (sbtab-1.0, sbtab-1.1, sbtab-1.2)
  version = regexp(example_file, 'sbtab-(1\.\d)', 'tokens', 'once');
  [~, d] = evalc('sbtab_document_load(example_file)');
  evalc('sbtab_document_save(d, filename, 0, 0, 1, version{1})');
  [~, d2] = evalc('sbtab_document_load(filename)');
  table_ids = fieldnames(d.tables);
  assert(isequal(fieldnames(d2.tables), table_ids), 'Tables differ in %s', files(i).name);
  for k = 1:numel(table_ids)
    c1 = d.tables.(table_ids{k}).column.column;
    c2 = d2.tables.(table_ids{k}).column.column;
    fn = fieldnames(c1);
    assert(isequal(fieldnames(c2), fn), 'Columns differ in %s', files(i).name);
    for j = 1:numel(fn)
      same = strcmp(c1.(fn{j}), c2.(fn{j})) | (cellfun('isempty', c1.(fn{j})) & cellfun('isempty', c2.(fn{j})));
      assert(all(same), 'Column %s differs in %s', fn{j}, files(i).name);
    end
  end
end
delete(filename);

%% print and convert all tables of an example document
example_file = fullfile(sbtab_resourcedir, 'examples', 'sbtab-1.1', 'escherichia-coli', 'escherichia-coli_wortel_2018_model.tsv');
d = sbtab_document_load(example_file);
evalc('sbtab_print(d)');
evalc('sbtab_print(d, ''all'')');
table_ids = fieldnames(d.tables);
for k = 1:numel(table_ids)
  my_table = sbtab_table_to_table(d.tables.(table_ids{k}));
  assert(istable(my_table));
end
s = sbtab_to_struct(d, 'table');
assert(isfield(s, 'Reaction'));
