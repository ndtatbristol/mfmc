function sequence = fn_MFMC_read_sequence(fname, varargin)
%SUMMARY
%   Reads all the information about a specified MFMC sequence in a file (or
%   all sequences if second argument is omitted or empty) EXCEPT the MFMC
%   data itself.
%AUTHOR
%   Paul Wilcox, November 2018
%INPUTS
%   fname - name of MFMC file 
%   [sequence_index] - number of sequence to read
%OUTPUTS
%   sequence - structured variable containing all the information about
%   specified sequence. If no sequence_index was specified, then this will be an 
%   array, sequence(1...N_M), containing the information for all sequences
%   in the file
%--------------------------------------------------------------------------

if ~fn_MFMC_prepare_to_write_or_read_file(fname)
    return
end

if isempty(varargin)
    sequence_index = [];
else
    sequence_index = varargin{1};
end

mfmc_root = fn_MFMC_utilities([], [], 'MFMC root');
mfmc_data_location = fn_MFMC_utilities([], [], 'MFMC location');
mfmc_data_location = regexprep(mfmc_data_location, '.+/', '');

if isempty(sequence_index)
    mfmc_root = fn_MFMC_utilities(mfmc_root, [], 'remove trailing index from list A');
    sequence = fn_MFMC_read_into_matlab_structure(fname, mfmc_root, mfmc_data_location);
else
    mfmc_root = fn_MFMC_utilities(mfmc_root, sequence_index, 'replace symbolic index in list A with number B');
    sequence = fn_MFMC_read_into_matlab_structure(fname, mfmc_root, mfmc_data_location);
end

%special bit for sequence - pull out size information
mfmc_data_location = fn_MFMC_utilities([], [], 'MFMC location');
if iscell(mfmc_data_location)
    mfmc_data_location = mfmc_data_location{1};
end

for ii = 1:length(sequence)
    loc = fn_MFMC_utilities(mfmc_data_location, ii, 'replace symbolic index in list A with number B');
    info = h5info(fname, loc);
    sequence(ii).N_Fm = info.Dataspace.Size(3);
    sequence(ii).N_Tm = info.Dataspace.Size(1);
end

end