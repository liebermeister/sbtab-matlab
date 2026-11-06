% Utility functions
%
% sbtab_version                 - default SBtab version for writing files ('1.1')
% sbtab_check_version           - check an SBtab version number for writing files
% sbtab_required_version        - SBtab version required by table types ('1.2' for 1.2-only types)
% sbtab_basedir                 - main folder of the repository
% sbtab_resourcedir             - folder with resources (example files)
% sbtab_load_example            - load an example file
% sbtab_load_data_object        - load an SBtab, SBML or Matlab file
% sbtab_load_text_table         - read a tab-, comma- or semicolon-separated file into a cell array
% sbtab_parse_attributes        - read the attributes from a declaration line
% sbtab_parse_sbo_header        - parse a column header !SBO:<quantity> [<unit>:<Scale>]:<ValueType>
% annotate_list                 - load a table of annotations and map a list of names
% sbtab_definitions             - definitions table of an SBtab version
% sbtab_clean_column_headers    - convert column names into Matlab field names
% sbtab_clean_table_id          - convert table IDs into Matlab field names
% sbtab_cell_to_numbers         - convert table entries into numbers
% sbtab_check_controlled        - check uniqueness of keys in the first column
% sbtab_remove_keys             - remove rows with given keys
% sbtab_substructure            - convert a struct of columns into a struct of rows
% sbtab_regulationFormula_parse - parse a regulation formula
