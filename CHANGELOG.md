# Changelog

Version numbers have the form MAJOR.MINOR.PATCH. MAJOR changes when existing calls may stop working.

## 1.0.0 (not released yet)

First numbered version.

- HTML documentation removed from the repository (it can be regenerated with m2html)
- Version function `sbtab_toolbox_version`. This is the version of the code; `sbtab_version` still gives the version of the SBtab file format
- Support for SBtab format 1.1 and validation of SBtab documents
- Tests and README
- Conversion between SBtab and network models, omics data, SBML and COBRA, and `sbtab_model_display`, moved to the Metabolic Network Toolbox (folder `mnt_sbtab_conversion`). SBtab for Matlab now requires only matlab-utils
- `annotate_list` moved here from matlab-utils

The state before the cleanup of October 2026 is available under the git tag `v0.9-legacy`.
