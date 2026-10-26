function T = sbtab_load_text_table(filename)

% SBTAB_LOAD_TEXT_TABLE Read a tab- or comma-separated text file into a cell array of strings
%
% T = sbtab_load_text_table(filename)
%
% The delimiter is taken from the first column header row (starting with '!', but not '!!'),
% or, if there is none, from the first line that is not empty and does not start with '%':
% tab if this line contains a tab; otherwise comma or semicolon (whichever occurs more often
% outside quotes); if none of them occurs, tab.
% In comma- and semicolon-separated files, fields may be enclosed in double quotes
% ("" stands for a double quote inside a field); in tab-separated files, quotes are kept as they are.
% A byte order mark and Windows or Mac line endings are accepted.
% Empty rows and columns are removed; missing cells are filled with ''.

if ~exist(filename, 'file')
  error('File %s cannot be found', filename);
end

text = fileread(filename, 'Encoding', 'UTF-8');
if ~isempty(text) && text(1) == char(65279)
  text = text(2:end);
end
lines = regexp(text, '\r\n|\n|\r', 'split');

% reference line for the delimiter: the first column header row ('!', but not '!!'),
% since declaration rows may consist of one cell containing commas (e.g. in TableName);
% if there is none, the first line that is not empty and not a comment
reference_line = '';
for it = 1:length(lines)
  this_line = strtrim(lines{it});
  if ~isempty(this_line) && this_line(1) ~= '%'
    if isempty(reference_line)
      reference_line = lines{it};
    end
    if this_line(1) == '!' && ~startsWith(this_line, '!!')
      reference_line = lines{it};
      break
    end
  end
end

delimiter = sprintf('\t');
if ~isempty(reference_line) && ~contains(reference_line, sprintf('\t'))
  n_comma     = count_outside_quotes(reference_line, ',');
  n_semicolon = count_outside_quotes(reference_line, ';');
  if n_semicolon > n_comma
    delimiter = ';';
  elseif n_comma > 0
    delimiter = ',';
  end
end

rows = cell(length(lines), 1);
for it = 1:length(lines)
  if strcmp(delimiter, sprintf('\t'))
    % regexp instead of strsplit, which is shadowed by other toolboxes on some paths
    rows{it} = regexp(lines{it}, '\t', 'split');
  else
    rows{it} = split_quoted(lines{it}, delimiter);
  end
end

n_columns = max([0; cellfun('length', rows)]);
T = repmat({''}, length(rows), n_columns);
for it = 1:length(rows)
  T(it, 1:length(rows{it})) = rows{it};
end

% remove empty rows and columns
is_filled = ~cellfun('isempty', T);
T = T(any(is_filled, 2), any(is_filled, 1));


% -----------------------------------------------------

function n = count_outside_quotes(line, character)

n = sum(line(~mod(cumsum(line == '"'), 2)) == character);


function fields = split_quoted(line, delimiter)

fields   = {};
field    = '';
in_quote = 0;
it = 1;
while it <= length(line)
  c = line(it);
  if in_quote
    if c == '"'
      if it < length(line) && line(it+1) == '"'
        field = [field '"'];
        it = it + 1;
      else
        in_quote = 0;
      end
    else
      field = [field c];
    end
  elseif c == '"' && isempty(strtrim(field))
    in_quote = 1;
    field = '';
  elseif c == delimiter
    fields{end+1} = field;
    field = '';
  else
    field = [field c];
  end
  it = it + 1;
end
fields{end+1} = field;
