function my_sbtab_table = sbtab_table_construct(attributes, column_names, columns)

% my_sbtab_table = sbtab_table_construct(struct('Type','Wonder'),{'A'},{{1 2 3}'})

my_sbtab_table = struct('attributes',{attributes},'column',struct,'rows',struct,'data',struct('ind',[]),'uncontrolled',struct('ind',[]));

if exist('column_names','var'),
  for it = 1:length(column_names),
    my_sbtab_table.column.column.(column_names{it}) = columns{it};
  end
  my_sbtab_table.column.ind = 1:length(column_names);
end
