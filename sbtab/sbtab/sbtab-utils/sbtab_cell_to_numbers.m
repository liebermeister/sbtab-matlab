function x = sbtab_cell_to_numbers(c)

% SBTAB_CELL_TO_NUMBERS Convert table entries (strings or numbers) into a numeric array
%
% x = sbtab_cell_to_numbers(c)
%
% c: cell array whose entries are strings or numbers
% Empty and non-numeric entries are converted to NaN

if ~iscell(c),
  x = c;
  return
end

x = nan(size(c));
is_number = cellfun(@(e) (isnumeric(e) || islogical(e)) && isscalar(e), c);
x(is_number) = [c{is_number}];
is_string = cellfun(@ischar, c);
x(is_string) = str2double(c(is_string));
