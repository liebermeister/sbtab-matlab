function sbtab_table_check(sbtab,type)

% SBTAB_TABLE_CHECK Check table for table type attribute being present
%
% sbtab_table_check(sbtab,type)
%
% Issue a warning if the table has no TableType attribute or
% (if the argument 'type' is given) if the table type differs from 'type'

eval(default('type','[]'));

if ~isfield(sbtab.attributes,'TableType'),
  warning('No table type specified');
elseif ~isempty(type) && ~strcmp(sbtab.attributes.TableType,type),
  warning('Table type is "%s" (expected "%s")', sbtab.attributes.TableType, type);
end
