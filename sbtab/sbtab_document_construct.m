function my_sbtab_document = sbtab_document_construct(attributes,table_names,tables)

% my_sbtab_document = sbtab_document_construct(attributes,table_names,tables)

my_sbtab_document.attributes = attributes; 
my_sbtab_document.tables     = struct;

if exist('table_names','var'),
 for it = 1:length(table_names),
    my_sbtab_document = sbtab_document_add_table(my_sbtab_document,table_names{it},tables{it});
 end
end