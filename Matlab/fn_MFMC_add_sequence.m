function [sequence_number, success] = fn_MFMC_add_sequence(fname, sequence)
%SUMMARY
%   Adds details of another sequence to file. This must be called before
%   frames of data can be added to sequence
%AUTHOR
%   Paul Wilcox, November 2018
%INPUTS
%   fname - name of MFMC file 
%   sequence - details of sequence to be added
%OUTPUTS
%   sequence_number - the index assigned to the seqeunce in the file
%   success - 1 if successful, 0 if not
%--------------------------------------------------------------------------

success = 0;
sequence_number = [];
if ~fn_MFMC_prepare_to_write_or_read_file(fname)
    return
end

%Get next free sequence number
mfmc_root = fn_MFMC_utilities([], [], 'MFMC root');
[dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(fname);
sequence_number = fn_MFMC_utilities(dataset_list, mfmc_root, 'next index from list A based on root B');

%Generate root location for sequence in file
hdf5_root = fn_MFMC_utilities(mfmc_root, sequence_number, 'replace symbolic index in list A with number B');
success = fn_MFMC_add_from_matlab_according_to_template(fname, sequence, hdf5_root);

end