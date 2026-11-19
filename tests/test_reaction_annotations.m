% Tests for reaction annotations with reaction orientation (SBtab 1.1 and 1.2): columns
% !ReactionIdentifiers:<DataCollection>, !ReactionMiriamAnnotation (Reaction tables),
% !Reaction:Identifiers:<DataCollection>, !Reaction:MiriamAnnotation (Quantity tables);
% double quotes in table files

setup_test_path;

%% parsing reaction identifiers
[id, o, ok, s] = sbtab_reaction_identifiers_parse('["R01068","orientation-reversed"]');
assert(strcmp(id, 'R01068') && strcmp(o, 'orientation-reversed') && ok && s == -1);
[id, o, ok] = sbtab_reaction_identifiers_parse('[ ''PGI'' , ''orientation-equal'' ]');
assert(strcmp(id, 'PGI') && strcmp(o, 'orientation-equal') && ok);
[id, o, ok, s] = sbtab_reaction_identifiers_parse('R01068');      % plain ID: orientation-equal
assert(strcmp(id, 'R01068') && strcmp(o, 'orientation-equal') && ok && s == 1);
[id, o, ok] = sbtab_reaction_identifiers_parse('');
assert(isempty(id) && isempty(o) && ok);
[id, o, ok] = sbtab_reaction_identifiers_parse('NaN');   % no entry
assert(isempty(id) && isempty(o) && ok);
for bad = {'["R01068"]', '["R01068","reversed"]', '["R01068","orientation-equal","x"]', '{"R01068":"orientation-equal"}'}
  [~, ~, ok] = sbtab_reaction_identifiers_parse(bad{1});
  assert(~ok, bad{1});
end
[ids, os, ok, signs] = sbtab_reaction_identifiers_parse({'["R00771","orientation-equal"]'; '["R01068","orientation-reversed"]'; ''; '["x","bad"]'});
assert(isequal(ids, {'R00771'; 'R01068'; ''; ''}) && isequal(os, {'orientation-equal'; 'orientation-reversed'; ''; ''}));
assert(isequal(ok, [true; true; true; false]) && isequal(signs(1:2), [1; -1]) && all(isnan(signs(3:4))));

%% formatting reaction identifiers
assert(strcmp(sbtab_reaction_identifiers_format('R01068', 'orientation-reversed'), '["R01068","orientation-reversed"]'));
assert(strcmp(sbtab_reaction_identifiers_format('PGI'), 'PGI'));   % orientation-equal: plain ID
assert(strcmp(sbtab_reaction_identifiers_format('PGI', 'orientation-equal', 1), '["PGI","orientation-equal"]'));
% unknown orientation (NaN): plain ID
assert(isequal(sbtab_reaction_identifiers_format({'R00771'; 'R01068'; ''; 'R00200'}, [1; -1; 1; nan]), ...
               {'R00771'; '["R01068","orientation-reversed"]'; ''; 'R00200'}));
try
  sbtab_reaction_identifiers_format('PGI', 'equal');
  error('no error for an invalid orientation');
catch err
  assert(~isempty(strfind(err.message, 'Invalid reaction orientation')));
end

%% Miriam annotations (JSON lists, the same form in SBtab 1.1 and 1.2)
expected = {'', 'urn:miriam:obo.chebi:CHEBI%3A15377'; '', 'urn:miriam:kegg.compound:C00001'};
text = '[["","urn:miriam:obo.chebi:CHEBI%3A15377"],["","urn:miriam:kegg.compound:C00001"]]';
[a, ok] = sbtab_miriam_annotation_parse(text); assert(ok && isequal(a, expected));
assert(strcmp(sbtab_miriam_annotation_format(expected), text));
[a, ok] = sbtab_miriam_annotation_parse('');   assert(ok && isempty(a));
[~, ok] = sbtab_miriam_annotation_parse('[["bqbiol:is"]]'); assert(~ok);
[~, ok] = sbtab_miriam_annotation_parse('{"":"urn:miriam:obo.chebi:CHEBI%3A15377"}'); assert(~ok);   % object form: not used

