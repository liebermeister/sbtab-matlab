function [object,filename] = sbtab_load_example(example_name,type)

% [object,filename] = sbtab_load_example(example_name,type)
%
% Load an example file from the folder resources/examples
% (for the possible types, see sbtab_load_data_object)
%
% usage example: [object,filename] = sbtab_load_example('sbtab/ecoli_ccm_aerobic/ecoli_ccm_aerobic_ModelData.tsv','sbtab');

filename = fullfile(sbtab_resourcedir, 'examples', example_name);

object = sbtab_load_data_object(filename,type);
