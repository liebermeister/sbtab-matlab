function sbtab_table = matrix_to_sbtab_table(matrix,table_id) 
  
% sbtab_table = matrix_to_sbtab_table(matrix,table_id)

attributes.TableID   = table_id;
attributes.TableType = 'Matrix';

nc = size(matrix,2);

if nc>0,
  for it = 1:nc,
    column_names{it} = sprintf('col%d',it);
    columns{it} = num2cell(matrix(:,it));
  end
else
  column_names = {};
  columns = {};
end

sbtab_table = sbtab_table_construct(attributes, column_names, columns);
