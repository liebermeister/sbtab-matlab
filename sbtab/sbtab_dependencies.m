function sbtab_dependencies()

% sbtab_dependencies()
%
% Check whether the packages used by SBtab for Matlab are installed
% (see README.md for details)

if ~exist('matlab_utils_installed','file')
  warning('Please install the Matlab utility functions (https://github.com/liebermeister/matlab-utils) - They are required by SBtab for Matlab.');
end

if ~exist('network_construct','file')
  warning('Please install the Metabolic Network Toolbox (https://github.com/liebermeister/metabolic-network-toolbox) - Otherwise the functions in sbtab-formats will not work.');
end

if ~exist('TranslateSBML','file')
  warning('Please install the Matlab interface of libSBML (https://sbml.org/software/libsbml/) - Otherwise the SBML conversion functions will not work.');
end
