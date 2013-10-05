function my_table = sbtab_table_save(my_sbtab_table, options)

% my_table = sbtab_table_save(my_sbtab_table, options)
%
% options.filename
% options.omit_declarations
% options.flag_latex
%
% OR: options itself contains the filename

eval(default('options','struct'));

if isstr(options), 
  options = struct('filename',options);
end

options_default = struct('filename',[],'omit_declarations',0,'flag_latex',0);
options         = join_struct(options_default,options);

if options.flag_latex,
 options.omit_declarations = 1; 
end

% example_file filename = '~/matlab/wolf_packages/sbtab/data/sbtab_omics_row_example.tsv';

my_table = {'!!SBtab'};
% fn = fieldnames(my_sbtab_table.attributes);
% for it = 1:length(fn),
%   my_table{1,1} = [   my_table{1,1} ' ' fn{it} '="' my_sbtab_table.attributes.(fn{it}) '"'];
% end

for it = 2:length(my_sbtab_table.attributes),
  my_table{1,1} = [   my_table{1,1} ' ' my_sbtab_table.attributes{it}];
end


fn = fieldnames(my_sbtab_table.rows);
n_rows = length(fn); 
for it = 1:n_rows,
  fnn = fn{it};
  switch fnn,
    case 'MiriamID__urn_miriam_kegg_compound',  % compatibility to older SBtab files
      fnn = 'Identifiers:kegg.compound'; 
    case 'MiriamID__urn_miriam_kegg_reaction',  % compatibility to older SBtab files
      fnn = 'Identifiers:kegg.reaction'; 
    case 'MiriamID__urn_miriam_ec_code',  % compatibility to older SBtab files
      fnn = 'Identifiers:ec-code';     
    case 'SBML__reaction__ID',  % compatibility to older SBtab files
      fnn = 'SBML:reaction:ID'; 
    case 'SBML__species__ID',  % compatibility to older SBtab files
      fnn = 'SBML:species:ID'; 
    case 'Identifiers_kegg_compound',
      fnn = 'Identifiers:kegg.compound'; 
    case 'Identifiers_kegg_reaction',
      fnn = 'Identifiers:kegg.reaction'; 
    case 'Identifiers_ec_code',
      fnn = 'Identifiers:ec-code';    
    case 'SBML_reaction_ID',
      fnn = 'SBML:reaction::ID'; 
    case 'SBML_species_ID',
      fnn = 'SBML:species:ID'; 
  end
  nc = length(my_sbtab_table.rows.(fn{it}));
  my_table(2+it,1:nc) = my_sbtab_table.rows.(fn{it});
  my_table{2+it,1}    = ['!' fnn];
end

cn = my_sbtab_table.column.column_names;
fn = fieldnames(my_sbtab_table.column.column);
nr = length(my_sbtab_table.column.column.(fn{1}));
for it = 1:length(fn),
  fnn = cn{it};
  %%fnn = fn{it};
  %%switch fnn,
  %%  case 'MiriamID__urn_miriam_kegg_compound',
  %%    fnn = 'MiriamID::urn:miriam:kegg.compound'; 
  %%  case 'MiriamID__urn_miriam_kegg_reaction',
  %%    fnn = 'MiriamID::urn:miriam:kegg.reaction'; 
  %%  case 'MiriamID__urn_miriam_ec_code',
  %%    fnn = 'MiriamID::urn:miriam:ec-code'; 
  %%  case 'SBML__reaction__ID',
  %%    fnn = 'SBML::reaction::ID'; 
  %%  case 'SBML__species__ID',
  %%    fnn = 'SBML::species::ID'; 
  %%end
  my_table{2,my_sbtab_table.column.ind(it)} = ['!' fnn];
  if isnumeric(my_sbtab_table.column.column.(fn{it})),
%    my_sbtab_table.column.column.(fn{it}) = cellstr(num2str(my_sbtab_table.column.column.(fn{it})));
    my_sbtab_table.column.column.(fn{it}) = num2cell(my_sbtab_table.column.column.(fn{it}));
  end
  my_table(2+n_rows+(1:nr),my_sbtab_table.column.ind(it)) = my_sbtab_table.column.column.(fn{it});
end

for it = 1:length(my_sbtab_table.data.ind),
  my_table{2,my_sbtab_table.data.ind(it)} = my_sbtab_table.data.headers{it};
  my_table(2+n_rows+(1:nr),my_sbtab_table.data.ind(it)) = my_sbtab_table.data.data(:,it);
end

for it = 1:length(my_sbtab_table.uncontrolled.ind),
  my_table{2,my_sbtab_table.uncontrolled.ind(it)} = my_sbtab_table.uncontrolled.headers{it};
  my_table(2+n_rows+(1:nr),my_sbtab_table.uncontrolled.ind(it)) = my_sbtab_table.uncontrolled.data(:,it);
end

if options.omit_declarations,
 my_table = my_table(2:end,:);
end

if length(options.filename),
  if options.flag_latex,
    for it = 1:size(my_table,2), my_table{1,it} = [ '\bf{' strrep(my_table{1,it},'!','') '}']; end
    table(my_table,'tex',options.filename);
  else,
    table(my_table,0,options.filename);
  end
end
