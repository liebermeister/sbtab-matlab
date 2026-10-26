function v = sbtab_check_version(v)

% SBTAB_CHECK_VERSION Check an SBtab version number for writing SBtab files
%
% v = sbtab_check_version(v)
%
% v: version number (string, like '1.1', or number, like 1.1); if empty, the
%    default version (see 'sbtab_version') is returned
%
% Supported versions: '1.0' and '1.1'. For other versions, a warning is issued
% and the default version is returned.

supported_versions = {'1.0', '1.1'};

if isempty(v)
  v = sbtab_version;
elseif isnumeric(v)
  v = sprintf('%.1f', v);
end

if ~any(strcmp(v, supported_versions))
  warning('SBtab version %s is not supported (supported versions: %s); using version %s', ...
          v, strjoin(supported_versions, ', '), sbtab_version);
  v = sbtab_version;
end
