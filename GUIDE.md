# How do I ...?

A short guide to the most common tasks. Type `help` and a function name for details.

An SBtab table is stored in a Matlab struct, and an SBtab document (several tables) in another struct.

## First steps

```matlab
filename = fullfile(sbtab_resourcedir, 'examples', 'sbtab-1.1', 'escherichia-coli', 'escherichia-coli_noor_2016_model.tsv');
sbtab_document = sbtab_document_load(filename);
reaction_table = sbtab_document_get_table(sbtab_document, 'Reaction');
ids = sbtab_table_get_column(reaction_table, 'ID');
```

## Read and write files

| Task | Function |
|---|---|
| Load a table | `sbtab_table_load` |
| Save a table | `sbtab_table_save` |
| Load a document with one table per file | `sbtab_document_load` |
| Load a document from one file | `sbtab_document_load_from_one` |
| Save a document to one file | `sbtab_document_save`, `sbtab_document_save_to_one` |
| Load one of the example files | `sbtab_load_example` |

## Work with tables

| Task | Function |
|---|---|
| Build a table in Matlab | `sbtab_table_construct` |
| Get a column | `sbtab_table_get_column`, `sbtab_table_has_column` |
| Get all IDs of a table | `sbtab_table_get_ids` |
| Add or remove a column | `sbtab_table_add_column`, `sbtab_table_remove_column` |
| Select some rows | `sbtab_table_subselect_items` |
| Read or set attributes | `sbtab_table_get_attribute`, `sbtab_table_add_attribute` |
| Check a table | `sbtab_table_check` |

## Work with documents

| Task | Function |
|---|---|
| Build a document in Matlab | `sbtab_document_construct` |
| Add a table | `sbtab_document_add_table` |
| Get a table, or the list of tables | `sbtab_document_get_table`, `sbtab_document_get_table_names` |
| Combine or compare documents | `sbtab_document_combine`, `sbtab_document_diff` |
| Show the structure | `sbtab_print` |

## SBtab versions

| Task | Function |
|---|---|
| Default SBtab version | `sbtab_version` |
| Versions that can be written | `sbtab_check_version` |
| Version of this toolbox | `sbtab_toolbox_version` |
