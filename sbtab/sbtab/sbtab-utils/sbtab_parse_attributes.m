function attributes = sbtab_parse_attributes(declaration_line)

% SBTAB_PARSE_ATTRIBUTES Read the attributes from an SBtab declaration line
%
% attributes = sbtab_parse_attributes(declaration_line)
%
% declaration_line: string, or cell array of strings (the cells of a '!!SBtab' or '!!!SBtab' line)
% attributes      : struct with one field per attribute (values are strings)
%
% Attributes have the form Name='value' or Name="value" and may be spread over several cells
% or written in one cell. Values may contain spaces, '=' and the other type of quote;
% unquoted values (Name=value) are accepted as well.
% Attribute names are converted into Matlab field names: a leading '!' and the ':' of
% constant-column attributes (e.g. ':Unit') are removed, and '>' is replaced by 'SAMPLE_'.

if iscell(declaration_line)
  declaration_line = declaration_line(~cellfun('isempty', declaration_line));
  declaration_line = strjoin(declaration_line, ' ');
end

line = declaration_line;
line(line == char(8216) | line == char(8217)) = '''';
line(line == char(8220) | line == char(8221)) = '"';
line = regexprep(line, '^\s*!*\s*SBtab\s*', '', 'ignorecase');

tokens = regexp(line, '([^\s=]+)\s*=\s*(''[^'']*''|"[^"]*"|[^\s''"]*)', 'tokens');

attributes = struct;
for it = 1:length(tokens)
  name  = strrep(strrep(tokens{it}{1}, '!', ''), ':', '');
  value = tokens{it}{2};
  if length(value) >= 2 && any(value(1) == '''"')
    value = value(2:end-1);
  end
  name = sbtab_clean_column_headers(name);
  if isempty(name)
    continue
  end
  if ~isletter(name(1))
    name = ['x' name];
  end
  attributes.(name) = strtrim(value);
end
