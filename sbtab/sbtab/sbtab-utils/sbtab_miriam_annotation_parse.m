function [annotations, ok] = sbtab_miriam_annotation_parse(entry, with_orientation)

% SBTAB_MIRIAM_ANNOTATION_PARSE Parse an entry of a Miriam annotation column
%
% [annotations, ok] = sbtab_miriam_annotation_parse(entry, with_orientation)
%
% entry            : JSON string
% with_orientation : 0 (default): column !MiriamAnnotation;
%                    1: columns !ReactionMiriamAnnotation (Reaction tables) and
%                       !Reaction:MiriamAnnotation (Quantity and QuantityMatrix tables)
% annotations      : cell array with one row per annotation and the columns
%                    {qualifier, URN} or {qualifier, URN, orientation}
% ok               : false if the entry is malformed (annotations is then empty)
%
% Entries are JSON lists (the same form in SBtab 1.1 and 1.2):
%   !MiriamAnnotation          [["bqbiol:is","urn:miriam:kegg.compound:C00001"], ...]
%   !ReactionMiriamAnnotation  [["bqbiol:is","urn:miriam:kegg.reaction:R01068","orientation-reversed"], ...]
% An empty qualifier "" means 'unknown'. The orientation is 'orientation-equal' or
% 'orientation-reversed' (reaction orientation relative to the database reaction); for
% orientation-equal, it may be omitted ([qualifier, URN]).
% Strings in single quotes are also accepted.
%
% See also sbtab_miriam_annotation_format, sbtab_reaction_identifiers_parse.

if ~exist('with_orientation','var') || isempty(with_orientation), with_orientation = 0; end

n_columns = 2 + double(logical(with_orientation));
annotations = cell(0, n_columns);
ok = true;
if ~ischar(entry), entry = ''; end
entry = strtrim(entry);
if isempty(entry), return; end

s   = '(["''])([^"'']*)\1';       % JSON string (tokens: quote, content)
sep = '\s*,\s*';
pair   = ['^\[\s*' s sep '(["''])([^"'']*)\3\s*\]$'];
triple = ['^\[\s*' s sep '(["''])([^"'']*)\3' sep '(["''])([^"'']*)\5\s*\]$'];

body = regexp(entry, '^\[\s*(.*?)\s*\]$', 'tokens', 'once');
if isempty(body), ok = false; return; end
body = body{1};
if isempty(body), return; end

% the body must consist of elements [...] separated by commas
[elements, rest] = regexp(body, '\[[^\[\]]*\]', 'match', 'split');
if isempty(elements) || ~isempty(strtrim(rest{1})) || ~isempty(strtrim(rest{end})) || ...
   any(cellfun(@(x) isempty(regexp(x, '^\s*,\s*$', 'once')), rest(2:end-1)))
  ok = false;
  return
end

annotations = cell(length(elements), n_columns);
for it = 1:length(elements)
  t = regexp(elements{it}, pair, 'tokens', 'once');
  if ~isempty(t)
    values = t([2 4]);
    if with_orientation, values{3} = 'orientation-equal'; end   % orientation omitted
  elseif with_orientation
    t = regexp(elements{it}, triple, 'tokens', 'once');
    if isempty(t), annotations = cell(0, n_columns); ok = false; return; end
    values = t([2 4 6]);
  else
    annotations = cell(0, n_columns); ok = false; return
  end
  annotations(it, :) = values;
end
annotations(cellfun('isempty', annotations)) = {''};   % empty tokens (1x0 char) as ''

if with_orientation && ~all(ismember(annotations(:, 3), {'orientation-equal', 'orientation-reversed'}))
  annotations = cell(0, n_columns);
  ok = false;
end
