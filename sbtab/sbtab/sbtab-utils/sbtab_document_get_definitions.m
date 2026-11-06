function definitions = sbtab_document_get_definitions(sbtab_document, version)

% SBTAB_DOCUMENT_GET_DEFINITIONS Definitions table used for an SBtab document object
%
% definitions = sbtab_document_get_definitions(sbtab_document, version)
%
% version: SBtab version of the default definitions table (default: the version of the
%          document, see sbtab_document_version)
% definitions: the default definitions table of the version, extended or replaced by the
%          extra definitions of the document (see sbtab_document_set_definitions), and
%          extended by the Definition tables contained in the document
%
% See also sbtab_document_set_definitions, sbtab_definitions

if ~exist('version','var') || isempty(version)
  version = sbtab_document_version(sbtab_document);
end

extra = {};
mode = 'extend';
if isfield(sbtab_document, 'definitions')
  extra = sbtab_document.definitions.extra;
  mode  = sbtab_document.definitions.mode;
end
definitions = sbtab_definitions(version, extra, mode);

% Definition tables contained in the document
inner = {};
ids = fieldnames(sbtab_document.tables);
for it = 1:length(ids)
  t = sbtab_document.tables.(ids{it});
  if isfield(t.attributes, 'TableType') && strcmp(t.attributes.TableType, 'Definition')
    inner{end+1} = t;
  end
end
if ~isempty(inner)
  definitions = sbtab_definitions_merge(definitions, inner{:});
end
