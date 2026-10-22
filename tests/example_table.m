function t = example_table()

% t = example_table()
%
% Small SBtab table used in the tests

t = sbtab_table_construct(struct('TableID','Compound','TableType','Compound'), ...
                          {'ID','Name','Identifiers:kegg.compound'}, ...
                          {{'A';'B';'C'}, {'a';'b';'c'}, {'C00001';'C00002';'C00003'}});
