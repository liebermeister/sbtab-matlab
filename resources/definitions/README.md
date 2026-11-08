SBtab definitions tables
========================

These tables define the predefined table types of SBtab and their columns.
They are used to check which table types can be read, to validate SBtab files
and to describe the columns (e.g. in html output). The same files are used in
sbtabpy (`src/sbtab/definitions`) and in sbtab-matlab
(`resources/definitions`).

- `definition_0.9.1_published.tsv`: SBtab 1.0, the definitions table offered
  on www.sbtab.net (it declares `SBtabVersion='0.9.1'`; columns
  `!ComponentName`, `!ComponentType`, `!IsPartOf`, `!Format`, `!Description`).
- `definition_1.1.tsv`: SBtab 1.1, derived from the appendix of the SBtab 1.1
  specification.
- `definition_1.2.tsv`: SBtab 1.2, derived from the appendix of the SBtab 1.2
  specification. The table types that it contains and `definition_1.1.tsv`
  does not (e.g. `SBMLfbcObjective`, `SBMLlayout`, `ToolInputOutput`) exist only in SBtab 1.2;
  documents containing them are written as SBtab 1.2.
- `definition_tool_types.tsv`: table types that are read by the SBtab tools
  but not defined in the SBtab specifications: `Layout` and `FbcObjective`
  (older names of `SBMLlayout` and `SBMLfbcObjective`), `Options` and the
  rxncon tables `rxnconContingencyList`, `rxnconReactionList`.

See the [SBtab specification](https://www.sbtab.net/sbtab/default/downloads.html#spec).
