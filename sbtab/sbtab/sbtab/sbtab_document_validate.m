function messages = sbtab_document_validate(sbtab_document, options)

% SBTAB_DOCUMENT_VALIDATE Check an SBtab document against the SBtab specification
%
% messages = sbtab_document_validate(sbtab_document, options)
%
% sbtab_document: SBtab document object, SBtab table object, or file name
% options (struct, optional):
%   options.version     : SBtab version whose rules are applied ('1.0' or '1.1'); default: the
%                         SBtabVersion attribute of the document or of its first table, else
%                         options.default_version
%   options.default_version : version for documents without SBtabVersion attribute (default '1.0')
%   options.definitions : definitions table (SBtab table object or file name); default: the
%                         definitions table of this version (see sbtab_definitions)
%   options.verbose     : 1 (default): issue a Matlab warning for each problem found
%
% messages: struct array with fields
%   severity: 'Error' (the file violates a 'must' rule), 'Warning' (a 'should' rule), or 'Info'
%   rule    : rule ID (see conformance/<version>/rules.md in the SBtab project)
%   table   : table name (empty for the whole document)
%   message : description of the problem
%
% The function never stops with an error: problems in the document, including violations of
% mandatory rules, are reported as messages (and, if options.verbose is set, as warnings).
%
% Definition tables contained in the document extend the definitions (custom table types,
% columns and attributes).

if ~exist('options','var'), options = struct; end
options = join_struct(struct('version', [], 'default_version', '1.0', 'definitions', [], 'verbose', 1), options);

messages = struct('severity', {}, 'rule', {}, 'table', {}, 'message', {});
filename = '';
raw_declarations = {};

warning_state = warning('off', 'all');
try
  if ischar(sbtab_document)
    filename = sbtab_document;
    raw_declarations = read_declarations(filename);
    messages = check_file(filename, messages);
    sbtab_document = sbtab_document_load(filename);
  elseif isfield(sbtab_document, 'column')
    my_document = sbtab_document_construct;
    sbtab_document = sbtab_document_add_table(my_document, sbtab_document.attributes.TableID, sbtab_document);
  end
  warning(warning_state);

  version = options.version;
  if isempty(version)
    version = document_version(sbtab_document, options.default_version);
  end
  switch version
    case {'1.0', '1.1'}
    otherwise
      if strncmp(version, '1.', 2) && str2double(version) > 1.1
        messages = add(messages, 'Info', '', '', sprintf('SBtab version %s is checked with the rules of version 1.1', version));
        version = '1.1';
      else
        messages = add(messages, 'Info', '', '', sprintf('SBtab version %s is checked with the rules of version 1.0', version));
        version = '1.0';
      end
  end

  definitions = options.definitions;
  if isempty(definitions)
    definitions = sbtab_definitions(version);
  elseif ischar(definitions)
    definitions = sbtab_table_load(definitions);
  end
  defs = read_definitions(definitions);
  [defs, messages] = add_document_definitions(defs, sbtab_document, version, messages);

  messages = check_document(sbtab_document, raw_declarations, defs, version, messages);

catch err
  warning(warning_state);
  where = '';
  if ~isempty(err.stack)
    where = sprintf(' (in %s, line %d)', err.stack(1).name, err.stack(1).line);
  end
  messages = add(messages, 'Error', '', '', sprintf('Validation failed: %s%s', err.message, where));
end

if options.verbose
  for it = 1:length(messages)
    if isempty(messages(it).table)
      where = '';
    else
      where = sprintf(' in table %s', messages(it).table);
    end
    if isempty(messages(it).rule)
      rule = '';
    else
      rule = sprintf(' (%s)', messages(it).rule);
    end
    warning('SBtab %s%s%s: %s', lower(messages(it).severity), rule, where, messages(it).message);
  end
end


% =====================================================================
% Checks on the file and on the document

function messages = check_file(filename, messages)

% R01: every table starts with a declaration row; content before the first one belongs to no table

my_table = sbtab_load_text_table(filename);
for it = 1:size(my_table,1)
  first = strtrim(my_table{it,1});
  if strncmp(first, '%', 1)
    continue
  elseif strncmp(first, '!!', 2)
    return
  elseif any(~cellfun('isempty', my_table(it,:)))
    messages = add(messages, 'Error', 'R01', '', 'The file contains lines before the first declaration row (!!SBtab); they do not belong to any table');
    return
  end
end
messages = add(messages, 'Error', 'R01', '', 'The file contains no declaration row (!!SBtab)');


