% SBtab - short demo: load SBtab table and show its structure

filename = [ sbtab_BASEDIR '/demo/data/sbtab_omics_row_example.tsv'];

S = sbtab_table_load(filename);

sbtab_table_show(S)
