function probe = fn_MFMC_read_probe(fname, varargin)
%SUMMARY
%   Reads all the information about a specified probe in a file (or
%   all probes if second argument is omitted or empty).
%AUTHOR
%   Paul Wilcox, November 2018
%INPUTS
%   fname - name of MFMC file 
%   [probe_index] - number of sequence to read
%OUTPUTS
%   probe - structured variable containing all the information about
%   specified probe. If no probe_index was specified, then this will be an 
%   array, probe(1...N_P), containing the information for all probes in 
%   the file
%--------------------------------------------------------------------------

if ~fn_MFMC_prepare_to_write_or_read_file(fname)
    return
end

if isempty(varargin)
    probe_index = [];
else
    probe_index = varargin{1};
end

probe_root = fn_MFMC_utilities([], [], 'probe root');

if isempty(probe_index)
    probe_root = fn_MFMC_utilities(probe_root, [], 'remove trailing index from list A');
    probe = fn_MFMC_read_into_matlab_structure(fname, probe_root);
else
    probe_root = fn_MFMC_utilities(probe_root, probe_index, 'replace symbolic index in list A with number B');
    probe = fn_MFMC_read_into_matlab_structure(fname, probe_root);
end

end