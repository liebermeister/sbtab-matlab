% Tests for extra definitions tables (sbtab_definitions, sbtab_definitions_merge,
% sbtab_document_set_definitions, sbtab_document_get_definitions; SBtab 1.2)

setup_test_path;
tab = sprintf('\t');
d = tempname;
mkdir(d);
cleanup = onCleanup(@() rmdir(d, 's'));
rules = @(m) strcat({m.severity}, ':', {m.rule});

extension = ['!!SBtab TableID=''MyDefinitions'' TableType=''Definition'' SBtabVersion=''1.1''' newline ...
             '!Name' tab '!Type' tab '!Parent' tab '!isShortname' tab '!Format' tab '!Description' newline ...
             'MyType' tab 'Table' tab 'SBtab' tab 'False' tab 'String' tab 'a table type of my tool' newline ...
             'ID' tab 'Column' tab 'MyType' tab 'True' tab 'String' tab 'key' newline ...
             'Colour' tab 'Column' tab 'MyType' tab 'False' tab 'String' tab 'colour' newline ...
             'Name' tab 'Column' tab 'Compound' tab 'False' tab 'String' tab 'my description' newline];
extension_file = fullfile(d, 'my_definition.tsv');
write_text(extension_file, extension);
document = ['!!!SBtab Document=''d'' SBtabVersion=''1.1''' newline ...
            '!!SBtab TableID=''C'' TableType=''Compound''' newline '!ID' tab '!Name' newline 'A' tab 'A' newline ...
            '!!SBtab TableID=''M'' TableType=''MyType''' newline '!ID' tab '!Colour' tab '!Size' newline 'x' tab 'red' tab '1' newline];
document_file = fullfile(d, 'doc.tsv');
write_text(document_file, document);
has_row = @(t, name, parent) any(strcmp(sbtab_table_get_column(t, 'Name'), name) & strcmp(sbtab_table_get_column(t, 'Parent'), parent));

%% extend: rows are appended, rows with the same Name and Parent are replaced
base = sbtab_definitions('1.1');
merged = sbtab_definitions('1.1', extension_file);
n_base = length(sbtab_table_get_column(base, 'Name'));
assert(length(sbtab_table_get_column(merged, 'Name')) == n_base + 3);
assert(has_row(merged, 'MyType', 'SBtab') && has_row(merged, 'Colour', 'MyType'));
names = sbtab_table_get_column(merged, 'Name');
parents = sbtab_table_get_column(merged, 'Parent');
descriptions = sbtab_table_get_column(merged, 'Description');
assert(strcmp(descriptions{strcmp(names, 'Name') & strcmp(parents, 'Compound')}, 'my description'));

%% replace: only the extra definitions
replaced = sbtab_definitions('1.1', extension_file, 'replace');
assert(has_row(replaced, 'MyType', 'SBtab') && ~has_row(replaced, 'Reaction', 'SBtab'));

%% extension in the SBtab 1.0 layout
ext10 = sbtab_table_construct(struct('TableName', 'Defs', 'TableType', 'Definition', 'SBtabVersion', '1.0'), ...
          {'ComponentName', 'ComponentType', 'IsPartOf', 'Format'}, {{'Colour'}, {'Column'}, {'Compound'}, {'String'}});
assert(has_row(sbtab_definitions_merge(sbtab_definitions('1.1'), ext10), 'Colour', 'Compound'));

%% document object with extra definitions; the validator uses them
doc = sbtab_document_load(document_file);
m = sbtab_document_validate(doc, struct('verbose', 0));
assert(any(strcmp(rules(m), 'Error:R05')));
doc = sbtab_document_set_definitions(doc, extension_file);
assert(strcmp(doc.definitions.mode, 'extend'));
assert(has_row(sbtab_document_get_definitions(doc), 'MyType', 'SBtab'));
m = sbtab_document_validate(doc, struct('verbose', 0));
assert(~any(strcmp(rules(m), 'Error:R05')));
assert(any(strcmp(rules(m), 'Warning:R22')));   % !Size is not defined for MyType
doc = sbtab_document_set_definitions(doc, []);
assert(~isfield(doc, 'definitions'));

%% validator option definitions (extend by default; replace on request)
m = sbtab_document_validate(document_file, struct('verbose', 0, 'definitions', extension_file));
assert(~any(strcmp(rules(m), 'Error:R05')));
m = sbtab_document_validate(document_file, struct('verbose', 0, 'definitions', extension_file, 'definitions_mode', 'replace'));
assert(~any(strcmp(rules(m), 'Error:R05')));   % Compound is a Parent in the extension
reaction_doc = fullfile(d, 'reaction.tsv');
write_text(reaction_doc, strrep(document, 'Compound', 'Reaction'));
m = sbtab_document_validate(reaction_doc, struct('verbose', 0, 'definitions', extension_file, 'definitions_mode', 'replace'));
assert(any(strcmp(rules(m), 'Error:R05')));

%% Definition tables contained in the document extend the definitions
inner = fullfile(d, 'inner.tsv');
write_text(inner, [document strrep(extension, ' SBtabVersion=''1.1''', '')]);
doc = sbtab_document_load(inner);
assert(has_row(sbtab_document_get_definitions(doc), 'Colour', 'MyType'));

%% invalid mode
try
  sbtab_definitions('1.1', extension_file, 'append');
  assert(false, 'no error for an invalid mode');
catch err
  assert(contains(err.message, 'Unknown definitions mode'));
end


% -----------------------------------------------------

function write_text(filename, text)
fid = fopen(filename, 'w', 'n', 'UTF-8');
fprintf(fid, '%s', text);
fclose(fid);
end
