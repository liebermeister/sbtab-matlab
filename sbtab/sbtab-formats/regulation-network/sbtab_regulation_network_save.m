function sbtab_document = sbtab_regulation_network_save(network, filename, options)

% SBTAB_REGULATION_NETWORK_SAVE Write a regulation network (arrows and signs) to an SBtab document
%
% sbtab_document = sbtab_regulation_network_save(network, filename, options)
%
% Writes a network of regulation arrows, e.g. a transcription network, as an SBtab document
% with the tables
%   Gene       targets (columns !ID, !Name; the names are the IDs)
%   Regulator  regulators (columns !ID, !Name, !Type, e.g. 'transcriptional regulator')
%   Regulation one row per arrow (SBtab 1.2; default), with the columns !ID, !Regulator,
%              !Target, !RegulatorType, !TargetType, !RegulationType ('activation',
%              'inhibition', or 'unknown')
% or, with options.format = 'ActivityCondition', instead of the Regulation table a column
% !ActivityCondition in the Gene table, listing the regulators of each target as a kinetic
% regulation formula (e.g. '+ TF1 - TF2 ? TF3'; '?': unknown sign).
% If network.weights is given, the weights of the arrows are written to a SparseMatrix
% table (TableID 'RegulationWeight'; columns !RowID, !ColumnID, !Value; table attributes
% RowTable, ColumnTable and QuantityType, see options.weight_quantity_type).
%
% Inputs
%   network   struct with fields targets, regulators (cell arrays of IDs), arrows
%             (targets x regulators; nonzero for each arrow), signs (targets x regulators:
%             +1, -1, 0 unknown; optional), weights (targets x regulators; optional),
%             see sbtab_regulation_network_load
%   filename  output file (.tsv); if empty, no file is written
%   options   struct with (optional) fields
%     .format          'Regulation' (default) or 'ActivityCondition'
%     .document_name   document name (default 'regulation_network')
%     .target_table_type   table type of the targets (default 'Gene')
%     .target_type     entity type of the targets, column !TargetType (default 'gene')
%     .regulator_type  entity type of the regulators, columns !Type and !RegulatorType
%                      (default 'transcriptional regulator')
%     .weight_quantity_type  quantity type of the weights (table attribute QuantityType;
%                      default: network.weight_quantity_type if given, otherwise
%                      'regulation weight (log scale)'; for weights relating expression
%                      and regulator activities on linear scale: 'regulation weight (linear scale)')
%
% Output: the SBtab document object
%
% See also: sbtab_regulation_network_load

eval(default('filename','[]','options','struct'));
if isempty(options), options = struct; end
options = join_struct(struct('format','Regulation','document_name','regulation_network', ...
                             'target_table_type','Gene','target_type','gene', ...
                             'regulator_type','transcriptional regulator'), options);
if ~isfield(options,'weight_quantity_type')
  if isfield(network,'weight_quantity_type') && ~isempty(network.weight_quantity_type)
    options.weight_quantity_type = network.weight_quantity_type;
  else
    options.weight_quantity_type = 'regulation weight (log scale)';
  end
end

targets    = column(network.targets);
regulators = column(network.regulators);
arrows     = network.arrows ~= 0;
if isfield(network,'signs') && ~isempty(network.signs)
  signs = sign(full(network.signs)) .* arrows;
else
  signs = zeros(size(arrows));
end

% column !Name (required for entity tables; here equal to the IDs)
target_table = sbtab_table_construct(struct('TableID',options.target_table_type,'TableType',options.target_table_type), {'ID','Name'}, {targets, targets});
regulator_table = sbtab_table_construct(struct('TableID','Regulator','TableType','Regulator'), {'ID','Name','Type'}, ...
                                        {regulators, regulators, repmat({options.regulator_type}, length(regulators), 1)});

switch options.format

  case 'Regulation'
    [ind_t, ind_r] = find(arrows);
    % arrows ordered by regulator, then by target
    [~, order] = sortrows([ind_r ind_t]);
    ind_t = ind_t(order); ind_r = ind_r(order);
    n = length(ind_t);
    regulation_type = repmat({'unknown'}, n, 1);
    my_signs = signs(sub2ind(size(signs), ind_t, ind_r));
    regulation_type(my_signs ==  1) = {'activation'};
    regulation_type(my_signs == -1) = {'inhibition'};
    ids = cellstr(num2str((1:n)', 'Reg%d'));
    ids = strrep(ids, ' ', '');
    regulation_table = sbtab_table_construct(struct('TableID','Regulation','TableType','Regulation'), ...
        {'ID','Regulator','Target','RegulatorType','TargetType','RegulationType'}, ...
        {ids, regulators(ind_r), targets(ind_t), repmat({options.regulator_type}, n, 1), ...
         repmat({options.target_type}, n, 1), regulation_type});
    sbtab_document = sbtab_document_construct(struct('Document',options.document_name), ...
        {options.target_table_type, 'Regulator', 'Regulation'}, {target_table, regulator_table, regulation_table});

  case 'ActivityCondition'
    conditions = cell(length(targets), 1);
    for it = 1:length(targets)
      terms = {};
      for ir = find(arrows(it,:))
        switch signs(it,ir)
          case  1, terms{end+1} = ['+ ' regulators{ir}];
          case -1, terms{end+1} = ['- ' regulators{ir}];
          otherwise, terms{end+1} = ['? ' regulators{ir}];
        end
      end
      conditions{it} = strjoin(terms, ' ');
    end
    target_table = sbtab_table_add_column(target_table, 'ActivityCondition', conditions);
    sbtab_document = sbtab_document_construct(struct('Document',options.document_name), ...
        {options.target_table_type, 'Regulator'}, {target_table, regulator_table});

  otherwise
    error('Unknown format %s', options.format);
end

% weights of the arrows (SparseMatrix table)
if isfield(network,'weights') && ~isempty(network.weights)
  [ind_t, ind_r] = find(arrows);
  [~, order] = sortrows([ind_r ind_t]);
  ind_t = ind_t(order); ind_r = ind_r(order);
  weights = full(network.weights);
  weight_table = sbtab_table_construct(struct('TableID','RegulationWeight','TableType','SparseMatrix', ...
      'RowTable',options.target_table_type,'ColumnTable','Regulator','QuantityType',options.weight_quantity_type), ...
      {'RowID','ColumnID','Value'}, {targets(ind_t), regulators(ind_r), weights(sub2ind(size(weights), ind_t, ind_r))});
  sbtab_document = sbtab_document_add_table(sbtab_document, 'RegulationWeight', weight_table);
end

if ~isempty(filename)
  sbtab_document_save(sbtab_document, filename, 0, 0, 1, '1.2');
end
