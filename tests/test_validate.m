% Tests for the validator (sbtab_document_validate)

setup_test_path;
tab = sprintf('\t');
d = tempname;
mkdir(d);
cleanup = onCleanup(@() rmdir(d, 's'));
validate = @(text, version) validate_text(d, text, version);
rules = @(m) strcat({m.severity}, ':', {m.rule});

compounds = ['!!SBtab SBtabVersion=''1.0'' TableType=''Compound'' TableName=''C''' newline ...
             '!ID' tab '!Name' newline 'A' tab 'a' newline 'B' tab 'b' newline];
reaction  = @(formula) ['!!SBtab SBtabVersion=''1.0'' TableType=''Reaction'' TableName=''R''' newline ...
                        '!ID' tab '!ReactionFormula' newline 'R1' tab formula newline];
% the same table in SBtab 1.1 (the table key is TableID)
compounds_11 = strrep(strrep(compounds, '''1.0''', '''1.1'''), 'TableName=', 'TableID=');

%% a valid document gives no messages
m = validate([reaction('A <=> 2 B') compounds], '');
assert(isempty(m));

%% the validator reports problems as messages and never stops with an error
m = validate(['!!SBtab TableName=''X''' newline '!ID' newline 'a' newline], '');
assert(any(strcmp(rules(m), 'Error:R04')));
m = sbtab_document_validate(fullfile(d, 'does_not_exist.tsv'), struct('verbose', 0));
assert(strcmp(m(1).severity, 'Error'));

%% declaration rows
m = validate(['%comment' newline 'A' tab 'B' newline compounds], '');
assert(any(strcmp(rules(m), 'Error:R01')));
m = validate(strrep(compounds, 'Compound''', 'Compounds'''), '');
assert(any(strcmp(rules(m), 'Error:R05')));
m = validate(strrep(compounds, ' TableName=''C''', ''), '');
assert(any(strcmp(rules(m), 'Error:R06')));
m = validate([reaction('A <=> B') strrep(compounds, '''C''', '''R''')], '');
assert(any(strcmp(rules(m), 'Error:R08')));

%% the table key must be a shortname: a warning in 1.0 (TableName), an error in 1.1 (TableID)
m = validate(strrep(compounds, '''C''', '''My compounds'''), '');
assert(any(strcmp(rules(m), 'Warning:R07')));
m = validate(strrep(compounds_11, '''C''', '''My compounds'''), '');
assert(any(strcmp(rules(m), 'Error:R07')));
assert(isempty(validate(compounds_11, '')));
m = validate(strrep(compounds_11, 'TableID=', 'TableName='), '');
assert(any(strcmp(rules(m), 'Error:R06')));

%% columns and keys
m = validate(strrep(compounds, '!Name', '!Colour'), '');
assert(any(strcmp(rules(m), 'Warning:R22')));
assert(any(strcmp(rules(m), 'Error:R50')));
m = validate(strrep(compounds, [newline 'B' tab], [newline 'A' tab]), '');
assert(any(strcmp(rules(m), 'Error:R40')));
m = validate(strrep(compounds, [newline 'B' tab], [newline tab]), '');
assert(any(strcmp(rules(m), 'Error:R61')));
m = validate(strrep(compounds, [newline 'B' tab], [newline '1B' tab]), '');
assert(any(strcmp(rules(m), 'Warning:R41')));
m = validate(strrep(compounds_11, '!ID', '!Compound'), '');
assert(any(strcmp(rules(m), 'Warning:R50')) && ~any(strcmp({m.severity}, 'Error')));

%% reaction formulae
assert(any(strcmp(rules(validate([reaction('A -> B') compounds], '')), 'Error:R52')));
assert(any(strcmp(rules(validate([reaction('n A <=> B') compounds], '')), 'Error:R53')));
assert(any(strcmp(rules(validate([reaction('1 A <=> B') compounds], '')), 'Warning:R53')));
assert(any(strcmp(rules(validate([reaction('A <=> X') compounds], '')), 'Info:R42')));

%% value formats, also for attributes written with ':'
quantity = ['!!SBtab SBtabVersion=''1.0'' TableType=''Quantity'' TableName=''Q''' newline ...
            '!ID' tab '!QuantityType' tab '!Value' newline 'q1' tab 'concentration' tab 'VALUE' newline];
assert(isempty(validate(strrep(quantity, 'VALUE', '?'), '')));
assert(any(strcmp(rules(validate(strrep(quantity, 'VALUE', 'high'), '')), 'Error:R60')));
assert(any(strcmp(rules(validate(strrep(quantity, 'VALUE', '1,5'), '')), 'Warning:R62')));
m = validate(strrep(reaction('A <=> B'), 'TableName=''R''', 'TableName=''R'' :IsReversible=''maybe'''), '');
assert(any(strcmp(rules(m), 'Error:R60')));
m = validate(strrep(reaction('A <=> B'), 'TableName=''R''', 'TableName=''R'' IsReversible=''maybe'''), '');
assert(~any(strcmp(rules(m), 'Error:R60')));

%% custom table types defined in the document
custom = ['!!SBtab SBtabVersion=''1.0'' TableType=''MyType'' TableName=''M''' newline '!ID' tab '!Colour' newline 'a' tab 'red' newline ...
          '!!SBtab SBtabVersion=''1.0'' TableType=''Definition'' TableName=''Def''' newline ...
          '!ComponentName' tab '!ComponentType' tab '!IsPartOf' tab '!Format' tab '!Description' newline ...
          'MyType' tab 'Table' tab tab 'String' tab 'x' newline ...
          'ID' tab 'Column' tab 'MyType' tab 'Shortname' tab 'x' newline ...
          'Colour' tab 'Column' tab 'MyType' tab 'String' tab 'x' newline];
assert(isempty(validate(custom, '')));

%% pointers in version 1.1
matrix = ['!!SBtab SBtabVersion=''1.1'' TableType=''QuantityMatrix'' TableID=''Data''' newline ...
          '!Compound' tab 'POINTER' newline 'A' tab '1.1' newline ...
          '!!SBtab SBtabVersion=''1.1'' TableType=''Measurement'' TableID=''Sample''' newline ...
          '!Sample' tab '!Time' newline 's1' tab '0' newline];
assert(isempty(validate(strrep(matrix, 'POINTER', '!>Sample:s1'), '')));
assert(any(strcmp(rules(validate(strrep(matrix, 'POINTER', '!>Sample:s9'), '')), 'Error:R31')));
assert(any(strcmp(rules(validate(strrep(matrix, 'POINTER', '>Sample:s1'), '')), 'Warning:R30')));

%% a document object can be validated, too
f = fullfile(d, 'doc.tsv');
write_text(f, [reaction('A <=> B') compounds]);
assert(isempty(sbtab_document_validate(sbtab_document_load(f), struct('verbose', 0))));


% -----------------------------------------------------

function m = validate_text(d, text, version)
f = fullfile(d, sprintf('case_%d.tsv', randi(1e9)));
write_text(f, text);
m = sbtab_document_validate(f, struct('verbose', 0, 'version', version));
end

function write_text(filename, text)
fid = fopen(filename, 'w', 'n', 'UTF-8');
fprintf(fid, '%s', text);
fclose(fid);
end
