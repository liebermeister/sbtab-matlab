function entries = sbtab_reaction_identifiers_format(ids, orientations, explicit)

% SBTAB_REACTION_IDENTIFIERS_FORMAT Entries of reaction identifier columns
%
% entries = sbtab_reaction_identifiers_format(ids, orientations, explicit)
%
% Entries of the columns !ReactionIdentifiers:<DataCollection> (Reaction tables) and
% !Reaction:Identifiers:<DataCollection> (Quantity and QuantityMatrix tables).
%
% ids          : database ID (string), or cell array of IDs
% orientations : 'orientation-equal' (default) or 'orientation-reversed' (string, or cell array
%                of the size of ids); numbers are also accepted: +1 (equal), -1 (reversed),
%                NaN (unknown)
% explicit     : 0 (default): orientation-equal is written as the plain ID;
%                1: also as a JSON string ["R00771","orientation-equal"]
% entries      : plain IDs (orientation-equal) or JSON strings like ["R01068","orientation-reversed"];
%                '' for empty IDs. An unknown orientation ('' or NaN) cannot be expressed: the
%                plain ID is written (which is read as orientation-equal)
%
% Example: sbtab_reaction_identifiers_format({'R00771','R01068'}, [1, -1])
%          gives {'R00771', '["R01068","orientation-reversed"]'}
%
% See also sbtab_reaction_identifiers_parse.

if ~exist('orientations','var') || isempty(orientations), orientations = 'orientation-equal'; end
if ~exist('explicit','var') || isempty(explicit), explicit = 0; end

if ischar(ids)
  entries = format_one(ids, orientations, explicit);
  return
end

if ischar(orientations), orientations = repmat({orientations}, size(ids)); end
if isnumeric(orientations), orientations = num2cell(orientations); end
entries = repmat({''}, size(ids));
for it = 1:numel(ids)
  entries{it} = format_one(ids{it}, orientations{it}, explicit);
end


function entry = format_one(id, orientation, explicit)

if isnumeric(orientation)
  if isempty(orientation) || ~isfinite(orientation) || orientation == 0, orientation = '';
  elseif orientation > 0, orientation = 'orientation-equal';
  else,                   orientation = 'orientation-reversed';
  end
end
if isempty(id)
  entry = '';
elseif isempty(orientation) || (strcmp(orientation, 'orientation-equal') && ~explicit)
  entry = id;
elseif ismember(orientation, {'orientation-equal', 'orientation-reversed'})
  entry = sprintf('["%s","%s"]', id, orientation);
else
  error('Invalid reaction orientation ''%s'' (allowed: orientation-equal, orientation-reversed)', orientation);
end
