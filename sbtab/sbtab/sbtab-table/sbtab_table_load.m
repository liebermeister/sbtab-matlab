function sbtab = sbtab_table_load(filename, my_table, flag_remove_comments, table_id)

% SBTAB_TABLE_LOAD Load SBtab table from file, or generate it from a list of strings
%
% sbtab = sbtab_table_load(filename, my_table, flag_remove_comments, table_id)
%
% Either load SBtab table from file (with filename [filename])
%        (if table_id is given (non-empty), use this table; otherwise, then use the first table);
% or     (if argument [my_table] is given)
%        load SBtab table from string cell array [my_table]

eval(default('my_table', '[]', 'flag_remove_comments', '0','table_id','[]'));

if isempty(my_table)
  try
    my_table = sbtab_load_text_table(filename);
    my_table = remove_comment_lines(my_table);
  catch err
    if isstr(filename)
      error(sprintf('I could not import the file %s (%s)',  filename, err.message))
    else
      error(sprintf('I could not import the file'))
    end
  end
end

if ~isempty(table_id)
  sbtab_doc = sbtab_document_load(filename);
  sbtab = sbtab_document_get_table(sbtab_doc,table_id);
  return
end

if strncmp('!!!',my_table{1,1},3)
  my_table = my_table(2:end,:);
end

ind_declarations = find(strncmp(my_table(:,1),'!!',2));
if length(ind_declarations)>1
  warning('Input file %s contains several tables; only the first one is loaded. To load another table, please specify its table ID (or use sbtab_document_load)', filename_string(filename));
  my_table = my_table(1:ind_declarations(2)-1,:);
end

attribute_line = {};
cont = 1;
while cont * length(my_table)
  if strncmp('!!',my_table{1,1},2)
    attribute_line = my_table(1,:);
    cont = 0;
  end
  my_table       = my_table(2:end,:);
end

if isempty(my_table)
  error(sprintf('No declaration line (starting with !!SBtab) found in file %s',filename_string(filename)));
end

% -------------------------------------------------------
% Attributes

attributes = sbtab_parse_attributes(attribute_line);

if ~isfield(attributes,'TableType')
  warning('Table type missing in file %s', filename_string(filename));
  attributes.TableType = 'unknown';
end

% The table ID (used to identify the table in an SBtab document) is the attribute TableID
% (in SBtab files before version 1.0) or, otherwise, the attribute TableName

if ~isfield(attributes,'TableID')
  if isfield(attributes,'TableName') && ~isempty(attributes.TableName)
    attributes.TableID = attributes.TableName;
  else
    warning('Table name missing in file %s (table type %s)', filename_string(filename), attributes.TableType);
    attributes.TableID = attributes.TableType;
  end
end

% -------------------------------------------------------
% If desired transpose the table

if isfield(attributes,'TableOrientation')
  switch attributes.TableOrientation
    case 'Transposed'
      my_table =  my_table';
  end
end

% -------------------------------------------------------
% Table columns

% omit empty columns

my_table = my_table(:, ~all(cellfun('isempty',my_table),1));

% detect empty column header
ind_no_header = find(cellfun('isempty',my_table(1,:)));
if length(ind_no_header)
  warning('Column header missing in file %s; the column(s) without header are ignored', filename_string(filename));
  my_table = my_table(:,setdiff(1:size(my_table,2),ind_no_header));
end

rows = struct;
ind_data = [];
while size(my_table,1)>1 && strncmp('!',my_table{2,1},1)
  row_header = my_table{2,1}(2:end);
  row_rest   = [{[]},my_table(2,2:end)];
  ind_data   = [ind_data, find(cellfun('length',row_rest))];
  my_table   = my_table([1,3:end],:);
  rows       = setfield(rows,row_header,row_rest);
end

ind_rows   = setdiff(unique(ind_data),1);
column     = struct;
ind_column = [];
column_names = {};

for it = 1:size(my_table,2)
  column_header = my_table{1,it};
  if strcmp('!',column_header(1))
    column_header = column_header(2:end);
    column_names{it,1} = column_header;
    if strfind(column_header,'ID')  % compatibility to older SBtab files
      column_header = strrep(column_header,'MiriamID::urn:miriam:','Identifiers:');
      column_header = strrep(column_header,'SBML::reaction::ID','SBML:reaction:ID');
      column_header = strrep(column_header,'SBML::species::ID','SBML:species:ID');
    end
    column_header = sbtab_clean_column_headers(column_header);
    ind_column = [ind_column it];
    column = setfield(column,column_header,my_table(2:end,it));
  end
end

ind_data         = setdiff(ind_rows,ind_column);
data_headers     = my_table(1,ind_data);
data             = my_table(2:end,ind_data);

ind_uncontrolled = setdiff(1:size(my_table,2),[ind_column,ind_data]);
if length(ind_uncontrolled)
  uncontrolled_headers = my_table(1,ind_uncontrolled);
  uncontrolled         = my_table(2:end,ind_uncontrolled);
else
  uncontrolled_headers = [];
  uncontrolled         = [];
  ind_uncontrolled = [];
end

fn = fieldnames(rows);

data_attributes   = [];
column_attributes = [];

for it = 1:length(fn);
  data_attributes.(fn{it})   = rows.(fn{it})(ind_data);
  column_attributes.(fn{it}) = rows.(fn{it})(ind_column);
end


% -------------------------------------------------------
% Generate SBtab struct

sbtab.filename          = filename;
sbtab.attributes        = attributes;
sbtab.rows              = rows;
sbtab.column.column     = column;
sbtab.column.column_names = column_names;
sbtab.column.attributes = column_attributes;
sbtab.column.ind        = ind_column;
sbtab.data.headers      = data_headers;
sbtab.data.attributes   = data_attributes;
sbtab.data.data         = data;
sbtab.data.ind          = ind_data;
sbtab.uncontrolled.headers = uncontrolled_headers;
sbtab.uncontrolled.data = uncontrolled;
sbtab.uncontrolled.ind  = ind_uncontrolled;

if flag_remove_comments
  sbtab = sbtab_table_remove_comment_lines(sbtab);
end


% -----------------------------------------------------

function s = filename_string(filename)

if ischar(filename)
  s = filename;
else
  s = '';
end

% -----------------------------------------------------

function my_table = remove_comment_lines(my_table)

  my_table = my_table(~strncmp(my_table(:,1),'%',1),:);
