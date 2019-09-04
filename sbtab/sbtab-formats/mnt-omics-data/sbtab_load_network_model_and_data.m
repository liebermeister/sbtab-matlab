function result = sbtab_load_network_model_and_data(filename)

if 0,
  filename = '/home/wolfram/projekte/convex_model_balancing/matlab/convex-model-balancing/resources/data/data-organisms/human_hela/human_hela_ECM_Model.tsv';
end

s = sbtab_document_load_from_one(filename);

opt = struct;

result.network    = sbtab_to_network(s, opt);
result.state_data = sbtab_to_omics_data(s, opt);
result.options    = sbtab_to_options(s, opt);