%% reaction Miriam annotations
expected = {'bqbiol:is', 'urn:miriam:kegg.reaction:R01068', 'orientation-reversed'; ...
            'bqbiol:is', 'urn:miriam:bigg.reaction:FBA',    'orientation-reversed'};
text = ['[["bqbiol:is","urn:miriam:kegg.reaction:R01068","orientation-reversed"],' ...
        '["bqbiol:is","urn:miriam:bigg.reaction:FBA","orientation-reversed"]]'];
[a, ok] = sbtab_miriam_annotation_parse(text, 1); assert(ok && isequal(a, expected));
assert(strcmp(sbtab_miriam_annotation_format(expected), text));
% orientation omitted: orientation-equal
equal = {'bqbiol:is', 'urn:miriam:kegg.reaction:R00771', 'orientation-equal'};
[a, ok] = sbtab_miriam_annotation_parse('[["bqbiol:is","urn:miriam:kegg.reaction:R00771"]]', 1); assert(ok && isequal(a, equal));
assert(strcmp(sbtab_miriam_annotation_format(equal), '[["bqbiol:is","urn:miriam:kegg.reaction:R00771"]]'));
assert(strcmp(sbtab_miriam_annotation_format(equal, 1), '[["bqbiol:is","urn:miriam:kegg.reaction:R00771","orientation-equal"]]'));
[a, ok] = sbtab_miriam_annotation_parse(['[["bqbiol:is","urn:miriam:kegg.reaction:R00771"],' ...
                                         '["bqbiol:is","urn:miriam:bigg.reaction:FBA","orientation-reversed"]]'], 1);
assert(ok && isequal(a(:,3), {'orientation-equal'; 'orientation-reversed'}));
for bad = {'[["bqbiol:is"]]', ...
           '[["bqbiol:is","urn:miriam:kegg.reaction:R01068","reversed"]]', ...
           '{"bqbiol:is":["urn:miriam:kegg.reaction:R01068","orientation-equal"]}'}
  [~, ok] = sbtab_miriam_annotation_parse(bad{1}, 1);
  assert(~ok, bad{1});
end

%% validator (rule R78)
t = sbtab_table_construct(struct('TableID','Reaction','TableType','Reaction','SBtabVersion','1.1'), ...
      {'ID','ReactionFormula','ReactionIdentifiers:kegg.reaction','ReactionMiriamAnnotation'}, ...
      {{'FBA';'PGI'}, {'DHAP + GAP <=> FBP';'G6P <=> F6P'}, {'["R01068","orientation-reversed"]';''}, ...
       {'[["bqbiol:is","urn:miriam:bigg.reaction:FBA","orientation-reversed"]]';''}});
m = sbtab_document_validate(t, struct('verbose', 0));
assert(~any(strcmp({m.rule}, 'R78')) && ~any(strcmp({m.rule}, 'R22')) && ~any(strcmp({m.rule}, 'R51')));

t = sbtab_table_construct(struct('TableID','Flux','TableType','Quantity','SBtabVersion','1.1'), ...
      {'ID','QuantityType','Reaction','Reaction:Identifiers:kegg.reaction','Reaction:MiriamAnnotation','Value'}, ...
      {{'flux_FBA'}, {'rate of reaction'}, {'FBA'}, {'["R01068","orientation-reversed"]'}, ...
       {'[["bqbiol:is","urn:miriam:kegg.reaction:R01068","orientation-reversed"]]'}, {'-0.5'}});
m = sbtab_document_validate(t, struct('verbose', 0));
assert(~any(strcmp({m.rule}, 'R78')) && ~any(strcmp({m.rule}, 'R22')));

