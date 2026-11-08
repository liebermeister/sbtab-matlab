function [sbtab_table, description] = sbtab_table_from_input(input, table_ids, table_type)

% SBTAB_TABLE_FROM_INPUT Get an SBtab table object from a file name, an SBtab table object, or an SBtab document object
%
% [sbtab_table, description] = sbtab_table_from_input(input, table_ids, table_type)
%
% Helper function for tools that accept their input tables either as files or as SBtab objects.
%
% Arguments
%   input        one of the following:
%                 o file name (string): the table is loaded from the file
%                 o SBtab table object: returned unchanged
%                 o SBtab document object: the table is selected from the document (see below)
%   table_ids    (optional) TableID, or cell array of possible TableIDs, of the requested table
%                (the first one found is used)
%   table_type   (optional) TableType of the requested table
%
% Table selection (for files with several tables, and for SBtab documents):
%   1. the first table whose TableID is listed in 'table_ids'
%   2. otherwise, the first table of TableType 'table_type'
%   3. otherwise, the first table
%
% Output
%   sbtab_table  SBtab table object ([] if input is empty)
%   description  string describing the input (file name or TableID), for messages

eval(default('table_ids','[]','table_type','[]'));

if ischar(table_ids), table_ids = {table_ids}; end

sbtab_table = [];
description = '';

if isempty(input), return; end

if ischar(input)
  description = input;
  if isempty(table_ids) && isempty(table_type)
    % no table selection: first table of the file
    sbtab_table = sbtab_table_load(input);
    return
  end
  my_document = sbtab_document_load_from_one(input);
elseif isstruct(input) && isfield(input,'tables')
  my_document = input;
elseif isstruct(input) && isfield(input,'attributes') && isfield(input,'column')
  sbtab_table = input;
  description = table_description(sbtab_table);
  return
else
  error('Input must be a file name, an SBtab table object, or an SBtab document object');
end

fn = fieldnames(my_document.tables);
if isempty(fn)
  error('SBtab document %s contains no tables', description);
end

my_fn = '';
for it = 1:length(table_ids)
  if isfield(my_document.tables, sbtab_clean_table_id(table_ids{it}))
    my_fn = sbtab_clean_table_id(table_ids{it});
    break
  end
end

if isempty(my_fn) && length(table_type)
  for it = 1:length(fn)
    my_attributes = my_document.tables.(fn{it}).attributes;
    if isfield(my_attributes,'TableType') && strcmp(my_attributes.TableType, table_type)
      my_fn = fn{it};
      break
    end
  end
end

if isempty(my_fn)
  my_fn = fn{1};
end

sbtab_table = my_document.tables.(my_fn);

if isempty(description)
  description = table_description(sbtab_table);
end


% ---------------------------------------------------------------

function description = table_description(sbtab_table)

description = '[SBtab table object]';
if isfield(sbtab_table.attributes,'TableID')
  description = sprintf('[SBtab table object %s]', sbtab_table.attributes.TableID);
end
