function definitions = sbtab_definitions(version, extra, mode)

% SBTAB_DEFINITIONS Definitions table of an SBtab version, optionally extended or replaced
%
% definitions = sbtab_definitions(version)
% definitions = sbtab_definitions(version, extra, mode)
%
% version: '1.0' (default), '1.1', '1.2' or 'tools'
% extra:   extra definitions: a definitions table (SBtab table object), the name of a file
%          containing definitions tables (all tables of type Definition are used), an SBtab
%          document object (its Definition tables are used), or a cell array of these
%          (see sbtab_definitions_read). A tool can come with a small definitions table that
%          contains only its own table types, columns and attributes.
% mode:    'extend' (default): the extra definitions are added to the definitions table of
%          the version (rows with the same Name and Parent replace its rows; see
%          sbtab_definitions_merge); 'replace': the extra definitions are used instead
% definitions: SBtab table object (table type 'Definition') listing the table types,
%              their columns and the table attributes, with their formats
%
% The tables are stored in [sbtab_resourcedir]/definitions (the same files as in sbtabpy):
%  definitions_0.9.1_published.tsv SBtab 1.0: the definitions table offered on www.sbtab.net
%                                  (it declares SBtabVersion='0.9.1')
%  definitions_1.1.tsv             derived from the appendix of the SBtab 1.1 specification
%  definitions_1.2.tsv             derived from the appendix of the SBtab 1.2 specification (draft)
%  definitions_tool_types.tsv      table types read by the SBtab tools, but not defined in the
%                                  SBtab specifications (version 'tools')
%
% See also sbtab_definitions_merge, sbtab_document_set_definitions

if ~exist('version','var') || isempty(version), version = '1.0'; end
if ~exist('extra','var'), extra = []; end
if ~exist('mode','var') || isempty(mode), mode = 'extend'; end
if ~ismember(mode, {'extend', 'replace'})
  error('Unknown definitions mode %s (use ''extend'' or ''replace'')', mode);
end

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

extra = sbtab_definitions_read(extra);
if isempty(extra), return; end
switch mode
  case 'extend',  definitions = sbtab_definitions_merge(definitions, extra{:});
  case 'replace', definitions = sbtab_definitions_merge(extra{:});
end
