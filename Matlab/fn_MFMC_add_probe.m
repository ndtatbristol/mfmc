function [probe_number, success] = fn_MFMC_add_probe(fname, probe)
%SUMMARY
%   Adds details of another probe to file.
%AUTHOR
%   Paul Wilcox, November 2018
%INPUTS
%   fname - name of MFMC file 
%   probe - details of probe to be added
%OUTPUTS
%   probe_number - the index assigned to the probe in the file
%   success - 1 if successful, 0 if not
%--------------------------------------------------------------------------

probe_number = [];
success = 0;
if ~fn_MFMC_prepare_to_write_or_read_file(fname)
    return
end

%Get next free probe number
probe_root = fn_MFMC_utilities([], [], 'probe root');
[dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(fname);
probe_number = fn_MFMC_utilities(dataset_list, probe_root, 'next index from list A based on root B');

%Generate root location for probe in file
hdf5_root = fn_MFMC_utilities(probe_root, probe_number, 'replace symbolic index in list A with number B');
success = fn_MFMC_add_from_matlab_according_to_template(fname, probe, hdf5_root);

end