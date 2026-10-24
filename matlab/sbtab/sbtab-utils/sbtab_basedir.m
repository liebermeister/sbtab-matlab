% SBTAB_BASEDIR - Return SBtab toolbox directory
%
% d = sbtab_basedir()

function d = sbtab_basedir()

d = [fileparts(which(mfilename)) filesep '..' filesep '..' ];
