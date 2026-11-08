function network = sbtab_regulation_network_load(input, options)

% SBTAB_REGULATION_NETWORK_LOAD Read a regulation network (arrows and signs) from an SBtab document
%
% network = sbtab_regulation_network_load(input, options)
%
% Reads a network of regulation arrows, e.g. a transcription network, from an SBtab
% document: regulators (e.g. transcription factors, Regulator table), targets (e.g. genes,
% Gene table), and the arrows between them with their signs, given
%  - in a Regulation table (SBtab 1.2; default): one row per arrow, with columns
%      !Regulator, !Target, and the sign in !RegulationType ('activation', 'inhibition',
%      'dual', 'unknown'), !RegulationType:SBO, or the sign of !RegulatoryCoefficient
%      (the first of these columns with an entry is used; NaN or no entry: sign unknown)
%  - or in a column !ActivityCondition of the target table: for each target, a
%      kinetic regulation formula listing its regulators, e.g. '+ TF1 - TF2'
%      ('?': unknown, also if no sign is given; '+-': dual)
%
% Weights of the arrows (e.g. NCA connection strengths) are read from a table of type
% SparseMatrix (columns !RowID, !ColumnID, !Value) with the table attributes
% RowTable (the target table type, e.g. 'Gene') and ColumnTable ('Regulator'); its table
% attribute QuantityType (e.g. 'regulation weight (log scale)') says what the values mean.
%
% Inputs
%   input    SBtab document object or filename (one file containing all tables)
%   options  struct with (optional) fields
%     .source             'auto' (default: Regulation table if present, otherwise the
%                         column ActivityCondition), 'Regulation', or 'ActivityCondition'
%     .target_table_type  table type of the targets (default 'Gene')
%     .regulator_table_type  table type of the regulators (default 'Regulator')
%
% Output: struct 'network' with fields
%   targets      column cell array of target IDs (from the target table; if there is
%                no target table, from the arrows)
%   regulators   column cell array of regulator IDs (from the Regulator table; if there
%                is no Regulator table, from the arrows)
%   arrows       sparse matrix (targets x regulators): 1 for each arrow
%   signs        sparse matrix (targets x regulators): +1 activation, -1 inhibition,
%                0 unknown or dual
%   source       'Regulation' or 'ActivityCondition'
%   weights      (only if a weights table is given) sparse matrix (targets x regulators)
%   weight_quantity_type  (only if a weights table is given) value of the table attribute
%                QuantityType of the weights table
%
% Arrows with unknown targets or regulators (not in the target or Regulator table) are
% ignored with a warning. Rows of a Regulation table with !TargetType 'metabolite' or
% 'enzyme' (kinetic regulation) are ignored.
%
% See also: sbtab_regulation_network_save

eval(default('options','struct'));
if isempty(options), options = struct; end
options = join_struct(struct('source','auto','target_table_type','Gene','regulator_table_type','Regulator'), options);

if ischar(input)
  sbtab_document = sbtab_document_load_from_one(input);
else
  sbtab_document = input;
end

target_table     = find_table(sbtab_document, options.target_table_type);
regulator_table  = find_table(sbtab_document, options.regulator_table_type);
regulation_table = find_table(sbtab_document, 'Regulation');

targets    = {};
regulators = {};
if ~isempty(target_table),    targets    = column(sbtab_table_get_column(target_table,'ID'));    end
if ~isempty(regulator_table), regulators = column(sbtab_table_get_column(regulator_table,'ID')); end

source = options.source;
if strcmp(source,'auto')
  if ~isempty(regulation_table)
    source = 'Regulation';
  else
    source = 'ActivityCondition';
  end
end

% list of arrows: target, regulator, sign
my_targets = {}; my_regulators = {}; my_signs = [];