function declarations = read_declarations(filename)

% attributes of all table declaration rows, as written in the file

my_table = sbtab_load_text_table(filename);
ind = find(strncmp(my_table(:,1), '!!', 2) & ~strncmp(my_table(:,1), '!!!', 3));
declarations = cell(length(ind), 1);
for it = 1:length(ind)
  declarations{it} = sbtab_parse_attributes(my_table(ind(it),:));
end


function messages = check_document(sbtab_document, raw_declarations, defs, version, messages)

table_ids   = fieldnames(sbtab_document.tables);
table_names = {};
all_keys    = {};
key_tables  = {};

for it = 1:length(table_ids)
  t = sbtab_document.tables.(table_ids{it});
  if length(raw_declarations) == length(table_ids)
    declared = raw_declarations{it};
  else
    declared = t.attributes;
  end
  [messages, name] = check_table(t, declared, sbtab_document, defs, version, messages);
  if ~isempty(name)
    table_names{end+1} = name;
  end
  if has_column(t, 'ID')
    keys = get_column(t, 'ID');
    keys = keys(~cellfun('isempty', keys));
    all_keys   = [all_keys; keys(:)];
    key_tables = [key_tables; repmat({table_label(t)}, length(keys), 1)];
  end
end

% R08: table names are unique
[~, ind_unique] = unique(table_names);
duplicates = unique(table_names(setdiff(1:length(table_names), ind_unique)));
for it_name = 1:length(duplicates)
  name = duplicates(it_name);
  messages = add(messages, 'Error', 'R08', '', sprintf('Several tables have the %s %s', key_attribute(version), name{1}));
end

% R40: keys (column !ID) are unique within the document
[~, ind_unique] = unique(all_keys);
duplicates = unique(all_keys(setdiff(1:length(all_keys), ind_unique)));
for it_key = 1:length(duplicates)
  key = duplicates(it_key);
  in_tables = unique(key_tables(strcmp(all_keys, key{1})));
  messages = add(messages, 'Error', 'R40', strjoin(in_tables, ', '), sprintf('The key %s is used more than once in the document', key{1}));
end


% =====================================================================
% Checks on one table

function [messages, name] = check_table(t, declared, sbtab_document, defs, version, messages)

name = '';
label = table_label(t);

% ------------------------------------------
% Declaration row

if ~isfield(declared, 'TableType') || isempty(declared.TableType) || (declared_from_object(declared, t) && strcmp(declared.TableType, 'unknown'))
  messages = add(messages, 'Error', 'R04', label, 'The attribute TableType is missing');
  table_type = '';
else
  table_type = declared.TableType;
  if ~any(strcmp(defs.table_types, table_type))
    messages = add(messages, 'Error', 'R05', label, sprintf('Unknown table type %s (not defined in the definitions table)', table_type));
  end
end

% R06/R07: the table key is TableName in SBtab 1.0 and TableID in SBtab 1.1
key = key_attribute(version);
if ~isfield(declared, key) || isempty(declared.(key))
  messages = add(messages, 'Error', 'R06', label, sprintf('The attribute %s is missing', key));
else
  name = declared.(key);
  if ~is_shortname(name, 'strict')
    messages = add(messages, severity(version, 'Warning', 'Error'), 'R07', label, sprintf('The %s %s is not a shortname (letters, digits and _, starting with a letter)', key, name));
  end
end

% ------------------------------------------
% Columns

column_names = t.column.column_names(:)';
column_names = column_names(~cellfun('isempty', column_names));
constant_names = {};
if isfield(t.column, 'constant_names')
  constant_names = t.column.constant_names(:)';
end

if strcmp(version, '1.1')
  % R30: pointers are written !>Table:Row in version 1.1
  headers = t.uncontrolled.headers;
  if isempty(headers), headers = {}; end
  for header = reshape(headers(strncmp(headers, '>', 1)), 1, [])
    messages = add(messages, 'Warning', 'R30', label, sprintf('Column %s: pointers are written !>Table:Row in SBtab 1.1', header{1}));
  end
end

