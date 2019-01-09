function fn_MFMC_file_dump(fname)
%SUMMARY
%   Dumps content of MFMC file to screen (or to text file - TODO)

fid = 1;

[probe, sequence] = fn_MFMC_file_summary(fname);

%probes
for ii = 1:length(probe)
    %need to convert back (!) from matlab names to HDF5 locations for
    %output purposes
    [hdf5_locations, matlab_field_names] = fn_MFMC_matlab_structure_to_hdf5_locations(probe(ii));
    for hi = 1:length(hdf5_locations)
        fprintf(fid, [hdf5_locations{hi}, '\n'])        
    end
    




end

