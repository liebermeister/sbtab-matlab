function sbtab = sbtab_network_state_save(network,c,v,filename)
  
% sbtab = sbtab_network_state_save(network,c,v,filename)
%
% Save a matlab 'network' structure, concentration vector c, and flux vector v to SBtab file
  
sbtab = network_to_sbtab(network,struct('c',c,'v',v));

sbtab_document_save(sbtab,filename);
