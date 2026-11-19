function [ids, orientations, ok, signs] = sbtab_reaction_identifiers_parse(entries)

% SBTAB_REACTION_IDENTIFIERS_PARSE Parse entries of reaction identifier columns
%
% [ids, orientations, ok, signs] = sbtab_reaction_identifiers_parse(entries)
%
% In SBtab 1.1 and 1.2, reactions are annotated, together with their orientation, in columns
% !ReactionIdentifiers:<DataCollection> (Reaction tables) and !Reaction:Identifiers:<DataCollection>
% (Quantity and QuantityMatrix tables), e.g. !ReactionIdentifiers:kegg.reaction. The orientation
% is 'orientation-equal' (the reaction in the table has the same orientation as the database
% reaction) or 'orientation-reversed' (opposite orientation). An entry is the plain database ID
% (orientation-equal; the default form) or a JSON string with the ID and the orientation:
%   R00771    ["R01068","orientation-reversed"]    ["R00771","orientation-equal"]
% A reversed orientation must be written as a JSON string. Data in the table always refer to the
% orientation used in the SBtab file.
%
% entries      : string, or cell array of strings (e.g. a table column)
% ids          : database IDs (string, or cell array of the size of entries)
% orientations : 'orientation-equal' (also for plain IDs), 'orientation-reversed', or '' (empty
%                entry or 'nan', or malformed entry)
% ok           : false for malformed entries (no JSON list of two strings, or an invalid
%                orientation); their ID and orientation are ''. Empty entries and plain IDs are ok.
% signs        : +1 (orientation-equal), -1 (orientation-reversed), NaN (no entry)
%
% Strings in single quotes ('R01068') are also accepted.
%
% See also sbtab_reaction_identifiers_format, sbtab_miriam_annotation_parse.

if ischar(entries)
  [ids, orientations, ok] = parse_one(entries);
  signs = orientation_sign(orientations);
  return
end

ids          = repmat({''}, size(entries));
orientations = repmat({''}, size(entries));
ok           = true(size(entries));
signs        = nan(size(entries));
for it = 1:numel(entries)
  [ids{it}, orientations{it}, ok(it)] = parse_one(entries{it});
  signs(it) = orientation_sign(orientations{it});
end


function [id, orientation, ok] = parse_one(entry)

id = ''; orientation = ''; ok = true;
if ~ischar(entry), entry = ''; end
entry = strtrim(entry);
if isempty(entry) || strcmpi(entry, 'nan'), return; end   % 'nan': no entry
if ~any(entry(1) == '[{')
  id = entry;                      % plain ID: orientation-equal
  orientation = 'orientation-equal';
  return
end
tokens = regexp(entry, '^\[\s*(["''])([^"'']*)\1\s*,\s*(["''])([^"'']*)\3\s*\]$', 'tokens', 'once');
if isempty(tokens) || ~ismember(tokens{4}, {'orientation-equal', 'orientation-reversed'})
  ok = false;
  return
end
id          = tokens{2};
if isempty(id), id = ''; end
orientation = tokens{4};


function s = orientation_sign(orientation)

switch orientation
  case 'orientation-equal',    s = 1;
  case 'orientation-reversed', s = -1;
  otherwise,                   s = nan;
end