for column_name = [column_names, constant_names]
  c = column_name{1};
  is_sbo_header = strncmp(c, 'SBO:', 4);
  % R33/R34: syntax of !SBO:<quantity> [<unit>:<Scale>]:<ValueType> headers
  if is_sbo_header && ~strncmp(c, 'SBO:Identifiers:', 16) && isempty(sbtab_parse_sbo_header(c))
    messages = add(messages, 'Warning', 'R34', label, sprintf('Column !%s: SBO column headers have the form !SBO:<quantity> [<unit>:<Scale>]:<ValueType>', c));
  end
  % R22: columns must be defined for the table type
  if ~isempty(table_type) && any(strcmp(defs.table_types, table_type)) && isempty(column_format(defs, table_type, c))
    messages = add(messages, 'Warning', 'R22', label, sprintf('Column !%s is not defined for table type %s', c, table_type));
  end
  % R25: no whitespace or special characters in column names (except names from external sources)
  if ~is_sbo_header && ~isempty(regexp(c, '[^A-Za-z0-9_:.\->]', 'once'))
    messages = add(messages, 'Warning', 'R25', label, sprintf('Column name !%s contains whitespace or special characters', c));
  end
end

% R28: several Identifiers columns must refer to different resources
identifiers = column_names(~cellfun('isempty', regexp(column_names, '(^|:)Identifiers:', 'once')));
[~, ind_unique] = unique(identifiers);
for c = reshape(unique(identifiers(setdiff(1:length(identifiers), ind_unique))), 1, [])
  messages = add(messages, 'Error', 'R28', label, sprintf('Several columns !%s', c{1}));
end

% R24: keys in !ID, which should be the first column
if strcmp(version, '1.1') && has_column(t, 'ID') && ~strcmp(column_names{1}, 'ID')
  messages = add(messages, 'Warning', 'R24', label, 'The column !ID should be the first column');
end

% ------------------------------------------
% Keys

if has_column(t, 'ID')
  keys = get_column(t, 'ID');
  for it = 1:length(keys)
    if isempty(keys{it})
      messages = add(messages, 'Error', 'R61', label, sprintf('Row %d has no key (empty field in column !ID)', it));
    elseif ~is_shortname(keys{it}, 'key')
      messages = add(messages, severity(version, 'Warning', 'Error'), 'R41', label, sprintf('The key %s is not a shortname (it must start with a letter and contain no whitespace, ":" or ".")', keys{it}));
    end
  end
end

% ------------------------------------------
% Table-type specific rules

entity_types = {'Compound', 'Enzyme', 'Protein', 'Gene', 'Regulator', 'Compartment'};
switch table_type
  case entity_types
    if ~has_column(t, 'ID')
      messages = add(messages, 'Warning', 'R50', label, sprintf('%s tables must contain the column !ID', table_type));
    end
    specifying = {'Name', 'MiriamAnnotation', 'SBML:species:id', 'SBML:compartment:id', 'Symbol'};
    if ~any(ismember(column_names, specifying)) && ~any(~cellfun('isempty', regexp(column_names, '^Identifiers:', 'once')))
      messages = add(messages, 'Error', 'R50', label, sprintf('The %s table has no column specifying its elements (e.g. !Name, !Identifiers:...)', table_type));
    end
  case 'Reaction'
    if ~has_column(t, 'ID')
      messages = add(messages, 'Warning', 'R51', label, 'Reaction tables must contain the column !ID');
    end
    if ~has_column(t, 'ReactionFormula') && ~any(~cellfun('isempty', regexp(column_names, '^Identifiers:', 'once')))
      messages = add(messages, 'Error', 'R51', label, 'The Reaction table contains neither !ReactionFormula nor an !Identifiers column');
    end
    if has_column(t, 'ReactionFormula')
      messages = check_formulae(get_column(t, 'ReactionFormula'), sbtab_document, label, messages);
    end
  case 'Definition'
    switch version
      case '1.0', required = {'ComponentName', 'ComponentType', 'IsPartOf', 'Format'};
      otherwise,  required = {'Name', 'Type', 'Parent', 'Format'};
    end
    missing = setdiff(required, column_names, 'stable');
    if ~isempty(missing)
      messages = add(messages, 'Error', 'R56', label, sprintf('Definition tables in SBtab %s need the columns %s (missing: %s)', version, ...
                                                       strjoin(strcat('!', required), ', '), strjoin(strcat('!', missing), ', ')));
    end
end

% ------------------------------------------
% Values (R60, R62)

if ~isempty(table_type)
  for column_name = [column_names, constant_names]
    c = column_name{1};
    format = column_format(defs, table_type, c);
    if ~isempty(format)
      messages = check_values(get_column(t, c), format, c, label, messages);
    end
  end
end

