function my_sbtab_document = sbtab_document_load_from_one(filename)

% SBTAB_DOCUMENT_LOAD_FROM_ONE % Load SBtab document (possibly, several tables) from one file
%
% my_sbtab_document = sbtab_document_load_from_one(filename)
%
% Note that table names must be provided as table attributes

my_sbtab_document = sbtab_document_construct;

flag_remove_comment_lines = 1;

try 
  my_table = load_unformatted_table(filename);
catch
  error(sprintf('Problem in import of file %s If you use non-".tsv" files, you need to specify this!',  filename))
end

split_lines = [find(cellfun('length',strfind(my_table,'!!'))); length(my_table)+1];

my_tables = {};

for it = 1:length(split_lines)-1,
  my_tables{it} = my_table(split_lines(it):split_lines(it+1)-1,:);
  % remove empty columns
  my_tables{it} = my_tables{it}(:,find(sum(cellfun('length',my_tables{it}))));
  if flag_remove_comment_lines,
    dum = char(my_tables{it}(:,1));
    keep = find(strcmp(cellstr(dum(:,1)),'%')==0);
    my_tables{it} = my_tables{it}(keep,:);
  end
end

for it = 1:length(my_tables),
  my_sbtab_table = sbtab_table_load([],my_tables{it});
  if ~isfield(my_sbtab_table.attributes,'TableName'),
    error('Attribute TableName is missing in input file');
  end
  table_names{it} = strrep(my_sbtab_table.attributes.TableName,' ','');
  my_sbtab_document.table_names{it} = my_sbtab_table.attributes.TableName;
  my_sbtab_document.tables = setfield(my_sbtab_document.tables, table_names{it}, my_sbtab_table);
end
