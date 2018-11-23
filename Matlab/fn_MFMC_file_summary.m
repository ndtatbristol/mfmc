function varargout = fn_MFMC_file_summary(fname)
%SUMMARY
%   Provides a summary of contents of specified MFMC file
%AUTHOR
%   Paul Wilcox, November 2018
%INPUTS
%   fname - name of MFMC file 
%OUTPUTS
%   NB If no outputs specified, summary information is displaced in command
%   window.
%   [probe] - details of all probes in file
%   [sequence] - details of all sequences in file
%--------------------------------------------------------------------------

fn_MFMC_prepare_to_write_or_read_file(fname);

[dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(fname);

mfmc_root = fn_MFMC_utilities([], [], 'MFMC root');
mfmc_indices = fn_MFMC_utilities(dataset_list, mfmc_root, 'unique indices from list A based on root B');
probe_root = fn_MFMC_utilities([], [], 'probe root');
probe_indices = fn_MFMC_utilities(dataset_list, probe_root, 'unique indices from list A based on root B');

if nargout == 0
    [~, nm, ext] = fileparts(fname);
    fprintf(['File: ', nm, ext, '\n']);
    
    fprintf('    Probes (%i):\n', length(probe_indices));
    for ii = 1:length(probe_indices)
        probe = fn_MFMC_read_probe(fname, ii);
        fprintf('%8i: %i elements, %.1f MHz\n', ii, length(probe.element_shape), probe.centre_frequency / 1e6);
    end
    
    fprintf('    Sequences (%i):\n', length(mfmc_indices));
    for ii = 1:length(mfmc_indices)
        sequence = fn_MFMC_read_sequence(fname, ii);
        fprintf('%8i: %i frames (%i time points x %i A-scans)', ii, sequence.N_Fm,  sequence.N_Tm, length(sequence.common.firing_index));
        if isfield(sequence.common, 'operator')
            fprintf([' performed by ', sequence.common.operator]);
        end
        if isfield(sequence.common, 'date_and_time')
            fprintf([' at ', sequence.common.date_and_time]);
        end
        fprintf('\n');
        if isfield(sequence.common, 'transmit_focal_law')
            fprintf('        Transmit focal laws (%i)\n', length(sequence.common.transmit_focal_law));
            for jj = 1:length(sequence.common.transmit_focal_law)
                fprintf('%12i: %i elements\n', jj, length(sequence.common.transmit_focal_law(jj).element));
            end
        end
        if isfield(sequence.common, 'receive_focal_law')
            fprintf('        Receive focal laws (%i)\n', length(sequence.common.receive_focal_law));
            for jj = 1:length(sequence.common.receive_focal_law)
                fprintf('%12i: %i elements\n', jj, length(sequence.common.receive_focal_law(jj).element));
            end
        end
    end
else
    varargout{1} = fn_MFMC_read_probe(fname);
    varargout{2} = fn_MFMC_read_sequence(fname);
end

end