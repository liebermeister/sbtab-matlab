% Tests for !SBO:<quantity> [<unit>:<Scale>]:<ValueType> column headers

setup_test_path;

%% parsing the header
s = sbtab_parse_sbo_header('!SBO:concentration [mM:Log10]:Median');
assert(isequal(s, struct('QuantityType','concentration','Unit','mM','Scale','Log10','ValueType','Median')));
s = sbtab_parse_sbo_header('SBO:equilibrium constant');
assert(strcmp(s.QuantityType, 'equilibrium constant') && isempty(s.Unit) && strcmp(s.ValueType, 'Value'));
s = sbtab_parse_sbo_header('!SBO:concentration [mM]');
assert(strcmp(s.Unit, 'mM') && isempty(s.Scale));
s = sbtab_parse_sbo_header('!SBO:concentration:Mean');
assert(strcmp(s.ValueType, 'Mean') && isempty(s.Unit));
assert(isempty(sbtab_parse_sbo_header('!SBO:Identifiers:obo.sbo')));
assert(isempty(sbtab_parse_sbo_header('!Compound')));

%% virtual columns QuantityType, <ValueType>, Unit, Scale; the file stays unchanged
t = sbtab_table_construct(struct('TableID','Q','TableType','Quantity'), ...
      {'ID','Compound','SBO:concentration [mM:Log10]:Median'}, {{'c1';'c2'}, {'C1';'C2'}, {'1';'0'}});
assert(isequal(sbtab_table_get_column(t,'QuantityType'), {'concentration';'concentration'}));
assert(isequal(sbtab_table_get_column(t,'Median'), {'1';'0'}));
assert(isequal(sbtab_table_get_column(t,'Median',1), [1;0]));
assert(isequal(sbtab_table_get_column(t,'Unit'), {'mM';'mM'}));
assert(isequal(sbtab_table_get_column(t,'Scale'), {'Log10';'Log10'}));
assert(sbtab_table_has_column(t,'QuantityType') && ~sbtab_table_has_column(t,'Value'));
c = sbtab_table_save(t);
assert(isequal(c(2,1:3), {'!ID','!Compound','!SBO:concentration [mM:Log10]:Median'}));

%% existing columns take precedence; Mean and Std columns of the same quantity
t = sbtab_table_construct(struct('TableID','Q','TableType','Quantity'), ...
      {'ID','SBO:concentration:Mean','SBO:concentration:Std','Unit'}, {{'c1'}, {'1'}, {'0.1'}, {'mM'}});
assert(isequal(sbtab_table_get_column(t,'Mean'), {'1'}) && isequal(sbtab_table_get_column(t,'Std'), {'0.1'}));
assert(isequal(sbtab_table_get_column(t,'QuantityType'), {'concentration'}));
assert(isequal(sbtab_table_get_column(t,'Unit'), {'mM'}));
