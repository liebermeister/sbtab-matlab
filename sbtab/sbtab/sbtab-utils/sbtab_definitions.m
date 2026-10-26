function definitions = sbtab_definitions(version)

% SBTAB_DEFINITIONS Definitions table of an SBtab version
%
% definitions = sbtab_definitions(version)
%
% version: '1.0' (default) or '1.1'
% definitions: SBtab table object (table type 'Definition') listing the predefined table types,
%              their columns and the table attributes, with their formats
%
% The tables are stored in [sbtab_resourcedir]/definitions:
%  definitions_1.0.tsv           derived from the appendix of the SBtab 1.0 specification,
%                                plus columns used in the examples of the specification
%  definitions_1.0_published.tsv as published with the 1.0 specification on www.sbtab.net
%  definitions_1.1.tsv           derived from the appendix of the SBtab 1.1 specification

if ~exist('version','var') || isempty(version), version = '1.0'; end

persistent cache
if isempty(cache), cache = struct; end

key = ['v' regexprep(version, '[^A-Za-z0-9]', '_')];
if ~isfield(cache, key)
  filename = fullfile(sbtab_resourcedir, 'definitions', ['definitions_' version '.tsv']);
  if ~exist(filename, 'file')
    error('No definitions table for SBtab version %s (file %s not found)', version, filename);
  end
  cache.(key) = sbtab_table_load(filename);
end
definitions = cache.(key);