% R31: pointers !>Table:Row refer to existing rows
if strcmp(version, '1.1')
  for c = column_names(strncmp(column_names, '>', 1))
    parts = regexp(c{1}(2:end), ':', 'split');
    if length(parts) == 2
      target = find_table(sbtab_document, parts{1});
      if isempty(target)
        messages = add(messages, 'Error', 'R31', label, sprintf('Column !%s: there is no table named %s', c{1}, parts{1}));
      elseif ~any(strcmp(table_keys(target), parts{2}))
        messages = add(messages, 'Error', 'R31', label, sprintf('Column !%s: table %s has no row %s', c{1}, parts{1}, parts{2}));
      end
    end
  end
end


function messages = check_formulae(formulae, sbtab_document, label, messages)

% R52: arrow <=>; R53: numerical stoichiometric coefficients, no explicit 1; R42: reactants defined

compounds = {};
compound_tables = find_tables_of_type(sbtab_document, 'Compound');
for it = 1:length(compound_tables)
  compounds = [compounds; table_keys(compound_tables{it})];
end
undefined = {};

for it = 1:length(formulae)
  f = strtrim(formulae{it});
  if isempty(f), continue; end
  sides = regexp(f, '<=>', 'split');
  if length(sides) ~= 2
    messages = add(messages, 'Error', 'R52', label, sprintf('Reaction formula "%s" does not contain exactly one arrow <=>', f));
    continue
  end
  for side = sides
    s = strtrim(side{1});
    if isempty(s), continue; end
    for term = regexp(s, '\s+\+\s+', 'split')
      tokens = regexp(strtrim(term{1}), '\s+', 'split');
      if length(tokens) == 2
        coefficient = str2double(tokens{1});
        if isnan(coefficient)
          messages = add(messages, 'Error', 'R53', label, sprintf('Reaction formula "%s": stoichiometric coefficient "%s" is not a number', f, tokens{1}));
        elseif coefficient == 1
          messages = add(messages, 'Warning', 'R53', label, sprintf('Reaction formula "%s": coefficients 1 should be omitted', f));
        end
        reactant = tokens{2};
      elseif length(tokens) == 1
        reactant = tokens{1};
      else
        messages = add(messages, 'Error', 'R53', label, sprintf('Reaction formula "%s": cannot read the term "%s"', f, term{1}));
        continue
      end
      reactant = regexprep(reactant, '\[[^\]]*\]$', '');
      if ~any(strcmp(compounds, reactant))
        undefined{end+1} = reactant;
      end
    end
  end
end

if ~isempty(undefined)
  messages = add(messages, 'Info', 'R42', label, sprintf('Reactants not defined in a Compound table of the document: %s', strjoin(unique(undefined), ', ')));
end


function messages = check_values(values, format, column_name, label, messages)

if isnumeric(values), return; end
bad = {};
decimal_comma = 0;
for it = 1:length(values)
  v = strtrim(values{it});
  if isempty(v) || any(strcmpi(v, {'?', 'na', 'nan'}))
    continue
  end
  switch lower(regexprep(format, '\(.*', ''))
    case {'boolean'}
      ok = any(strcmpi(v, {'true', 'false', '1', '0'}));
    case {'number', 'float'}
      % (str2double would read '1,5' as 15)
      ok = isempty(strfind(v, ',')) && ~isnan(str2double(v)) || ~isempty(regexp(v, '^[-+]?(\d+\.?\d*|\.\d+)?\s*[-+]?\s*i\s*\d*\.?\d*$', 'once')) || any(strcmpi(v, {'inf', '-inf'}));
    case 'integer'
      x = str2double(v);
      ok = ~isnan(x) && x == round(x);
    case 'enum'
      allowed = regexp(format, '''([^'']*)''', 'tokens');
      ok = any(strcmp(v, [allowed{:}]));
    otherwise
      ok = 1;
  end
  if ~ok
    if any(strcmpi(format, {'number', 'float'})) && ~isempty(regexp(v, '^[-+]?\d+,\d+$', 'once'))
      decimal_comma = 1;
    else
      bad{end+1} = v;
    end
  end
end
if decimal_comma
  messages = add(messages, 'Warning', 'R62', label, sprintf('Column !%s: use decimal points, not decimal commas', column_name));
end
if ~isempty(bad)
  messages = add(messages, 'Error', 'R60', label, sprintf('Column !%s (format %s) contains invalid values: %s', column_name, format, strjoin(unique(bad), ', ')));
end


% =====================================================================
% Definitions

function defs = read_definitions(definitions)

% columns of the definitions table (layout of SBtab 1.0 or 1.1)

