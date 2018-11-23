function success = fn_MFMC_add_frame_to_sequence(fname, sequence_number, frame)
%SUMMARY
%   Adds frame(s) of MFMC data to existing sequence in file
%INPUTS
%   fname - name of MFMC file 
%   sequence_number - number of sequence to add frame(s) so
%   frame - frame(s) of MFMC data
%OUTPUTS
%   success - 1 if successful, 0 if not
%--------------------------------------------------------------------------

success = 0;
if ~fn_MFMC_prepare_to_write_or_read_file(fname)
    return
end

%Work out root location of sequence in file
mfmc_root = fn_MFMC_utilities([], [], 'MFMC root');
hdf5_root = fn_MFMC_utilities(mfmc_root, sequence_number, 'replace symbolic index in list A with number B');

%Check if sequence exists
try
    h5info(fname, hdf5_root);
catch
    fprintf('Sequence does not exist.\n');
    success = 0;
    return
end

%Write frame(s) to sequence
success = fn_MFMC_add_from_matlab_according_to_template(fname, frame, hdf5_root);
end