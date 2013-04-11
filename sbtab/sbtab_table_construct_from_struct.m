function my_sbtab_table = sbtab_table_construct_from_struct(attributes,my_struct)

% my_sbtab_table = sbtab_table_construct_from_struct(attributes,my_struct)
%
% construct a table with ONLY controlled columns from a matlab struc containing
% exactly these controlled columns,
    
my_sbtab_table.attributes   = attributes; 
my_sbtab_table.rows         = struct;
my_sbtab_table.column.column= my_struct;
my_sbtab_table.column.attributes = struct;
my_sbtab_table.column.ind        = 1:length(fieldnames(my_struct));
my_sbtab_table.data         = struct('ind',[]);
my_sbtab_table.uncontrolled = struct('ind',[]);
