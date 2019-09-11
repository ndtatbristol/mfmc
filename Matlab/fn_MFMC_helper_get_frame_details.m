function seq = fn_MFMC_helper_get_frame_details(fname, seq_ref)

MFMC.fname = fname; 
MFMC.root_path = '/';
MFMC.sequence_name_template = ''; %not needed, but field needs to exist
MFMC.probe_name_template = ''; %not needed, but field needs to exist
MFMC.law_name_template = ''; %not needed, but field needs to exist

seq = fn_MFMC_read_sequence(MFMC, seq_ref);
end