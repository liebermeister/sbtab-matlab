function my_sbtab_document = sbtab_document_load_from_one(filename)

% SBTAB_DOCUMENT_LOAD_FROM_ONE Load SBtab document (possibly, several tables) from one file
%
% my_sbtab_document = sbtab_document_load_from_one(filename)
%
% the argument 'filename' can be of the following types:
%  string                -> single file
%  string cell array     -> several files, to be concatenated
%  sbtab object (struct) -> the function simply returns the function argument

if isstruct(filename)
  my_sbtab_document = filename;
  return
end

if iscell(filename)
  my_sbtab_document = sbtab_document_load_from_one(filename{1});
  for it = 2:length(filename)
    my_sbtab_document = sbtab_document_combine(my_sbtab_document, sbtab_document_load_from_one(filename{it}));
  end
  return
end

my_sbtab_document = sbtab_document_construct;

flag_remove_comment_lines = 1;

my_table  = sbtab_load_text_table(filename);

if flag_remove_comment_lines
  my_table = remove_comment_lines(my_table);
end

attribute_line_number = find(strncmp(my_table(:,1),'!!!',3));

split_lines = [find(strncmp(my_table(:,1),'!!',2)); size(my_table,1)+1];
split_lines = setdiff(split_lines,attribute_line_number);

% ---------------------------------------------

attributes = struct;
if length(attribute_line_number)
  if length(attribute_line_number)>1
    warning('File %s contains several document lines (!!!SBtab); only the first one is used', filename);
  end
  attributes = sbtab_parse_attributes(my_table(attribute_line_number(1),:));
end

my_sbtab_document.attributes = attributes;

% --------------------------------------

my_tables = {};

for it = 1:length(split_lines)-1
  my_tables{it} = my_table(split_lines(it):split_lines(it+1)-1,:);
  % remove empty columns
  my_tables{it} = my_tables{it}(:,find(sum(cellfun('length',my_tables{it}))));
end

for it = 1:length(my_tables)
  % (sbtab_table_load sets a missing TableID to the TableName, or else to the TableType)
  my_sbtab_table = sbtab_table_load(filename,my_tables{it});
  table_id = sbtab_clean_table_id(my_sbtab_table.attributes.TableID);
  if isempty(table_id) || ~isletter(table_id(1))
    table_id = ['Table_' table_id];
  end
  if isfield(my_sbtab_document.tables, table_id)
    new_table_id = table_id;
    n = 2;
    while isfield(my_sbtab_document.tables, new_table_id)
      new_table_id = sprintf('%s_%d', table_id, n);
      n = n + 1;
    end
    warning('Non-unique table ID %s in file %s; the table is stored as %s', my_sbtab_table.attributes.TableID, filename, new_table_id);
    my_sbtab_table.attributes.TableID = new_table_id;
    table_id = new_table_id;
  end
  my_sbtab_document.table_names{it,1} = my_sbtab_table.attributes.TableID;
  my_sbtab_document.tables.(table_id) = my_sbtab_table;
end

% -----------------------------------------------------

function my_table = remove_comment_lines(my_table)

  my_table = my_table(~strncmp(my_table(:,1),'%',1),:);
