clear;
close all;
clc;
restoredefaultpath;


output_mfmc_fname = 'test v1.2.mfmc';

template_fname = 'MFMC template v1.2.json';



%load template and dataset lists
template = jsondecode(fileread(template_fname));
[dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(output_mfmc_fname);

%prime utilities function
fn_MFMC_utilities([], [], [], template);

output = fn_MFMC_utilities(dataset_list, '/MFMC', 'extract numerical indices from list A based on root B')

output = fn_MFMC_utilities(dataset_list, '/PROBE', 'next index from list A based on root B')

output = fn_MFMC_utilities({'/PROBE<p>/TEST'; '/PROBE<p>/SQ'}, 4, 'replace symbolic index in list A with number B')

% output = fn_MFMC_utilities('/PROBE<3>/ELEMENT_SHAPE', [], 'template index for file location A')

output = fn_MFMC_utilities('/PROBE<2>/SOME<7>', [], 'convert list A to matlab fields')

output = fn_MFMC_utilities('/PROBE<2>/SOME<7>', [], 'remove trailing index from list A')