clear;
close all;
clc;
restoredefaultpath;

global template_path

% use_case = '1. single array, single sequence, single frame';
use_case = '2. single array, single sequence, three frames';

template_path = ['..' filesep, 'Template'];
template_fname = '1.0.0-Beta.json';

%--------------------------------------------------------------------------
switch use_case
    case {'1. single array, single sequence, single frame', '2. single array, single sequence, three frames'}
        %Probes - for multiple probes just make these into vectors, one
        %element per probe
        N_Ep = 4; %Elements in any probe
        E_pitch = 1e-3; %Element pitch
        E_width = 0.9e-3; %Element width
        E_length = 10e-3; %Element length
        
        %Sequence
        N_Tm = 10; %Time points
        Mode = {'FMC'}; %FMC or HMC
        long_vel = 6000;
        shear_vel = 3000;
        time_start = 0;
        time_step = 1/50e6;
        centre_frequency = 5e6;
        raw_data_type = 'int8';
        pos_change = [10e-3;0;0];
        switch use_case
            case '1. single array, single sequence, single frame'
                frames_to_add = 1;
            case '2. single array, single sequence, three frames'
                frames_to_add = 3;
        end
end

%--------------------------------------------------------------------------
fname = ['..', filesep, 'Example MFMC files', filesep, use_case, '.mfmc'];

%create output file
success = fn_MFMC_create_new_file(fname, template_fname);

%generate probe data
for ii = 1:length(N_Ep)
    tmp = [1:N_Ep(ii)] * E_pitch; tmp = tmp - mean(tmp);
    probe(ii).element_position = [tmp; zeros(2, N_Ep(ii))];
    probe(ii).element_minor = repmat([E_width(ii) / 2; 0; 0], [1, N_Ep(ii)]);
    probe(ii).element_major = repmat([0; E_length(ii) / 2; 0], [1, N_Ep(ii)]);
    probe(ii).element_shape = int64(ones(N_Ep(ii), 1));
    probe(ii).centre_frequency = centre_frequency;
end

%generate sequence/common data
tmp = 1:N_Ep(1);
[tx, rx] = meshgrid(tmp, tmp);
switch Mode{ii}
    case 'FMC'
        tx = tx(:);
        rx = rx(:);
        
    case 'HMC'
        tx = tx(find(triu(tx)));
        rx = rx(find(triu(rx)));
end

sequence.common.probe_index = int64(1);
sequence.common.transmit_law_index = int64(tx);
sequence.common.receive_law_index = int64(rx);

for jj = 1:length(tmp);
    sequence.common.law(jj, 1).probe = int64(1);
    sequence.common.law(jj, 1).element = int64(tmp(jj));
end

sequence.common.time_step = time_step; %1
sequence.common.start_time = time_start; %1
sequence.common.specimen_velocity = [shear_vel; long_vel]; %2

%frame of data
frame.probe_placement_index =   int64(ones(length(sequence.common.transmit_law_index), 1));
frame.probe_position =          [0; 0; 0]; 
frame.probe_x_direction =       [1; 0; 0];
frame.probe_y_direction =       [0; 1; 0];

frame.mfmc_data = randn(N_Tm, length(sequence.common.transmit_law_index), 1);
switch raw_data_type
    case 'int8'
        frame.mfmc_data = int8(frame.mfmc_data);
    case 'int16'
        frame.mfmc_data = int16(frame.mfmc_data);
    case 'complex'
        frame.mfmc_data_im = rand(size(frame.mfmc_data));
end


%add probes to file
for ii = 1:length(probe)
    [probe_number, success] = fn_MFMC_add_probe(fname, probe(ii));
end

%add sequence/common
    [sequence_number, success] = fn_MFMC_add_sequence(fname, sequence);

%add number of frames to each sequence
for fi = 1:frames_to_add
    success = fn_MFMC_add_frame_to_sequence(fname, 1, frame);
    frame.probe_position = frame.probe_position + pos_change;
    frame.probe_placement_index = frame.probe_placement_index + 1;
end

%--------------------------------------------------------------------------

[errors, warnings] = fn_MFMC_check_file(fname);

%--------------------------------------------------------------------------

fn_MFMC_file_summary(fname);


