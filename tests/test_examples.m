% Tests with the example files in resources/examples/sbtab:
% each file can be loaded, saved and loaded again without changes

setup_test_path;

%% load, save and reload all example files
files = dir(fullfile(sbtab_resourcedir, 'examples', 'sbtab', '**', '*.tsv'));
assert(numel(files) > 0);
filename = [tempname '.tsv'];
for i = 1:numel(files)
  example_file = fullfile(files(i).folder, files(i).name);
  [~, d] = evalc('sbtab_document_load(example_file)');
  evalc('sbtab_document_save(d, filename, 0, 0)');
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
example_file = fullfile(sbtab_resourcedir, 'examples', 'sbtab', 'ecoli', 'ecoli_wortel_2018_model.tsv');
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
