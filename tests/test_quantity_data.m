% Tests for reading quantity data

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
