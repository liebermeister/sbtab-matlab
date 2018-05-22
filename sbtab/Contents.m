% MATLAB Toolbox for SBtab file format
%
% The toolbox provides functions for reading, writing, and manipulating SBtab tables and documents.
% For more information about the SBtab format, please visit the website at www.sbtab.net
% To get a first impression, please run the demo script demo_sbtab.
%
% The toolbox also contains functions for the 'biotable' data format, a specific type of SBtab documents describing biological data. For further information, please type "help biotable" 
%
% Functions contained in the toolbox: 
%
% Functions for SBtab documents (please type "help <FUNCTIONNAME> for further information)
% 
% sbtab_document_add_column
% sbtab_document_add_table
% sbtab_document_construct
% sbtab_document_get_table
% sbtab_document_load_from_one
% sbtab_document_load
% sbtab_document_save
% sbtab_document_save_to_one
% sbtab_document_show
% 
% Functions for SBtab tables (please type "help <FUNCTIONNAME> for further information)
%
% sbtab_table_add_annotation
% sbtab_table_add_column
% sbtab_table_check
% sbtab_table_construct_from_struct
% sbtab_table_construct
% sbtab_table_export
% sbtab_table_get_all_columns
% sbtab_table_get_column
% sbtab_table_get_element
% sbtab_table_has_column
% sbtab_table_load
% sbtab_table_remove_column
% sbtab_table_remove_comment_lines
% sbtab_table_save
% sbtab_table_show
% sbtab_table_subselect_items
% 
% Other functions (please type "help <FUNCTIONNAME> for further information)
%
% sbtab_BASEDIR
% sbtab_regulationFormula_parse
% dynamic_data_2_sbtab
% sbtab_2_dynamic_data
% sbtab_check_controlled
% sbtab_clean_column_headers
% sbtab_remove_keys
% sbtab_substructure
% sbtab_version