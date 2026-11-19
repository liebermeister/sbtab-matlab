function entry = sbtab_miriam_annotation_format(annotations, explicit)

% SBTAB_MIRIAM_ANNOTATION_FORMAT Entry of a Miriam annotation column
%
% entry = sbtab_miriam_annotation_format(annotations, explicit)
%
% annotations : cell array with one row per annotation and the columns
%               {qualifier, URN} (column !MiriamAnnotation) or
%               {qualifier, URN, orientation} (columns !ReactionMiriamAnnotation and
%               !Reaction:MiriamAnnotation; orientation: 'orientation-equal' or
%               'orientation-reversed')
% explicit    : 0 (default): orientation-equal is omitted ([qualifier, URN]); 1: it is written
% entry       : JSON list, e.g. [["bqbiol:is","urn:miriam:kegg.compound:C00001"]] or
%               [["bqbiol:is","urn:miriam:kegg.reaction:R01068","orientation-reversed"]]
%
% See also sbtab_miriam_annotation_parse.

if ~exist('explicit','var') || isempty(explicit), explicit = 0; end
if isempty(annotations), entry = ''; return; end

with_orientation = size(annotations, 2) == 3;
if with_orientation && ~all(ismember(annotations(:, 3), {'orientation-equal', 'orientation-reversed'}))
  error('Invalid reaction orientation (allowed: orientation-equal, orientation-reversed)');
end

elements = cell(1, size(annotations, 1));
for it = 1:size(annotations, 1)
  a = annotations(it, :);
  if with_orientation && (explicit || ~strcmp(a{3}, 'orientation-equal'))
    elements{it} = sprintf('["%s","%s","%s"]', a{:});
  elseif with_orientation
    elements{it} = sprintf('["%s","%s"]', a{1:2});
  else
    elements{it} = sprintf('["%s","%s"]', a{:});
  end
end
entry = ['[' strjoin(elements, ',') ']'];