t = sbtab_table_construct(struct('TableID','Reaction','TableType','Reaction','SBtabVersion','1.1'), ...
      {'ID','Identifiers:kegg.reaction','ReactionIdentifiers:kegg.reaction','ReactionMiriamAnnotation'}, ...
      {{'FBA';'PGI'}, {'R01068';''}, {'["R01068","reversed"]';'R00771'}, {'[["bqbiol:is"]]';''}});
m = sbtab_document_validate(t, struct('verbose', 0));
r78 = {m(strcmp({m.rule}, 'R78')).message};
assert(length(r78) == 3, 'three R78 warnings expected');   % (the plain ID R00771 is valid)
assert(any(~cellfun('isempty', strfind(r78, 'same data resource'))));
assert(~any(strcmp({m.rule}, 'R51')));

%% the example file is read with the JSON strings unchanged, and it is valid
filename = fullfile(sbtab_resourcedir, 'examples', 'sbtab-1.1', 'reaction_annotations', 'reaction_annotations.tsv');
d = sbtab_document_load_from_one(filename);
entries = sbtab_table_get_column(d.tables.Reaction, 'ReactionIdentifiers:kegg.reaction');
assert(isequal(entries(:), {'R00771'; '["R01068","orientation-reversed"]'}));
[~, o] = sbtab_reaction_identifiers_parse(sbtab_table_get_column(d.tables.Flux, 'Reaction:Identifiers:kegg.reaction'));
assert(isequal(o(:), {'orientation-equal'; 'orientation-reversed'}));
m = sbtab_document_validate(filename, struct('verbose', 0));
assert(~any(strcmp({m.severity}, 'Error')) && ~any(strcmp({m.rule}, 'R78')) && ~any(strcmp({m.rule}, 'R22')));

%% quantity data are matched by the IDs in reaction identifier columns
t = sbtab_table_construct(struct('TableID','Flux','TableType','Quantity','Unit','mM/s'), ...
      {'QuantityType','Reaction:Identifiers:kegg.reaction','Value'}, ...
      {{'rate of reaction';'rate of reaction'}, {'["R01068","orientation-reversed"]';'R00771'}, {'-0.5';'2'}});
M = sbtab_load_quantity_data(t, [], 'rate of reaction', 'Reaction:Identifiers:kegg.reaction', {'R00771';'R01068'}, {'Value'}, 1);
assert(isequal(M, [2; -0.5]));

%% double quotes in files: kept inside fields, removed around fields (as written by spreadsheet programs)
q = char(34);   % double quote
filename = [tempname '.tsv'];
fid = fopen(filename, 'w');
fprintf(fid, '%s\n', '!!SBtab TableID=''R'' TableType=''Reaction'' SBtabVersion=''1.1''');
fprintf(fid, '%s\n', sprintf('!ID\t!Name\t!ReactionIdentifiers:kegg.reaction'));
fprintf(fid, '%s\n', sprintf('FBA\tC-4'' decarboxylase\t["R01068","orientation-reversed"]'));
fprintf(fid, '%s\n', sprintf('PGI\t%ssay %s%shello%s%s%s\t["R00771","orientation-equal"]', q, q, q, q, q, q));
fclose(fid);
t = sbtab_table_load(filename);
names = sbtab_table_get_column(t, 'Name');
assert(isequal(names(:), {'C-4'' decarboxylase'; ['say ' q 'hello' q]}));
ids = sbtab_table_get_column(t, 'ReactionIdentifiers:kegg.reaction');
assert(isequal(ids(:), {'["R01068","orientation-reversed"]'; '["R00771","orientation-equal"]'}));
% saving and loading again gives the same entries
filename2 = [tempname '.tsv'];
sbtab_table_save(t, struct('filename', filename2));
t2 = sbtab_table_load(filename2);
names2 = sbtab_table_get_column(t2, 'Name');
ids2 = sbtab_table_get_column(t2, 'ReactionIdentifiers:kegg.reaction');
assert(isequal(names2(:), names(:)) && isequal(ids2(:), ids(:)));
delete(filename); delete(filename2);

disp('test_reaction_annotations: all tests passed');
