function [network,c,v] = sbtab_network_state_load(filename)

% [network,c,v] = sbtab_network_state_load(filename)
%
% Load 'network' data structure, concentration vector 'c', and flux vector 'v' from SBtab file
  
sbtab = sbtab_document_load(filename);

network = sbtab_to_network(sbtab);
sbtab_c = sbtab_to_struct(sbtab_document_get_table(sbtab,'MetaboliteConcentration'),'column');
sbtab_v = sbtab_to_struct(sbtab_document_get_table(sbtab,'Flux'),'column');

ll = label_names(network.metabolites,sbtab_c.Metabolite);
c  = cell_string2num(sbtab_c.Value(ll));

ll = label_names(network.actions,sbtab_v.Reaction);
v  = cell_string2num(sbtab_v.Value(ll));