switch source

  case 'Regulation'
    if isempty(regulation_table), error('No Regulation table found'); end
    regulation_table = sbtab_table_remove_comment_lines(regulation_table);
    my_regulators = column(sbtab_table_get_column(regulation_table,'Regulator'));
    my_targets    = column(sbtab_table_get_column(regulation_table,'Target'));
    n = length(my_targets);
    sign_type = nan(n,1); sign_sbo = nan(n,1); sign_coef = nan(n,1);
    if sbtab_table_has_column(regulation_table,'RegulationType')
      sign_type = cellfun(@regulation_type_sign, column(sbtab_table_get_column(regulation_table,'RegulationType')));
    end
    if sbtab_table_has_column(regulation_table,'RegulationType:SBO')
      sign_sbo = cellfun(@regulation_type_sign, column(sbtab_table_get_column(regulation_table,'RegulationType:SBO')));
    end
    if sbtab_table_has_column(regulation_table,'RegulatoryCoefficient')
      sign_coef = sign(column(sbtab_table_get_column(regulation_table,'RegulatoryCoefficient',1)));
      sign_coef(sign_coef==0) = nan;
    end
    my_signs = zeros(n,1);
    for it = 1:n
      given = [sign_type(it), sign_sbo(it), sign_coef(it)];
      given = given(~isnan(given));
      if length(given)
        my_signs(it) = given(1);
        if any(given ~= given(1))
          warning('Regulation table, row %d (%s -> %s): the columns for the type of regulation disagree; using the first given', it, my_regulators{it}, my_targets{it});
        end
      end
    end
    % rows describing kinetic regulation of enzymes are not part of the network
    if sbtab_table_has_column(regulation_table,'TargetType')
      target_types = lower(strtrim(column(sbtab_table_get_column(regulation_table,'TargetType'))));
      keep = ~ismember(target_types, {'metabolite','enzyme'});
      my_targets = my_targets(keep); my_regulators = my_regulators(keep); my_signs = my_signs(keep);
    end

  case 'ActivityCondition'
    if isempty(target_table) || ~sbtab_table_has_column(target_table,'ActivityCondition')
      error('No %s table with column ActivityCondition found', options.target_table_type);
    end
    conditions = column(sbtab_table_get_column(target_table,'ActivityCondition'));
    for it = 1:length(targets)
      [signs_it, regulators_it] = parse_regulation_formula(conditions{it});
      my_regulators = [my_regulators; regulators_it];
      my_targets    = [my_targets; repmat(targets(it), length(regulators_it), 1)];
      my_signs      = [my_signs; signs_it(:)];
    end

  otherwise
    error('Unknown source %s', source);
end

% targets and regulators not declared in tables: taken from the arrows
if isempty(target_table),    targets    = unique_stable(my_targets);    end
if isempty(regulator_table), regulators = unique_stable(my_regulators); end

