function no_frames = fn_MFMC_get_no_frames(MFMC, ref_or_index_or_loc)
%SUMMMAY
%   Returns number of frames in specified sequence
%INPUTS
%   MFMC - MFMC structure (see fn_MFMC_open_file)
%   ref_or_index_or_loc - HDF5 reference, index or location of sequence
%OUTPUTS
%   no_frames - number of frames in sequence
%--------------------------------------------------------------------------
sequence_path = [fn_hdf5_ref_or_index_or_loc_to_loc(ref_or_index_or_loc, MFMC.fname, [MFMC.root_path, MFMC.sequence_name_template]), '/'];

try
    a = h5info(MFMC.fname, [sequence_path, 'MFMC_DATA']);
    no_frames = a.Dataspace.Size(3);
catch
    %case if sequence exists
    no_frames = 0;
end
        
    

end
