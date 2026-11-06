# Changelog

Version numbers have the form MAJOR.MINOR.PATCH. MAJOR changes when existing calls may stop working.

## Not released yet

- Definitions tables of SBtab 1.1 and 1.2: new columns of `QuantityInfo` tables for priors of multiplicative quantities and related information, as used in parameter balancing and model balancing: `!BiologicalElement`, `!PhysicalType`, `!MathematicalType`, `!PriorGeometricStd`, `!DataGeometricStd`, `!UseAsPriorInformation` (also added to the SBtab 1.1 and 1.2 specifications).
- Extra definitions tables (planned for SBtab 1.2): `sbtab_definitions(version, extra, mode)` extends ('extend', default) or replaces ('replace') the definitions table of a version by extra definitions tables (table objects, files, documents, or cell arrays of these); new functions `sbtab_definitions_merge`, `sbtab_definitions_read`, `sbtab_document_set_definitions` (stores them in the document object, field `definitions`) and `sbtab_document_get_definitions`; `sbtab_document_validate` uses the definitions of the document and has the new option `definitions_mode` (option `definitions` now extends the default definitions by default)
- `sbtab_basedir` now returns the main directory of the repository
- New `GUIDE.md` and `CITATION.cff`; `README.md` has a Quick start section
- `sbtab_document_validate`: the default version for documents without `SBtabVersion` is 1.1; new rules R16 (SBtabVersion of the document repeated in a table declaration row: warning) and R17 (table type of SBtab 1.2 in a 1.0/1.1 document: warning); in SBtab 1.0, `!Identifiers:<resource>` columns are accepted with the published definitions table and `ReactionStoichiometry` gives a warning instead of an error
- `tests/test_examples.m` tests only the SBtab 1.1 examples by default (environment variable `SBTAB_TEST_VERSIONS`, e.g. `1.0,1.1` or `all`)
- Example files with `e_coli` or `ecoli` in their names renamed to `escherichia-coli` (`escherichia_coli` in Matlab function and script names)

## 1.0.0 (2026-10-31)

First numbered version.

- HTML documentation removed from the repository (it can be regenerated with m2html)
- Version function `sbtab_toolbox_version`. This is the version of the code; `sbtab_version` still gives the version of the SBtab file format
- Support for SBtab format 1.1 and validation of SBtab documents
- Tests and README
- Conversion between SBtab and network models, omics data, SBML and COBRA, and `sbtab_model_display`, moved to the Metabolic Network Toolbox (folder `mnt_sbtab_conversion`). SBtab for Matlab now requires only matlab-utils
- `annotate_list` moved here from matlab-utils

The state before the cleanup of October 2026 is available under the git tag `v0.9-legacy`.
