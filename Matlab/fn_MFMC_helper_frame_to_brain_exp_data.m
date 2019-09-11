function exp_data = fn_MFMC_helper_frame_to_brain_exp_data(fname, varargin)
%SUMMARY
%   Returns specified frame of FMC data from specified sequence in MFMC
%   file in Bristol Matlab exp_data format. If sequence not specified the
%   first one found in the file will be used, and if frame_index is not
%   specified the first frame in the sequence will be returned.
%INPUTS
%   fname - filename (and path) of MFMC file
%   [seq_ref] - reference to desired sequence in MFMC file. If empty
%   (default) then first sequence in file is used
%   [frame_index] - index of frame in sequence to return. If not specified
%   or empty or null, first frame is used.
%OUTPUTS
%   exp_data - FMC in Bristol Brain matlab format
%--------------------------------------------------------------------------

if length(varargin) < 1
    seq_ref = [];
else
    seq_ref = varargin{1};
end
if length(varargin) < 2
    frame_index = [];
else
    frame_index = varargin{2};
end

MFMC.fname = fname; 
MFMC.root_path = '/';
MFMC.sequence_name_template = ''; %not needed, but field needs to exist
MFMC.probe_name_template = ''; %not needed, but field needs to exist
MFMC.law_name_template = ''; %not needed, but field needs to exist

if isempty(seq_ref)
    [names, SEQUENCE] = fn_MFMC_helper_get_sequences(fname);
    if length(SEQUENCE) > 1
        warning('MFMC file contains multiple sequences. Using first sequence.');
    end
    seq_ref = SEQUENCE{1}.ref;
end

seq = fn_MFMC_read_sequence(MFMC, seq_ref);

if isempty(frame_index)
    no_frames = fn_MFMC_get_no_frames(MFMC, seq_ref);
    if no_frames > 1
        warning('MFMC sequence contains multiple frames. Returning first frame.');
    end
    frame_index = 1;
end

frame = fn_MFMC_read_frame(MFMC, seq_ref, frame_index);

%check number of probes and add to exp_data
no_probes = size(seq.PROBE_LIST, 1);
if no_probes > 1
    error('Multiple probe not supported in Brain exp_data format');
else
    probe_ref = seq.PROBE_LIST(1,:);
end
PROBE = fn_MFMC_read_probe(MFMC, probe_ref);
exp_data.array.el_xc = PROBE.ELEMENT_POSITION(1,:);
exp_data.array.el_yc = PROBE.ELEMENT_POSITION(2,:);
exp_data.array.el_zc = PROBE.ELEMENT_POSITION(3,:);
exp_data.array.el_x1 = PROBE.ELEMENT_POSITION(1,:) + PROBE.ELEMENT_MAJOR(1,:);
exp_data.array.el_y1 = PROBE.ELEMENT_POSITION(2,:) + PROBE.ELEMENT_MAJOR(2,:);
exp_data.array.el_z1 = PROBE.ELEMENT_POSITION(3,:) + PROBE.ELEMENT_MAJOR(3,:);
exp_data.array.el_x2 = PROBE.ELEMENT_POSITION(1,:) + PROBE.ELEMENT_MINOR(1,:);
exp_data.array.el_y2 = PROBE.ELEMENT_POSITION(2,:) + PROBE.ELEMENT_MINOR(2,:);
exp_data.array.el_z2 = PROBE.ELEMENT_POSITION(3,:) + PROBE.ELEMENT_MINOR(3,:);
exp_data.array.centre_freq = PROBE.CENTRE_FREQUENCY;

%check focal laws are for single TX-RX combos and add to exp_data
no_ascans = size(frame, 2);
exp_data.tx = zeros(1, no_ascans);
exp_data.rx = zeros(1, no_ascans);
for ii = 1:size(seq.TRANSMIT_LAW, 1)
     law = fn_MFMC_read_law(MFMC, seq.TRANSMIT_LAW(ii, :));
     if length(law.ELEMENT) > 1
         error('Multiple transmit elements not supported in Brain exp_data format');
     end
     exp_data.tx(ii) = law.ELEMENT(1);
end
for ii = 1:size(seq.RECEIVE_LAW, 1)
     law = fn_MFMC_read_law(MFMC, seq.RECEIVE_LAW(ii, :));
     if length(law.ELEMENT) > 1
         error('Multiple receive elements not supported in Brain exp_data format');
     end
     exp_data.rx(ii) = law.ELEMENT;
end

%add the time axis and actual data to exp_data
exp_data.time = [0:size(frame, 1) - 1]' * seq.TIME_STEP + seq.START_TIME;
exp_data.time_data = double(frame);
exp_data.ph_velocity = seq.SPECIMEN_VELOCITY(2);

end