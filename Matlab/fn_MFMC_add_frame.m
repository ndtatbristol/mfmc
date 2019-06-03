function fn_MFMC_add_frame(MFMC, ref_or_index_or_loc, FRAME)
%SUMMMAY
%   Adds frame(s) of data to sequence based on HDF5 reference, index or 
%   location of sequence.
%INPUTS
%   MFMC - MFMC structure (see fn_MFMC_open_file)
%   ref_or_index_or_loc - HDF5 reference, index or location of sequence
%   group to add to.
%   FRAME - frame of data to add with mandatory fields:
%       .MFMC_DATA
%       .PROBE_PLACEMENT_INDEX
%       .PROBE_POSITION
%       .PROBE_X_DIRECTION
%       .PROBE_Y_DIRECTION
%       and optional fields as per the MFMC file specification
%       Additional optional field .deflate_value can be used to specify
%       compression level from 0 (none) to 9 (max). If not specified,
%       default is 4.
%--------------------------------------------------------------------------
default_deflate_value = 4;

if isfield(FRAME, 'deflate_value')
    deflate_value = FRAME.deflate_value;
else
    deflate_value = default_deflate_value;
end

sequence_path = [fn_hdf5_ref_or_index_or_loc_to_loc(ref_or_index_or_loc, MFMC.fname, [MFMC.root_path, MFMC.sequence_name_template]), '/'];

tmp = fn_hdf5_read_to_matlab(MFMC.fname, sequence_path);

if ~strcmp(tmp.TYPE, 'SEQUENCE')
    error('Invalid sequence');
end

no_probes = size(tmp.PROBE_LIST, 1);
no_ascans = size(FRAME.PROBE_PLACEMENT_INDEX, 1);
no_time_pts = size(FRAME.MFMC_DATA, 1);

% Enforce constraint that each MFMC_DATA must be same size and same type
if (isfield(tmp,'MFMC_DATA'))
    [no_time_pts_in_file,no_ascans_in_file,~] = size(tmp.MFMC_DATA);
    if (no_time_pts_in_file ~= no_time_pts)
        error(['Invalid number of time points (',num2str(no_time_pts),') in new FRAME, must match with value in MFMC file (',num2str(no_time_pts_in_file),')'])
    end
    if (no_ascans_in_file ~= no_ascans)
        error(['Invalid number of A-scans (',num2str(no_ascans),') in new FRAME, must match with value in MFMC file (',num2str(no_ascans_in_file),')'])
    end
    if (strcmp(class(tmp.MFMC_DATA),class(FRAME.MFMC_DATA))<1)
        warning(['Mismatch between new FRAME.MFMC_DATA (',class(FRAME.MFMC_DATA),') and stored MFMC_DATA (',class(tmp.MFMC_DATA),') data types. Possible data loss']);
    end
end

fn_hdf5_add_to_dataset(FRAME, MFMC.fname, [sequence_path, 'MFMC_DATA'],             'M', [], [no_time_pts, no_ascans, inf], 3, deflate_value);
fn_hdf5_add_to_dataset(FRAME, MFMC.fname, [sequence_path, 'MFMC_DATA_IM'],          'O', [], [no_time_pts, no_ascans, inf], 3, deflate_value);
fn_hdf5_add_to_dataset(FRAME, MFMC.fname, [sequence_path, 'PROBE_PLACEMENT_INDEX'], 'M', [], [no_ascans, inf],              2);
fn_hdf5_add_to_dataset(FRAME, MFMC.fname, [sequence_path, 'PROBE_POSITION'],        'M', [], [3, no_probes, inf],           3);
fn_hdf5_add_to_dataset(FRAME, MFMC.fname, [sequence_path, 'PROBE_X_DIRECTION'],     'M', [], [3, no_probes, inf],           3);
fn_hdf5_add_to_dataset(FRAME, MFMC.fname, [sequence_path, 'PROBE_Y_DIRECTION'],     'M', [], [3, no_probes, inf],           3);

end