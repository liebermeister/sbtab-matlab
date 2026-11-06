function definitions = sbtab_definitions(version)

% SBTAB_DEFINITIONS Definitions table of an SBtab version
%
% definitions = sbtab_definitions(version)
%
% version: '1.0' (default), '1.1' or '1.2'
% definitions: SBtab table object (table type 'Definition') listing the predefined table types,
%              their columns and the table attributes, with their formats
%
% The tables are stored in [sbtab_resourcedir]/definitions (the same files as in sbtabpy):
%  definitions_0.9.1_published.tsv SBtab 1.0: the definitions table offered on www.sbtab.net
%                                  (it declares SBtabVersion='0.9.1')
%  definitions_1.1.tsv             derived from the appendix of the SBtab 1.1 specification
%  definitions_1.2.tsv             derived from the appendix of the SBtab 1.2 specification (draft)
%  definitions_tool_types.tsv      table types read by the SBtab tools, but not defined in the
%                                  SBtab specifications (version 'tools')

if ~exist('version','var') || isempty(version), version = '1.0'; end

persistent cache
if isempty(cache), cache = struct; end

key = ['v' regexprep(version, '[^A-Za-z0-9]', '_')];
if ~isfield(cache, key)
  switch version
    case '1.0',   name = 'definitions_0.9.1_published.tsv';
    case 'tools', name = 'definitions_tool_types.tsv';
    otherwise,    name = ['definitions_' version '.tsv'];
  end
  filename = fullfile(sbtab_resourcedir, 'definitions', name);
  if ~exist(filename, 'file')
    error('No definitions table for SBtab version %s (file %s not found)', version, filename);
  end
  cache.(key) = sbtab_table_load(filename);
end
definitions = cache.(key);
