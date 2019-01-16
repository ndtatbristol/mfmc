clear;
close all;
clc;
restoredefaultpath;

global template_path
% 
template_path = ['..' filesep, 'Template'];
fname = ['..', filesep, 'Example MFMC files', filesep, 'from random numbers.mfmc'];
template_fname = '2.0.0-Beta.json';

N_P = 3; %number of probes
N_Ep_max = 32; %Max elements in any probe

N_M = 2; %number of sequences
N_Tm_max = 200; %max time points in any sequence
N_Am_max = 256; %max A-scans per frame in any sequence
N_Lm_max = 32; %max number of focal laws in any sequence
N_Clm_max = 1; %max number of entries in any focal law
N_Bm_max = 32; %max firing events per frame in any sequence

N_F_to_add = 2; %number of frame blocks to add
N_Fm = 3; %Frames per block in m-th sequence
raw_data_type = 'complex';

%--------------------------------------------------------------------------

%create output file
success = fn_MFMC_create_new_file(fname, template_fname);

%generate probe data
N_Ep = randi(N_Ep_max, N_P, 1); %elements in each probe 
for ii = 1:N_P
    probe(ii) = fn_generate_dummy_probe_data(N_Ep(ii));
end

%generate sequence data and a block of frames for each one
for ii = 1:N_M
%     sequence(ii) = fn_generate_dummy_sequence_data(N_Ep, N_Am, N_TEtm, N_REtm, N_P);
    N_Pm = randi(N_P, 1, 1); %number of probes involved
    N_Am = randi(N_Am_max, 1, 1); %A-scans per frame
    N_Lm = randi(N_Lm_max, 1, 1); %focal laws per frame
    sequence(ii) = fn_generate_dummy_sequence_data(N_Ep, N_Am, N_Lm, N_Clm_max, N_Pm);
    
    N_Tm = randi(N_Tm_max, 1, 1); %time points
    frame(ii) = fn_generate_dummy_frame_data(N_Tm, N_Am, N_Fm, N_Bm_max, N_Pm, raw_data_type);
end

%Uncomment one of following to introduce deliberate errors into MFMC file
%to test fn_MFMC_check_file function
% sequence(1).common = rmfield(sequence(1).common, 'transmit_focal_law'); % removal of optional group
% sequence(1).common.transmit_focal_law = rmfield(sequence(1).common.transmit_focal_law, 'delay'); % removal of mandatory dataset in optional group
% sequence(1).common.transmit_probe = sequence(1).common.transmit_probe(1:end-1);% removal of end of dataset to cause size mismatch

%--------------------------------------------------------------------------

%add probes to file
for ii = 1:length(probe)
    [probe_number, success] = fn_MFMC_add_probe(fname, probe(ii));
end

%add some sequences
for ii = 1:length(sequence)
    [sequence_number, success] = fn_MFMC_add_sequence(fname, sequence(ii));
end

%add number of frames to each sequence
for si = 1:length(sequence)
    for fi = 1:N_F_to_add
        success = fn_MFMC_add_frame_to_sequence(fname, si, frame(si));
    end
end

%--------------------------------------------------------------------------

[errors, warnings] = fn_MFMC_check_file(fname);

%--------------------------------------------------------------------------

fn_MFMC_file_summary(fname);