ind_t = label_names(my_targets, targets);
ind_r = label_names(my_regulators, regulators);
unknown = (ind_t == 0) | (ind_r == 0);
if any(unknown)
  warning('Regulation arrows with unknown targets or regulators are ignored: %s', ...
          strjoin(strcat(my_regulators(unknown), '->', my_targets(unknown))', ', '));
end

network.targets    = targets;
network.regulators = regulators;
network.arrows     = sparse(ind_t(~unknown), ind_r(~unknown), 1, length(targets), length(regulators));
network.arrows     = double(network.arrows ~= 0);
network.signs      = sparse(ind_t(~unknown), ind_r(~unknown), my_signs(~unknown), length(targets), length(regulators));
network.source     = source;

if any(network.signs(:) > 1 | network.signs(:) < -1)
  warning('Several arrows between the same regulator and target; their signs are added');
  network.signs = sign(network.signs);
end

% weights: SparseMatrix table with RowTable = target table type and ColumnTable = 'Regulator'
weight_table = [];
table_ids = fieldnames(sbtab_document.tables);
for it = 1:length(table_ids)
  a = sbtab_document.tables.(table_ids{it}).attributes;
  if isfield(a,'TableType') && strcmp(a.TableType,'SparseMatrix') && isfield(a,'RowTable') && isfield(a,'ColumnTable') ...
      && strcmp(a.RowTable, options.target_table_type) && strcmp(a.ColumnTable, options.regulator_table_type)
    weight_table = sbtab_document.tables.(table_ids{it});
    break
  end
end
if ~isempty(weight_table)
  w_rows = label_names(column(sbtab_table_get_column(weight_table,'RowID')), targets);
  w_cols = label_names(column(sbtab_table_get_column(weight_table,'ColumnID')), regulators);
  w_vals = column(sbtab_table_get_column(weight_table,'Value',1));
  ok = (w_rows ~= 0) & (w_cols ~= 0);
  if any(~ok)
    warning('Weights table: entries with unknown targets or regulators are ignored');
  end
  network.weights = sparse(w_rows(ok), w_cols(ok), w_vals(ok), length(targets), length(regulators));
  if any(network.weights(:) ~= 0 & network.arrows(:) == 0)
    warning('Weights table: weights for pairs without a regulation arrow');
  end
  network.weight_quantity_type = '';
  if isfield(weight_table.attributes,'QuantityType')
    network.weight_quantity_type = weight_table.attributes.QuantityType;
  end
end


% -------------------------------------------------------

function table = find_table(sbtab_document, table_type)

table = [];
table_ids = fieldnames(sbtab_document.tables);
for it = 1:length(table_ids)
  my_table = sbtab_document.tables.(table_ids{it});
  if isfield(my_table.attributes,'TableType') && strcmp(my_table.attributes.TableType, table_type)
    table = my_table;
    return
  end
end


% -------------------------------------------------------

function list = unique_stable(list)

[~, ind] = unique(list, 'stable');
list = column(list(ind));


% -------------------------------------------------------

function s = regulation_type_sign(entry)

% +1 (activation), -1 (inhibition), 0 (dual) or nan (empty or unknown) for an entry of
% the column RegulationType ('activation', 'inhibition', 'dual') or RegulationType:SBO

s = nan;
if ~ischar(entry) || isempty(strtrim(entry)), return; end
entry = lower(strtrim(entry));
sbo = regexp(entry, 'sbo:0*(\d+)', 'tokens', 'once');
if ~isempty(sbo)
  sbo = str2double(sbo{1});
  if any(sbo == [459, 21, 461, 462, 170, 171, 656]), s = 1;
  elseif any(sbo == [20, 206, 207, 536, 537, 169]), s = -1;
  elseif any(sbo == [595, 596]), s = 0;   % dual-activity modifier, modifier of unknown activity
  end
  return
end
switch entry
  case {'activation','activator','+'},  s = 1;
  case {'inhibition','inhibitor','-'},  s = -1;
  case {'dual','+-','unknown','?'},    s = 0;
end


% -------------------------------------------------------

function [signs, names] = parse_regulation_formula(formula)

% Kinetic regulation formula, e.g. '+ TF1 - TF2 +- TF3 ? TF4'
% signs: +1, -1, 0 (dual, unknown, or no sign); names: column cell array

signs = []; names = {};
if ~ischar(formula), return; end
tokens  = strsplit(strtrim(strrep(formula,'|',' ')));
my_sign = '';
for it = 1:length(tokens)
  token = tokens{it};
  if isempty(token), continue; end
  if any(strcmp(token,{'+','-','+-','?'})), my_sign = token; continue; end
  if strncmp(token,'+-',2) && length(token) > 2
    my_sign = '+-'; token = token(3:end);
  elseif any(token(1) == '+-?') && length(token) > 1
    my_sign = token(1); token = token(2:end);
  end
  switch my_sign
    case '+',  signs(end+1,1) = 1;
    case '-',  signs(end+1,1) = -1;
    otherwise, signs(end+1,1) = 0;
  end
  names{end+1,1} = token;
  my_sign = '';
end
