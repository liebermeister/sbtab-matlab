% Tests for regulation networks (sbtab_regulation_network_load, sbtab_regulation_network_save)

setup_test_path;
network.targets    = {'geneA';'geneB';'geneC'};
network.regulators = {'TF1';'TF2'};
network.arrows     = [1 0; 1 1; 0 1];
network.signs      = [1 0; -1 0; 0 -1];   % TF2 -> geneB: sign unknown

%% Regulation table: save and load
filename = [tempname '.tsv'];
sbtab_regulation_network_save(network, filename);
text = fileread(filename);
assert(contains(text, 'TableType=''Regulation'''));
assert(contains(text, sprintf('Reg1\tTF1\tgeneA\ttranscriptional regulator\tgene\tactivation')));
assert(contains(text, sprintf('TF1\tTF1\ttranscriptional regulator')));
assert(contains(text, sprintf('TF2\tgeneB\ttranscriptional regulator\tgene\tunknown')));
loaded = sbtab_regulation_network_load(filename);
delete(filename);
assert(isequal(loaded.targets, network.targets) && isequal(loaded.regulators, network.regulators));
assert(isequal(full(loaded.arrows), network.arrows) && isequal(full(loaded.signs), network.signs));
assert(strcmp(loaded.source, 'Regulation'));

%% column ActivityCondition of the Gene table: save and load
filename = [tempname '.tsv'];
sbtab_regulation_network_save(network, filename, struct('format','ActivityCondition'));
text = fileread(filename);
assert(~contains(text, 'TableType=''Regulation'''));
assert(contains(text, sprintf('geneB\tgeneB\t- TF1 ? TF2')));
loaded = sbtab_regulation_network_load(filename);
delete(filename);
assert(isequal(full(loaded.arrows), network.arrows) && isequal(full(loaded.signs), network.signs));
assert(strcmp(loaded.source, 'ActivityCondition'));

%% weights (SparseMatrix table)
network.weights = [0.5 0; -1.2 0.3; 0 -0.8];
filename = [tempname '.tsv'];
sbtab_regulation_network_save(network, filename, struct('weight_quantity_type','regulation weight (linear scale)'));
text = fileread(filename);
assert(contains(text, 'TableType=''SparseMatrix'' RowTable=''Gene'' ColumnTable=''Regulator'' QuantityType=''regulation weight (linear scale)'''));
loaded = sbtab_regulation_network_load(filename);
delete(filename);
assert(isequal(full(loaded.weights), network.weights));
assert(strcmp(loaded.weight_quantity_type, 'regulation weight (linear scale)'));
network = rmfield(network, 'weights');

%% Regulation table: signs from RegulationType:SBO and RegulatoryCoefficient; kinetic rows ignored;
% without Gene and Regulator tables, targets and regulators are taken from the arrows
filename = [tempname '.tsv'];
fid = fopen(filename,'w');
fprintf(fid, ['!!!SBtab Document=''n'' SBtabVersion=''1.2''\n' ...
              '!!SBtab TableID=''Regulation'' TableType=''Regulation''\n' ...
              '!ID\t!Regulator\t!Target\t!TargetType\t!RegulationType:SBO\t!RegulatoryCoefficient\n' ...
              'R1\tTF1\tg1\tgene\tSBO:0000020\t\n' ...
              'R2\tTF2\tg1\tgene\t\t2\n' ...
              'R3\tTF2\tg2\tgene\tSBO:0000596\tNaN\n' ...
              'R4\tATP\tPFK\tenzyme\t\t-1\n']);
fclose(fid);
loaded = sbtab_regulation_network_load(filename);
delete(filename);
assert(isequal(loaded.targets, {'g1';'g2'}) && isequal(loaded.regulators, {'TF1';'TF2'}));
assert(isequal(full(loaded.arrows), [1 1; 0 1]) && isequal(full(loaded.signs), [-1 1; 0 0]));
