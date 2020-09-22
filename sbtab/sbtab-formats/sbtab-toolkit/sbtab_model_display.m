function sbtab_model_display(sbtab_file)

sbtab_object = sbtab_document_load(sbtab_file);
sbtab_document_print(sbtab_object)
network = sbtab_to_network(sbtab_file);
kinetics = network.kinetics
netgraph_concentrations(network,[],[],1);