% SBtab tables
%
% Construction, loading and saving
%   sbtab_table_construct            - construct an SBtab table
%   sbtab_table_load                 - load an SBtab table from a file or a cell array
%   sbtab_table_load_from_document   - load one table from a document file
%   sbtab_table_save                 - save an SBtab table (or convert it into a cell array)
%   sbtab_table_print                - display an SBtab table
%   sbtab_table_convert_version      - adapt a table to an SBtab version (used when saving)
%   matrix_to_sbtab_table            - construct a table of type 'Matrix' from a matrix
%   struct_to_sbtab_table            - construct an SBtab table from a struct of columns
%
% Attributes and columns
%   sbtab_table_add_attribute        - add an attribute
%   sbtab_table_get_attribute        - get an attribute value
%   sbtab_table_get_attributes       - get all attributes
%   sbtab_table_add_column           - add a column
%   sbtab_table_add_annotation       - add a column with annotations for the entries of another column
%   sbtab_table_get_column           - get a column
%   sbtab_table_get_all_columns      - get all SBtab columns (as a struct)
%   sbtab_table_get_element          - get an element
%   sbtab_table_get_ids              - get the entries of the ID column
%   sbtab_table_has_column           - check whether a column exists
%   sbtab_table_remove_column        - remove a column
%   sbtab_table_check                - check the TableType attribute
%
% Rows and tables
%   sbtab_table_remove_comment_lines - remove rows starting with '%'
%   sbtab_table_subselect_items      - select rows
%   sbtab_table_combine_horizontally - combine two tables with the same rows
%   sbtab_table_combine_vertically   - combine two tables with the same columns
%   sbtab_table_diff                 - compare two tables
%
% Conversion
%   sbtab_table_to_cell              - convert into a cell array
%   sbtab_table_array                - convert into a cell array
%   sbtab_table_export               - convert into a flat cell array (and write it to a file)
%   sbtab_table_to_table             - convert into a Matlab table object
%   sbtab_table_to_matrix            - convert a table of type 'Matrix' into a matrix
%   sbtab_table_to_struct            - convert into a struct of columns
%   sbtab_table_to_simple_struct     - convert a key column and a value column into a struct
