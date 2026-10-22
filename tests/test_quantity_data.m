% Tests for reading quantity data and omics data

setup_test_path;
t = sbtab_table_construct(struct('TableID','Flux','TableType','Quantity','Unit','mM/s'), ...
                          {'QuantityType','Reaction','Value','Std'}, ...
                          {{'rate of reaction';'rate of reaction';'concentration'}, {'R1';'R2';'R1'}, {'1';'2';'3'}, {'0.1';'0.2';'0.3'}});

%% read data values from a quantity table
[M, ids, columns, unit] = sbtab_load_quantity_data(t, [], 'rate of reaction', 'Reaction', [], {'Value','Std'}, 1);
assert(isequal(M, [1 0.1; 2 0.2]));
assert(isequal(ids, {'R1';'R2'}));
assert(isequal(columns, {'Value';'Std'}));
assert(strcmp(unit, 'mM/s'));

%% select element IDs
M = sbtab_load_quantity_data(t, [], 'rate of reaction', '!Reaction', {'R2';'R3'}, {'!Value'}, 1);
assert(isequaln(M, [2; nan]));

%% omics data: dynamic data -> SBtab document -> file -> dynamic data
data = struct('MetaboliteName', {{'A';'B'}}, 'SampleName', {{'t1';'t2';'t3'}}, 'SampleTime', [0;1;2], ...
              'DataMean', [1 2 3; 4 5 6], 'DataStd', [0.1 0.2 0.3; 0.4 0.5 0.6], 'Info', {{'Organism','E. coli'}});
d = dynamic_data_2_sbtab(data, 'Test');
filename = [tempname '.tsv'];
sbtab_document_save(d, filename, 0, 0);
data2 = sbtab_2_dynamic_data(filename);
delete(filename);
assert(isequal(data2.MetaboliteName, data.MetaboliteName));
assert(isequal(data2.SampleName(:), data.SampleName));
assert(isequal(data2.SampleTime(:), data.SampleTime));
assert(isequal(data2.DataMean, data.DataMean));
assert(isequal(data2.DataStd, data.DataStd));
assert(isequal(data2.Info, data.Info));
