% Tests for writing SBtab files of different SBtab versions

setup_test_path;
t = example_table;
d = sbtab_document_construct(struct('Document','Test'), {'Compound'}, {t});
d = sbtab_document_add_table(d, 'Reaction', sbtab_table_construct(struct('TableID','Reaction','TableName','Reaction','TableType','Reaction'), {'ID'}, {{'R1'}}));
definitions_10 = sbtab_table_construct(struct('TableName','Definition','TableType','Definition','SBtabVersion','1.0'), ...
                   {'ComponentName','ComponentType','IsPartOf','Format','Description'}, ...
                   {{'ID'}, {'Column'}, {'Compound'}, {'string'}, {'Identifier'}});

%% default version 1.1 in the declaration line (also with the option add_date_and_sbtab_version)
assert(strcmp(sbtab_version, '1.1'));
c = sbtab_table_save(t);
assert(contains(c{1,1}, 'SBtabVersion=''1.1'''));
c = sbtab_table_save(t, struct('add_date_and_sbtab_version',1));
assert(contains(c{1,1}, 'SBtabVersion=''1.1''') && contains(c{1,1}, 'Date='));

%% version 1.0, also given as a number; an existing SBtabVersion attribute is replaced
c = sbtab_table_save(t, struct('sbtab_version','1.0'));
assert(contains(c{1,1}, 'SBtabVersion=''1.0'''));
c = sbtab_table_save(t, struct('sbtab_version',1));
assert(contains(c{1,1}, 'SBtabVersion=''1.0'''));
c = sbtab_table_save(definitions_10);
assert(contains(c{1,1}, 'SBtabVersion=''1.1''') && ~contains(c{1,1}, 'SBtabVersion=''1.0'''));

%% unsupported versions give a warning, and the default version is written
lastwarn('');
c = evalc('cc = sbtab_table_save(t, struct(''sbtab_version'',''1.2''));');
assert(contains(lastwarn, 'not supported'));
assert(contains(cc{1,1}, 'SBtabVersion=''1.1'''));

%% definition tables: column names of version 1.0 and 1.1
c = sbtab_table_save(definitions_10);
assert(isequal(c(2,1:5), {'!Name','!Type','!Parent','!Format','!Description'}));
assert(isequal(c(3,1:3), {'ID','Column','Compound'}));
t11 = sbtab_table_load([], c);
assert(isequal(sbtab_table_get_column(t11,'Parent'), {'Compound'}));
c = sbtab_table_save(t11, struct('sbtab_version','1.0'));
assert(isequal(c(2,1:5), {'!ComponentName','!ComponentType','!IsPartOf','!Format','!Description'}));
% tables that already have the target version are not changed
c = sbtab_table_save(definitions_10, struct('sbtab_version','1.0'));
assert(isequal(c(2,1:3), {'!ComponentName','!ComponentType','!IsPartOf'}));

%% the table key: TableID in version 1.1, TableName in version 1.0
t10 = sbtab_table_construct(struct('TableName','C','TableTitle','My compounds','TableType','Compound','SBtabVersion','1.0'), {'ID'}, {{'A'}});
c = sbtab_table_save(t10);
assert(contains(c{1,1}, 'TableID=''C''') && contains(c{1,1}, 'TableName=''My compounds''') && ~contains(c{1,1}, 'TableTitle'));
c = sbtab_table_save(sbtab_table_construct(struct('TableName','C','TableType','Compound','SBtabVersion','1.0'), {'ID'}, {{'A'}}));
assert(contains(c{1,1}, 'TableID=''C''') && ~contains(c{1,1}, 'TableName'));
c = sbtab_table_save(t10, struct('sbtab_version','1.0'));
assert(contains(c{1,1}, 'TableName=''C''') && contains(c{1,1}, 'TableTitle=''My compounds''') && ~contains(c{1,1}, 'TableID'));
t11 = sbtab_table_construct(struct('TableID','C','TableName','Compounds','TableType','Compound','SBtabVersion','1.1'), {'ID'}, {{'A'}});
c = sbtab_table_save(t11, struct('sbtab_version','1.0'));
assert(contains(c{1,1}, 'TableName=''C''') && contains(c{1,1}, 'TableTitle=''Compounds''') && ~contains(c{1,1}, 'TableID'));

%% version 1.1: warning for a TableID that is not a shortname
lastwarn('');
evalc('sbtab_table_save(sbtab_table_add_attribute(t,''TableID'',''Compound table''));');
assert(contains(lastwarn, 'not a shortname'));
lastwarn('');
evalc('sbtab_table_save(sbtab_table_add_attribute(t,''TableID'',''Compound table''), struct(''sbtab_version'',''1.0''));');
assert(isempty(lastwarn));

%% documents in one file: version in all declaration lines
for v = {'1.0', '1.1'}
  filename = [tempname '.tsv'];
  sbtab_document_save(d, filename, 0, 0, 1, v{1});
  lines = regexp(fileread(filename), '\r?\n', 'split');
  declarations = lines(startsWith(lines, '!!'));
  assert(length(declarations) == 3);
  assert(all(contains(declarations, ['SBtabVersion=''' v{1} ''''])));
  delete(filename);
end

%% documents in separate files: version in all declaration lines (default 1.1)
basename = tempname;
sbtab_document_save(d, basename, 0, 0, 0);
for table_name = {'Compound', 'Reaction'}
  filename = [basename '_' table_name{1} '.tsv'];
  lines = regexp(fileread(filename), '\r?\n', 'split');
  assert(contains(lines{1}, 'SBtabVersion=''1.1'''));
  delete(filename);
end