if has_column(definitions, 'ComponentName')
  names   = get_column(definitions, 'ComponentName');
  types   = get_column(definitions, 'ComponentType');
  parents = get_column(definitions, 'IsPartOf');
else
  names   = get_column(definitions, 'Name');
  types   = get_column(definitions, 'Type');
  parents = get_column(definitions, 'Parent');
end
formats = get_column(definitions, 'Format');
if isempty(formats), formats = repmat({''}, size(names)); end
if isempty(parents), parents = repmat({''}, size(names)); end

defs.table_types = names(strcmp(types, 'Table'));
is_column        = strcmp(types, 'Column');
defs.columns     = names(is_column);
defs.parents     = parents(is_column);
defs.formats     = formats(is_column);
defs.patterns    = cellfun(@(c) regexptranslate('wildcard', c), defs.columns, 'UniformOutput', false);


function [defs, messages] = add_document_definitions(defs, sbtab_document, version, messages)

for t = find_tables_of_type(sbtab_document, 'Definition')
  try
    d = read_definitions(t{1});
  catch
    continue
  end
  if isempty(d.columns) && isempty(d.table_types)
    continue
  end
  defs.table_types = [defs.table_types; d.table_types];
  defs.columns     = [defs.columns; d.columns];
  defs.parents     = [defs.parents; d.parents];
  defs.formats     = [defs.formats; d.formats];
  defs.patterns    = [defs.patterns; d.patterns];
end


function format = column_format(defs, table_type, column_name)

% format of a column for a table type ('' if the column is not defined; 'String' if no format is given)

format = '';
ind = find(strcmp(defs.parents, table_type));
for it = ind(:)'
  if ~isempty(regexp(column_name, ['^' defs.patterns{it} '$'], 'once'))
    format = defs.formats{it};
    if isempty(format), format = 'String'; end
    return
  end
end


% =====================================================================
% Helper functions

function messages = add(messages, severity, rule, table, message)

messages(end+1) = struct('severity', severity, 'rule', rule, 'table', table, 'message', message);


function s = severity(version, severity_10, severity_11)

if strcmp(version, '1.0'), s = severity_10; else, s = severity_11; end


function version = document_version(sbtab_document, default_version)

version = '';
if isfield(sbtab_document.attributes, 'SBtabVersion')
  version = sbtab_document.attributes.SBtabVersion;
else
  fn = fieldnames(sbtab_document.tables);
  if ~isempty(fn) && isfield(sbtab_document.tables.(fn{1}).attributes, 'SBtabVersion')
    version = sbtab_document.tables.(fn{1}).attributes.SBtabVersion;
  end
end
if isempty(version), version = default_version; end


function ok = is_shortname(s, mode)

switch mode
  case 'strict', ok = ~isempty(regexp(s, '^[A-Za-z][A-Za-z0-9_]*$', 'once'));
  case 'key',    ok = ~isempty(regexp(s, '^[A-Za-z][^\s:.]*$', 'once'));
end


function res = declared_from_object(declared, t)

% the attributes were taken from the table object (where a missing TableType is set to 'unknown')

res = isequal(declared, t.attributes);


function label = table_label(t)

if isfield(t.attributes, 'TableID')
  label = t.attributes.TableID;
elseif isfield(t.attributes, 'TableName')
  label = t.attributes.TableName;
else
  label = '';
end


function key = key_attribute(version)

% attribute that holds the table key (shortname)

if strcmp(version, '1.0'), key = 'TableName'; else, key = 'TableID'; end


function res = has_column(t, column_name)

res = sbtab_table_has_column(t, column_name);


function c = get_column(t, column_name)

c = sbtab_table_get_column(t, column_name, 0, 0);
if isempty(c), c = {}; end
c = c(:);


function keys = table_keys(t)

if has_column(t, 'ID')
  keys = get_column(t, 'ID');
elseif has_column(t, 'Sample')
  keys = get_column(t, 'Sample');
else
  keys = {};
end


function t = find_table(sbtab_document, table_name)

t = [];
for fn = fieldnames(sbtab_document.tables)'
  tt = sbtab_document.tables.(fn{1});
  if strcmp(table_label(tt), table_name)
    t = tt;
    return
  end
end


function tables = find_tables_of_type(sbtab_document, table_type)

tables = {};
for fn = fieldnames(sbtab_document.tables)'
  tt = sbtab_document.tables.(fn{1});
  if strcmp(tt.attributes.TableType, table_type)
    tables{end+1} = tt;
  end
end
