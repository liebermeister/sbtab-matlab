% Tests for conversions between SBtab objects and Matlab structs

setup_test_path;
t = example_table;

%% table -> struct with columns -> table
s = sbtab_to_struct(t, 'column');
assert(isequal(s.Name, {'a';'b';'c'}));
assert(strcmp(s.TABLE_ATTRIBUTES.TableID, 'Compound'));
t2 = struct_to_sbtab(s);
assert(isequal(sbtab_table_get_column(t2,'Name'), {'a';'b';'c'}));
assert(strcmp(t2.attributes.TableID, 'Compound'));

%% table -> struct with rows
s = sbtab_to_struct(t, 'row');
assert(strcmp(s.B.Name, 'b'));

%% table -> struct array -> table
s = sbtab_to_struct(t, 'row-cell', struct('store_attributes',0));
assert(numel(s) == 3 && strcmp(s(3).Name, 'c'));
t3 = struct_to_sbtab(s, 'table', 'row-cell');
assert(isequal(t3.column.column_names(:)', {'ID','Name','Identifiers_kegg_compound'}));
assert(isequal(column(sbtab_table_get_column(t3,'ID')), {'A';'B';'C'}));

%% document -> struct -> document
d = sbtab_document_construct(struct('Document','Test'), {'Compound'}, {t});
s = sbtab_to_struct(d, 'column');
d2 = struct_to_sbtab(s);
assert(strcmp(sbtab_object_type(d2), 'document'));
assert(isequal(sbtab_table_get_column(d2.tables.Compound,'Name'), {'a';'b';'c'}));

%% options struct -> SBtab table -> options struct
options = struct('name','test','n',3,'x',[1 2 3],'flag',true,'sub',struct('a',1));
t4 = options_to_sbtab(options);
options2 = sbtab_to_options(t4);
assert(strcmp(options2.name, 'test'));
assert(options2.n == 3);
assert(isequal(options2.x(:)', [1 2 3]));
assert(options2.flag == 1);
assert(options2.sub.a == 1);

%% simple struct from key and value columns
my_struct = sbtab_table_to_simple_struct(t, 'ID', 'Name');
assert(isequal(my_struct, struct('A','a','B','b','C','c')));
