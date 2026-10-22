% Tests for SBtab tables

setup_test_path;
t  = example_table;
t2 = sbtab_table_add_column(t, 'Gene-ID', {'g1';'g2';'g3'});
t2 = sbtab_table_add_column(t2, '>Sample:S1', [1;2;3]);
t3 = sbtab_table_add_column(t, 'Comment', {'x';'y';'z'}, 0);

%% construct, get and check columns
assert(isequal(sbtab_table_get_column(t,'ID'), {'A';'B';'C'}));
assert(isequal(sbtab_table_get_column(t,'!Identifiers:kegg.compound'), {'C00001';'C00002';'C00003'}));
assert(sbtab_table_has_column(t,'Identifiers:kegg.compound'));
assert(~sbtab_table_has_column(t,'Unit'));
assert(isempty(sbtab_table_get_column(t,'Unit',0,0)));
assert(strcmp(sbtab_table_get_element(t,'Name','ID','B'), 'b'));

%% add columns, also with special characters in the column names
assert(isequal(sbtab_table_get_column(t2,'Gene-ID'), {'g1';'g2';'g3'}));
assert(isequal(sbtab_table_get_column(t2,'>Sample:S1',1), [1;2;3]));
assert(isequal(t2.column.ind, 1:5));

%% adding an existing column raises an error
failed = 0;
try, sbtab_table_add_column(t, 'Name', {'x';'y';'z'}); catch, failed = 1; end
assert(failed);

%% uncontrolled columns
assert(isequal(sbtab_table_get_column(t3,'Comment'), {'x';'y';'z'}));
tt = sbtab_table_to_table(t3);
assert(isequal(size(tt), [3 4]));

%% get columns as numbers (strings, numbers, Booleans)
t4 = sbtab_table_construct(struct('TableID','T','TableType','Quantity'), {'S','N','B'}, {{'1';'2.5';''}, {1;2;[]}, {'True';'false';'True'}});
assert(isequaln(sbtab_table_get_column(t4,'S',1), [1;2.5;nan]));
assert(isequaln(sbtab_table_get_column(t4,'N',1), [1;2;nan]));
assert(isequal(sbtab_table_get_column(t4,'B',1), [1;0;1]));

%% remove column
t5 = sbtab_table_remove_column(t, 'Identifiers:kegg.compound');
assert(isequal(t5.column.column_names(:)', {'ID','Name'}));
assert(~sbtab_table_has_column(t5,'Identifiers:kegg.compound'));

%% save to file and load
filename = [tempname '.tsv'];
sbtab_table_save(t2, struct('filename', filename));
t6 = sbtab_table_load(filename);
assert(strcmp(t6.attributes.TableID, 'Compound'));
assert(isequal(sbtab_table_get_column(t6,'Gene-ID'), {'g1';'g2';'g3'}));
assert(isequal(sbtab_table_get_column(t6,'>Sample:S1',1), [1;2;3]));
delete(filename);

%% load from a cell array, with comment lines, row attributes and empty columns
my_table = {'!!SBtab TableID=''T'' TableType=''Quantity''', '', '', '';
            '!ID',  '!Value', '', 'Note';
            '!Unit', 'mM',   '', '';
            'A',    '1',      '', 'x';
            '%B',   '2',      '', 'y';
            'C',    '3',      '', 'z'};
t7 = sbtab_table_load([], my_table);
assert(isequal(sbtab_table_get_column(t7,'ID'), {'A';'%B';'C'}));
assert(isfield(t7.rows,'Unit'));
assert(isequal(t7.uncontrolled.headers, {'Note'}));
t8 = sbtab_table_remove_comment_lines(t7);
assert(isequal(sbtab_table_get_column(t8,'ID'), {'A';'C'}));
assert(isequal(sbtab_table_get_column(t8,'Note'), {'x';'z'}));

%% select rows
t9 = sbtab_table_subselect_items(t3, 'Name', [], 'b');
assert(isequal(sbtab_table_get_column(t9,'ID'), {'B'}));
assert(isequal(sbtab_table_get_column(t9,'Comment'), {'y'}));

%% combine tables
th = sbtab_table_combine_horizontally(t, sbtab_table_construct(struct('TableID','X','TableType','Compound'), {'Charge'}, {{'0';'1';'-1'}}));
assert(isequal(numel(th.column.column_names), 4));
assert(isequal(sbtab_table_get_column(th,'Charge'), {'0';'1';'-1'}));
tv = sbtab_table_combine_vertically(t, t);
assert(isequal(sbtab_table_get_column(tv,'ID'), {'A';'B';'C';'A';'B';'C'}));

%% compare tables
t10 = t;
t10.column.column.Name{2} = 'b_new';
result = sbtab_table_diff(t, t10);
assert(isequal(result.Name(2,:), {'B','b','b_new'}));

%% conversion into a cell array and a matrix
c = sbtab_table_to_cell(t);
assert(isequal(c(2,:), {'!ID','!Name','!Identifiers:kegg.compound'}));
m = sbtab_table_to_matrix(matrix_to_sbtab_table([1 2; 3 4], 'M'));
assert(isequal(m, [1 2; 3 4]));
