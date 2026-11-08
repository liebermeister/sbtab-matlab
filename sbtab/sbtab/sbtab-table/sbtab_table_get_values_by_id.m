function [values, unknown_ids, is_found] = sbtab_table_get_values_by_id(sbtab_table, id_column, element_ids, value_column, verbose)

% SBTAB_TABLE_GET_VALUES_BY_ID Get numerical values from an SBtab table, matched to a list of element IDs
%
% [values, unknown_ids, is_found] = sbtab_table_get_values_by_id(sbtab_table, id_column, element_ids, value_column, verbose)
%
% Reads the column 'value_column' and sorts the values by the element IDs given in 'element_ids'
% (for instance, the reaction or compound IDs of a model). The order of rows in the table does
% not matter; table rows whose IDs do not appear in 'element_ids' are ignored.
%
% Arguments
%   sbtab_table   SBtab table object
%   id_column     name of the column containing the element IDs (e.g. 'Reaction' or 'Compound'),
%                 or cell array of column names, of which the first existing one is used
%                 (e.g. {'Compound', 'Compound:SBML:species:id'})
%   element_ids   cell array of element IDs (defines the order of the output vector)
%   value_column  name of the numerical column (e.g. 'Value', 'Min', 'Max')
%   verbose       (default 1) show a warning if table rows cannot be matched
%
% Output
%   values        column vector (length of element_ids); NaN for elements not listed in the table
%   unknown_ids   IDs in the table that do not occur in 'element_ids'
%   is_found      Boolean vector: element found in the table
%
% If the table has none of the ID columns, but exactly one row per element, the rows are
% assumed to be in the order of 'element_ids' (with a warning; for older files).

eval(default('verbose','1'));

if ischar(id_column), id_column = {id_column}; end

element_ids = element_ids(:);
x = sbtab_table_get_column(sbtab_table, value_column, 1, 0);
if isempty(x)
  error('Column "%s" missing in SBtab table "%s"', value_column, sbtab_table_name(sbtab_table));
end
x = x(:);

my_id_column = '';
for it = 1:length(id_column)
  if sbtab_table_has_column(sbtab_table, id_column{it})
    my_id_column = id_column{it};
    break
  end
end

if isempty(my_id_column)
  if length(x) == length(element_ids)
    warning('SBtab table "%s": no ID column (%s); I assume that the rows are in the order of the model elements', sbtab_table_name(sbtab_table), strjoin(id_column, ', '));
    values      = x;
    unknown_ids = {};
    is_found    = true(size(values));
    return
  else
    error('SBtab table "%s": ID column (%s) missing', sbtab_table_name(sbtab_table), strjoin(id_column, ', '));
  end
end

ids = sbtab_table_get_column(sbtab_table, my_id_column, 0);
[found, ind] = ismember(ids(:), element_ids);
unknown_ids  = ids(~found);

values   = nan(length(element_ids), 1);
values(ind(found)) = x(found);
is_found = false(length(element_ids), 1);
is_found(ind(found)) = true;

if verbose && length(unknown_ids)
  warning('SBtab table "%s": elements not found in the model (ignored): %s', sbtab_table_name(sbtab_table), strjoin(unknown_ids(:)', ', '));
end


% ---------------------------------------------------------------

function name = sbtab_table_name(sbtab_table)

name = '';
if isfield(sbtab_table, 'attributes') && isfield(sbtab_table.attributes, 'TableID')
  name = sbtab_table.attributes.TableID;
end
