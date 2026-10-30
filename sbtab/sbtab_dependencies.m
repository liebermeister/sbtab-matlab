function sbtab_dependencies()

% sbtab_dependencies()
%
% Check whether the packages used by SBtab for Matlab are installed
% (see README.md for details)

if ~exist('matlab_utils_installed','file')
  warning('Please install the Matlab utility functions (https://github.com/liebermeister/matlab-utils) - They are required by SBtab for Matlab.');
end

if exist('package_version_check','file')
  package_version_check('The Matlab utility functions', 'matlab_utils_version', '1.0.0');
end
