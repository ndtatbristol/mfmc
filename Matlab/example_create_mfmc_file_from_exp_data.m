clear;
close all;
clc;
% restoredefaultpath;

global template_path

template_path = ['..' filesep, 'Template'];
input_exp_data_fnames = 'X:\Individuals\Paul\2012-06-22 QNDE data - weld scan\15 deg crack, offset *mm.mat';
fname = ['..', filesep, 'Example MFMC files', filesep, 'generated from exp_data files.mfmc'];
template_fname = 'MFMC template v1.2.json';

%--------------------------------------------------------------------------

success = fn_MFMC_create_new_file(fname, template_fname);

%read in frames from input file
if ~iscell(input_exp_data_fnames)
    tmp = dir(input_exp_data_fnames);
    input_exp_data_fnames = [];
    for ii = 1:length(tmp)
        input_exp_data_fnames{ii} = [tmp(ii).folder, filesep, tmp(ii).name];
    end
    
end

%TODO
% input_data = fn_read_into_matlab_structure(input_mfmc_fname);

%--------------------------------------------------------------------------

for fi = 1:length(input_exp_data_fnames)
    load(input_exp_data_fnames{fi});
    
    %get probe and sequence data from first file in sequence
    if fi == 1
        %generate probe data
        probe.element_position = [exp_data.array.el_xc; exp_data.array.el_yc; exp_data.array.el_zc];
        probe.element_minor = [exp_data.array.el_x1; exp_data.array.el_y1; exp_data.array.el_z1] - probe.element_position;
        probe.element_major = [exp_data.array.el_x2; exp_data.array.el_y2; exp_data.array.el_z2] - probe.element_position;
        probe.element_shape = int64(ones(size(probe.element_position, 2), 1));
        probe.centre_frequency = exp_data.array.centre_freq;
        
        %add probe to MFMC file
        [probe_number, success] = fn_MFMC_add_probe(fname, probe);

        %generate sequence data
        sequence.common.transmit_element = int64(exp_data.tx(:)); %N_(A,m)
        sequence.common.receive_element = int64(exp_data.rx(:)); %N_(A,m))
        sequence.common.transmit_probe = int64(ones(size(sequence.common.transmit_element))); %N_(A,m)
        sequence.common.receive_probe = int64(ones(size(sequence.common.receive_element))); %N_(A,m)
        sequence.common.firing_index = int64(sequence.common.transmit_element); %N_(A,m)
        sequence.common.time_step = exp_data.time(2) - exp_data.time(1); %1
        sequence.common.start_time = exp_data.time(1); %1
        sequence.common.specimen_velocity = [exp_data.ph_velocity / 2; exp_data.ph_velocity]; %2
        sequence.common.probe_list = int64(1);
        N_Pm = length(sequence.common.probe_list); %number of probes used in sequence
        
        N_Bm = length(unique(sequence.common.firing_index)); %number of different firing indices
        %add sequence to MFMC file
        [sequence_number, success] = fn_MFMC_add_sequence(fname, sequence);
    end
    
    %generate frame data
    N_Fm = 1; %number of frames added at a time
    frame.probe_position =       repmat([1, 0, 0]', [1, N_Bm, N_Pm, N_Fm]);%3×N_(B,m)×N_(P,m)×N_(F,m)
    frame.probe_x_direction =    repmat([1, 0, 0]', [1, N_Bm, N_Pm, N_Fm]);%3×N_(B,m)×N_(P,m)×N_(F,m)
    frame.probe_y_direction =    repmat([0, 1, 0]', [1, N_Bm, N_Pm, N_Fm]);%3×N_(B,m)×N_(P,m)×N_(F,m)
    frame.mfmc_data = exp_data.time_data; %N_(T,m)×N_(A,m)×N_(F,m)
    
    %add frame to MFMC file
    success = fn_MFMC_add_frame_to_sequence(fname, sequence_number, frame);
end

%--------------------------------------------------------------------------

fn_MFMC_file_summary(fname);

[errors, warnings] = fn_MFMC_check_file(fname);
