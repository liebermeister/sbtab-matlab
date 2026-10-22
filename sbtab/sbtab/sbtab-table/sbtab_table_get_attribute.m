function attributes = sbtab_table_get_attribute(my_sbtab_table,key)

% SBTAB_TABLE_GET_ATTRIBUTE Get an attribute value from an SBtab table
%
% attribute = sbtab_table_get_attribute(my_sbtab_table,key)

attributes = getfield(my_sbtab_table.attributes,key);