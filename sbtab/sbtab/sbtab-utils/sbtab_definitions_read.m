function tables = sbtab_definitions_read(extra)

% SBTAB_DEFINITIONS_READ Extra definitions as a cell array of definitions table objects
%
% tables = sbtab_definitions_read(extra)
%
% extra: a definitions table (SBtab table object), the name of a file containing
%        definitions tables, an SBtab document object, or a cell array of these;
%        of files and documents, all tables of type Definition are used
% tables: cell array of SBtab table objects (empty if extra is empty)
%
% See also sbtab_definitions, sbtab_document_set_definitions

tables = {};
if isempty(extra), return; end
if iscell(extra)
  for it = 1:length(extra)
    tables = [tables, sbtab_definitions_read(extra{it})];
  end
  return
end
if ischar(extra) || isstring(extra)
  filename = char(extra);
  if ~exist(filename, 'file')
    error('Definitions file %s not found', filename);
  end
  extra = sbtab_document_load(filename);
end
if isfield(extra, 'tables')
  % document object: its Definition tables
  ids = fieldnames(extra.tables);
  for it = 1:length(ids)
    t = extra.tables.(ids{it});
    if isfield(t.attributes, 'TableType') && strcmp(t.attributes.TableType, 'Definition')
      tables{end+1} = t;
    end
  end
  if isempty(tables)
    error('The definitions file or document contains no Definition table');
  end
else
  tables = {extra};
end
