function sequence = fn_MFMC_read_sequence(fname, sequence_index)
%SUMMARY
%   Reads all the information about a specified MFMC sequence in a file
%   EXCEPT the MFMC data itself.
%AUTHOR
%   Paul Wilcox, November 2018
%INPUTS
%   fname - name of MFMC file
%   sequence_index - number of sequence to read
%OUTPUTS
%   sequence - structured variable containing all the information about
%   specified sequence.
%--------------------------------------------------------------------------

if ~fn_MFMC_prepare_to_write_or_read_file(fname)
    return
end

mfmc_root = fn_MFMC_utilities([], [], 'MFMC root');
mfmc_data_location = fn_MFMC_utilities([], [], 'MFMC location');
mfmc_data_location = regexprep(mfmc_data_location, '.+/', '');

mfmc_root = fn_MFMC_utilities(mfmc_root, sequence_index, 'replace symbolic index in list A with number B');

try
    sequence = fn_MFMC_read_into_matlab_structure(fname, mfmc_root, mfmc_data_location);
catch
    sequence = [];
    return;
end

%special bit for sequence - pull out size information from MFMC data if
%there is any in file
mfmc_data_location = fn_MFMC_utilities([], [], 'MFMC location');
if iscell(mfmc_data_location)
    mfmc_data_location = mfmc_data_location{1};
end

loc = fn_MFMC_utilities(mfmc_data_location, sequence_index, 'replace symbolic index in list A with number B');

try
    info = h5info(fname, loc);
    sequence.N_Tm = info.Dataspace.Size(1);
    sequence.N_Am = info.Dataspace.Size(2);
    sequence.N_Fm = info.Dataspace.Size(3);
catch
    sequence.N_Tm = 0;
    sequence.N_Am = 0;
    sequence.N_Fm = 0;
end

end