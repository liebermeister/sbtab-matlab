function v = sbtab_document_version(sbtab_document, v)

% SBTAB_DOCUMENT_VERSION SBtab version in which an SBtab document is written
%
% v = sbtab_document_version(sbtab_document, v)
%
% v (input): requested version ('1.0', '1.1' or '1.2'), or [] for the default version:
%            '1.1', or '1.2' if the document contains table types that exist only
%            in SBtab 1.2 (see 'sbtab_required_version')
% A warning is issued if the requested version is lower than the required version 1.2.

eval(default('v','[]'));

fn = fieldnames(sbtab_document.tables);
table_types = {};
for it = 1:length(fn)
  a = sbtab_document.tables.(fn{it}).attributes;
  if isfield(a, 'TableType'), table_types{end+1} = a.TableType; end
end
required = sbtab_required_version(table_types);

if isempty(v)
  v = required;
else
  v = sbtab_check_version(v);
  if strcmp(required, '1.2') && ~strcmp(v, '1.2')
    warning('The document contains table types that exist only in SBtab 1.2, but is written as SBtab %s', v);
  end
end
