Matlab code for SBtab file format
=================================

[SBtab](https://www.sbtab.net) is a table-based data format for Systems Biology, designed to support automated data integration and model building. It uses the structure of spreadsheets and defines conventions for table structure, controlled vocabularies and semantic annotations. The format comes with predefined table types for experimental data and SBML-compliant model structures and can easily be customized to cover new types of data.

This repository contains Matlab code for SBtab. For python code and a larger collection of example files, please see the [main SBtab repository](https://github.com/tlubitz/SBtab).

## Installation

Download or clone the repository and add the `sbtab` folder, with its subfolders, to your Matlab path:

```matlab
addpath(genpath('/path/to/sbtab-matlab/sbtab'));
savepath;   % optional: keep the folders on the path in future sessions
```

Then install the required packages (see below) and run the demo:

```matlab
demo_sbtab
```

To check which of the other packages are installed, run `sbtab_dependencies`.

## Requirements

- Matlab (tested with R2025b)
- [Matlab utility functions](https://github.com/liebermeister/matlab-utils) (required)

Conversion between SBtab and network models, omics data, SBML and COBRA is part of the
[Metabolic Network Toolbox](https://github.com/liebermeister/metabolic-network-toolbox)
(folder `mnt_sbtab_conversion`).

## Usage

```matlab
filename = fullfile(sbtab_resourcedir, 'examples', 'sbtab', 'ecoli', 'ecoli_noor_2016_model.tsv');
sbtab_document = sbtab_document_load(filename);         % load an SBtab document (several tables)
sbtab_print(sbtab_document)                              % show its structure
reaction_table = sbtab_document_get_table(sbtab_document, 'Reaction');
ids = sbtab_table_get_column(reaction_table, 'ID');      % get a column
sbtab_document_save(sbtab_document, 'my_model.tsv');     % save the document to one file
```

## Contents

- **`sbtab/sbtab`**: SBtab tables (`sbtab-table`) and documents (`sbtab-document`), functions for both
  (`sbtab`), and utility functions (`sbtab-utils`)
- **`sbtab/sbtab-formats`**: conversion between SBtab and Matlab structs with tool options
- **`resources/examples`**: example files (SBtab, SBML, COBRA)

Each folder contains a `Contents.m` file with an overview (type, e.g., `help sbtab-table`).
HTML documentation is available in the folder `doc`.

## Tests

From the repository folder, run

```matlab
results = runtests('tests')
```

## Versions

To see the installed version, type `sbtab_toolbox_version` (the version of the SBtab file format is given by `sbtab_version`). Older versions can be downloaded from the [releases page](https://github.com/liebermeister/sbtab-matlab/releases) of this repository, and changes between versions are listed in `CHANGELOG.md`.

## License
This package is released under the [GNU General Public License](LICENSE), version 2 or later.

## Contact
Please contact [Wolfram Liebermeister](mailto:wolfram.liebermeister@gmail.com) with any questions or comments.

## Reference
Lubitz T., Hahn J., Bergmann F.T., Noor E., Klipp E., Liebermeister W. (2016),
*SBtab: A flexible table format for data exchange in systems biology*.
[Bioinformatics 32 (16) 2559–2561](https://academic.oup.com/bioinformatics/article/32/16/2559/1743291)
