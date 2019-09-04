% SBTAB_RESOURCEDIR - Return SBtab toolbox resource directory
%
% d = sbtab_resourcedir()

function d = sbtab_resourcedir()

d = [fileparts(which(mfilename)) filesep '..' filesep '..'  filesep '..' filesep '..' filesep 'resources' ];
