function my_sbtab_object = struct_to_sbtab(my_struct)

% STRUCT_TO_SBTAB Construct an SBtab object from matlab struct
%
% my_sbtab_object = struct_to_sbtab(structure)
%
% Construct an SBtab document or table object from a matlab struct
% for the conversion in from SBtab object to struct, see 'sbtab_to_struct'
  
if isfield(my_struct,'DOCUMENT_ATTRIBUTES'),
  object_type = 'document';
elseif isfield(my_struct,'TABLE_ATTRIBUTES'),
  object_type = 'table';
else
  error('input struct does not have the right form to be converted into an sbtab object');
end

switch object_type,
  case 'document',
    attributes = my_struct.DOCUMENT_ATTRIBUTES; 
    my_struct = rmfield(my_struct,'DOCUMENT_ATTRIBUTES');
    table_names = fieldnames(my_struct);
    tables = {};
    for it = 1:length(table_names),
      tables = [tables; struct_to_sbtab(my_struct.(table_names{it}))];
    end
    my_sbtab_object = sbtab_document_construct(attributes,table_names,tables);
    
  case 'table',
    attributes = my_struct.TABLE_ATTRIBUTES;
    my_struct = rmfield(my_struct,'TABLE_ATTRIBUTES');
    
    if ~isfield(attributes,'TableType'),
      warning('Table type missing');
      attributes.TableType = 'unknown';
    end
    
    if ~isfield(attributes,'TableID'),
      error('Table ID missing');
    end

    my_sbtab_object.attributes   = attributes; 
    my_sbtab_object.rows         = struct;
    
    fn = fieldnames(my_struct);

    if iscell(my_struct.(fn{1})) + ismatrix(my_struct.(fn{1})),
      
      % the struct entries correspond to table columns
      my_sbtab_object.column.column_names = fn;
      my_sbtab_object.column.column     = my_struct;
      my_sbtab_object.column.attributes = struct;
      my_sbtab_object.column.ind        = 1:length(fieldnames(my_struct));
      my_sbtab_object.data              = struct('ind',[]);
      my_sbtab_object.uncontrolled      = struct('ind',[],'headers',[]);
      
    elseif isstruct(my_struct.(fn{1})),

      % the struct entries correspond to table rows
      element_names = fn;
      column_names = fieldnames(my_struct.(element_names{1}));
      my_sbtab_object.column.column_names = [{'ID'}; column_names];
      cn.ID = column(element_names)';
      for it=1:length(column_names)
        cn.(column_names{it}) = {};
        for itt = 1:length(element_names),
          cn.(column_names{it}){itt} = my_struct.(element_names{itt}).(column_names{it});
        end
      end
      my_sbtab_object.column.column = cn; 
      my_sbtab_object.column.attributes = struct;
      my_sbtab_object.column.ind        = 1:length(column_names)+1;
      my_sbtab_object.data              = struct('ind',[]);
      my_sbtab_object.uncontrolled      = struct('ind',[],'headers',[]);
      
    end
end
