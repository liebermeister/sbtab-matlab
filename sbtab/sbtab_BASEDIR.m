% SBTAB_BASEDIR - Return SBtab toolbox directory
%
% d = sbtab_BASEDIR()

function d = sbtab_BASEDIR()

d = [fileparts(which(mfilename)) filesep '..' filesep];
