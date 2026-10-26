function sbo = sbtab_parse_sbo_header(column_name)

% SBTAB_PARSE_SBO_HEADER Parse a column header of the form !SBO:<quantity> [<unit>:<Scale>]:<ValueType>
%
% sbo = sbtab_parse_sbo_header(column_name)
%
% column_name: column header (with or without leading '!'), e.g.
%   '!SBO:equilibrium constant', '!SBO:concentration [mM]', '!SBO:concentration:Median',
%   '!SBO:concentration [mM:Log10]:Median'
%
% sbo: struct with fields QuantityType, Unit, Scale, ValueType (empty strings if not given;
%      ValueType 'Value' if not given), or [] if the header has not this form (e.g. the
%      annotation column '!SBO:Identifiers:obo.sbo')
%
% Such a column contains the values of one quantity type (quantity name as in the Systems
% Biology Ontology); see 'sbtab_table_get_column' for the columns it stands for.

sbo = [];
if ~ischar(column_name), return; end
column_name = regexprep(strtrim(column_name), '^!', '');
if ~strncmp(column_name, 'SBO:', 4) || strncmp(column_name, 'SBO:Identifiers', 15)
  return
end
rest = column_name(5:end);

% value type ':<ValueType>' at the end
value_type = 'Value';
t = regexp(rest, '^(.*):([A-Za-z]\w*)$', 'tokens', 'once');
if ~isempty(t) && isempty(strfind(t{2}, ']'))
  [rest, value_type] = deal(t{1}, t{2});
end

% unit and scale in square brackets: ' [<unit>]' or ' [<unit>:<Scale>]'
[unit, scale] = deal('');
t = regexp(rest, '^(.*?)\s*\[([^\[\]]*)\]$', 'tokens', 'once');
if ~isempty(t)
  rest = t{1};
  u = regexp(t{2}, '^([^:]*)(.*)$', 'tokens', 'once');
  unit  = strtrim(u{1});
  scale = strtrim(regexprep(u{2}, '^:', ''));
end

% quantity name: no square brackets or ':'
if isempty(regexp(rest, '^[^\[\]:]*[^\[\]:\s]$', 'once'))
  return
end
sbo = struct('QuantityType', rest, 'Unit', unit, 'Scale', scale, 'ValueType', value_type);
