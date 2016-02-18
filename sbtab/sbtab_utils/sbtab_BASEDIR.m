% SBTAB_BASEDIR Directory in which SBtab package is installed
%
% d = sbtab_BASEDIR()

function d = sbtab_BASEDIR()

d = [fileparts(which(mfilename)) '/../'];
