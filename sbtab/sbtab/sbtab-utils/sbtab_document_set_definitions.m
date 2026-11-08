function sbtab_document = sbtab_document_set_definitions(sbtab_document, extra, mode)

% SBTAB_DOCUMENT_SET_DEFINITIONS Set extra definitions tables for an SBtab document object
%
% sbtab_document = sbtab_document_set_definitions(sbtab_document, extra, mode)
%
% extra: extra definitions (definitions table object, file name, document object, or a cell
%        array of these; see sbtab_definitions_read); [] removes the extra definitions.
%        A tool can come with a small definitions table that contains only its own table
%        types, columns and attributes.
% mode:  'extend' (default): the extra definitions extend the definitions table of the
%        document's SBtab version; 'replace': they are used instead of it
%
% The definitions are stored in sbtab_document.definitions (fields 'extra': cell array of
% definitions tables, read when this function is called; 'mode') and used by
% sbtab_document_validate and sbtab_document_get_definitions. Definition tables contained
% in the document extend the definitions in both modes.
%
% Example:
%   d = sbtab_document_load('my_model.tsv');
%   d = sbtab_document_set_definitions(d, 'ecm_definition.tsv');
%   messages = sbtab_document_validate(d);
%
% See also sbtab_document_get_definitions, sbtab_definitions

if ~exist('extra','var'), extra = []; end
if ~exist('mode','var') || isempty(mode), mode = 'extend'; end
if ~ismember(mode, {'extend', 'replace'})
  error('Unknown definitions mode %s (use ''extend'' or ''replace'')', mode);
end

if isempty(extra)
  if isfield(sbtab_document, 'definitions')
    sbtab_document = rmfield(sbtab_document, 'definitions');
  end
  return
end

sbtab_document.definitions = struct('extra', {sbtab_definitions_read(extra)}, 'mode', mode);
