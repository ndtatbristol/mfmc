clear;
close all;
clc;
% restoredefaultpath;

global template_path

template_path = ['..' filesep, 'Template'];
fname = ['..', filesep, 'Example MFMC files', filesep, 'from random numbers.mfmc'];
template_fname = 'MFMC template v1.2.json';

N_P = 10; %number of probes
N_M = 2; %number of sequences
N_F_to_add = 2; %number of frame blocks to add
N_Tm = 200; %time points in m-th sequence
N_Am = 256; %A-scans per frame in m-th sequence
N_Fm = 3; %Frames per block in m-th sequence
N_Ep = 32; %Elements in p-th probe
N_Bm = 32; %Transmission events per frame in m-th sequence
% N_Pm = 4; %Number of probes in m-th sequence
N_TEtm = [3, 5, 7]; %Number of elements in t-th transmit focal law in m-th sequence
N_REtm = [4, 6, 8]; %Number of elements in r-th receive focal law in m-th sequence
raw_data_type = 'complex';
complex = 1;

%--------------------------------------------------------------------------

%create output file
success = fn_MFMC_create_new_file(fname, template_fname);

%generate probe data
for ii = 1:N_P
    probe(ii) = fn_generate_dummy_probe_data(N_Ep);
end

%generate sequence data and a block of frames for each one
for ii = 1:N_M
    sequence(ii) = fn_generate_dummy_sequence_data(N_Ep, N_Am, N_TEtm, N_REtm, N_P);
    N_Pm = length(sequence(ii).common.probe_list);
    frame(ii) = fn_generate_dummy_frame_data(N_Tm, N_Am, N_Fm, N_Bm, N_Pm, raw_data_type);
end

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

fn_MFMC_file_summary(fname);

[errors, warnings] = fn_MFMC_check_file(fname);
