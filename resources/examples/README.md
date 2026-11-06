# Example files

- `sbtab-1.0/`: the SBtab example files offered on https://www.sbtab.net
  (Downloads, "Example files"), each in a folder of its own, with corrected
  declaration rows: `SBtabVersion='1.0'` in all declaration rows (on the
  website, some files declare 1.1 or no version), single quotes, a TableName
  (the table key in 1.0) in every table, the table types `Relation` (instead
  of `Relationship`) and `Config` (instead of `PbConfig`), and without the
  old attributes `Version`, `Level`. The table contents are unchanged.
- `sbtab-1.1/`: example files in SBtab 1.1 (the table key is TableID,
  TableName is free text; in documents with a `!!!SBtab` row, the
  SBtabVersion is given only there).
- `sbtab-1.2/`: example files that need SBtab 1.2: models with the SBML
  packages fbc (`SBMLfbcObjective` table) and layout (`SBMLlayout` table).
- `sbml/`: SBML models, among them the models of the SBtab examples.
- `options/`: an options table (`ecm_options.tsv`).
