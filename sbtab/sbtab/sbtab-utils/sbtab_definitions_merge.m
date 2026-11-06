function definitions = sbtab_definitions_merge(definitions, varargin)

% SBTAB_DEFINITIONS_MERGE Extend a definitions table by the rows of other definitions tables
%
% definitions = sbtab_definitions_merge(definitions, extension1, extension2, ...)
%
% definitions: definitions table (SBtab table object), e.g. sbtab_definitions('1.1')
% extension1, ...: definitions tables (SBtab table objects) with additional table types,
%                  columns or attributes, e.g. the small definitions table of a tool
%
% A row of an extension with the same Name and Parent as a row of the definitions table
% replaces that row (its empty fields are taken from the original row); all other rows are
% appended. The result has the columns of the first table. The tables can have the SBtab 1.0
% layout (ComponentName, ComponentType, IsPartOf) or the 1.1 layout (Name, Type, Parent).
%
% See also sbtab_definitions, sbtab_document_set_definitions

names   = definitions.column.column_names;
columns = cellfun(@(c) as_strings(sbtab_table_get_column(definitions, c)), names, 'UniformOutput', false);
n_rows  = length(columns{1});
i_name   = find_column(names, 'Name');
i_parent = find_column(names, 'Parent');
if isempty(i_name) || isempty(i_parent)
  error('The definitions table has no columns Name and Parent (or ComponentName and IsPartOf)');
end
keys = strcat(columns{i_name}, '|', columns{i_parent});

for k = 1:length(varargin)
  ext = varargin{k};
  ext_names = ext.column.column_names;
  ext_columns = cell(size(names));
  ext_rows = 0;
  for it = 1:length(names)
    j = find_column(ext_names, names{it});
    if ~isempty(j)
      ext_columns{it} = as_strings(sbtab_table_get_column(ext, ext_names{j}));
      ext_rows = length(ext_columns{it});
    end
  end
  for it = 1:length(names)
    if isempty(ext_columns{it}), ext_columns{it} = repmat({''}, ext_rows, 1); end
  end
  for r = 1:ext_rows
    name = ext_columns{i_name}{r};
    if isempty(name), continue; end
    key = [name '|' ext_columns{i_parent}{r}];
    ind = find(strcmp(keys, key), 1);
    if isempty(ind)
      n_rows = n_rows + 1;
      keys{n_rows, 1} = key;
      for it = 1:length(names)
        columns{it}{n_rows, 1} = ext_columns{it}{r};
      end
    else
      for it = 1:length(names)
        if ~isempty(ext_columns{it}{r})
          columns{it}{ind} = ext_columns{it}{r};
        end
      end
    end
  end
end

definitions = sbtab_table_construct(definitions.attributes, names, columns);


% -----------------------------------------------------

function c = as_strings(c)

if isnumeric(c)
  c = arrayfun(@num2str, c, 'UniformOutput', false);
end
c = c(:);
c(cellfun(@(x) ~ischar(x), c)) = {''};


function j = find_column(names, name)

% column of a definitions table, also under its name in the other layout (1.0 or 1.1)

synonyms = {'Name', 'ComponentName'; 'Type', 'ComponentType'; 'Parent', 'IsPartOf'};
clean = sbtab_clean_column_headers(names);
name  = sbtab_clean_column_headers(name);
candidates = {name};
[row, ~] = find(strcmp(synonyms, name));
if ~isempty(row), candidates = synonyms(row(1), :); end
j = [];
for c = candidates
  j = find(strcmp(clean, c{1}), 1);
  if ~isempty(j), return; end
end
