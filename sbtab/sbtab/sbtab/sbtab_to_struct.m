function my_struct = sbtab_to_struct(my_sbtab_object,structure)

% SBTAB_TO_STRUCT Convert an SBtab document or table into a matlab struct
%
% my_struct = sbtab_to_struct(my_sbtab_object)
%
% Construct a matlab struct from an SBtab table; ignore uncontrolled columns
%
% argument 'structure':
%  'table': SBtab tables appear as a table (cell array)
%  'column': SBtab table is broken into columns (cell arrays)
%  'row': SBtab table is broken into rows (elements) with "dict" structure
%
% Usage example: 
%
% filename = [ sbtab_basedir '/demo/data/sbtab_omics_row_example_document.tsv'];
% s = sbtab_document_load(filename);
% t = sbtab_to_struct(s);

eval(default('structure','''table'''));
  
switch sbtab_object_type(my_sbtab_object),
  
  case 'document',

    my_struct.DOCUMENT_ATTRIBUTES = my_sbtab_object.attributes;
    fn = fieldnames(my_sbtab_object.tables);
    for it = 1:length(fn),
      my_struct.(fn{it}) = sbtab_to_struct(my_sbtab_object.tables.(fn{it}),structure);
    end
  
  case 'table',
    
    my_struct.TABLE_ATTRIBUTES = my_sbtab_object.attributes;
    switch structure,
      
      case 'column',
        my_struct = my_sbtab_object.column.column;
      
      case 'row',
        my_IDs = my_sbtab_object.column.column.ID;
        fn = fieldnames(my_sbtab_object.column.column);
        for it = 1:length(fn),
          if ~strcmp(fn{it},'ID'),
            my_fn = fn{it};
            my_sbtab_object.column.column.(my_fn);
            for itt = 1:length(my_IDs),
              my_struct.(my_IDs{itt}).(my_fn) = my_sbtab_object.column.column.(my_fn){itt};
            end
          end
        end
        
      case 'table',
        my_struct.table = sbtab_table_to_cell(my_sbtab_object);
        my_struct.table = my_struct.table(2:end,:);
        
      otherwise,
        error(sprintf('invalid function argument "%s"',structure));
    end

end
