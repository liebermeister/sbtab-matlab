function object_type = sbtab_object_type(sbtab_object)

% object_type = sbtab_object_type(sbtab_object)
%
% returns either 'document' or 'table'
 
if isfield(sbtab_object,'tables'),
  object_type = 'document';
else
  object_type = 'table';
end
