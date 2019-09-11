function [names, SEQUENCE] = fn_MFMC_helper_get_sequences(fname)
%SUMMARY
%Returns a cell array of names (and full details) of all MFMC sequences in
%given file. Will throw error if file does not exist

MFMC.fname = fname; 
MFMC.root_path = '/';
MFMC.sequence_name_template = ''; %not needed, but field needs to exist
MFMC.probe_name_template = ''; %not needed, but field needs to exist
MFMC.law_name_template = ''; %not needed, but field needs to exist
[PROBE, SEQUENCE] = fn_MFMC_get_probe_and_sequence_refs(MFMC);
for ii = 1:length(SEQUENCE)
     names{ii} = SEQUENCE{ii}.name;
end

end