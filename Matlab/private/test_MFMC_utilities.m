clear;
close all;
clc;
restoredefaultpath;

output_mfmc_fname = 'test v1.2.mfmc';

template_fname = '../../Template/1.2 Beta.json';



%load template and dataset lists
template = jsondecode(fileread(template_fname));
% [dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(output_mfmc_fname);

%prime utilities function
fn_MFMC_utilities([], [], [], template);

% % A = '/MFMC';
% A = '/PROBE<1>/ELEMENT_SHAPE';
A = '/MFMC<2>/COMMON/TRANSMIT_FOCAL_LAW<12>/ELEMENT';
% A = {'/MFMC'; '/MFMC<7>/COMMON/USER';'/PROBE<1>/ELEMENT_SHAPE'; '/MFMC<2>/COMMON/TRANSMIT_FOCAL_LAW<12>/ELEMENT'};

% output = fn_MFMC_utilities(A, [], 'template location for file location A')

output = fn_MFMC_utilities('/MFMC<2>/COMMON/LAW<26>/ELEMENT', '/MFMC<m>/COMMON/LAW<l>/ELEMENT', 'match numeric indices in A to symbolic indices in B')

% output = fn_MFMC_utilities(A, [], 'is A valid location in template')
% 
% output = fn_MFMC_utilities({'/PROBE<p>/TEST'; '/PROBE<p>/SQ'}, 4, 'replace symbolic index in list A with number B')
% 
% % output = fn_MFMC_utilities('/PROBE<3>/ELEMENT_SHAPE', [], 'template index for file location A')
% 
% output = fn_MFMC_utilities('/PROBE<2>/SOME<7>', [], 'convert list A to matlab fields')
% 
% output = fn_MFMC_utilities('/PROBE<2>/SOME<7>', [], 'remove trailing index from list A')