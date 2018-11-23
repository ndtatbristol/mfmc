function MFMC_data = fn_MFMC_read_frames(fname, sequence_index, varargin)
%SUMMARY
%   Reads specified MFMC frame(s) from sequence (or all frames if third
%   argument ommitted)
%AUTHOR
%   Paul Wilcox, November 2018
%INPUTS
%   fname - name of MFMC file
%   sequence_index - number of sequence to read from
%   [frame_index] - index(s) of frames to read from sequence
%OUTPUTS
%   MFMC_data - the MFMF frames read
%--------------------------------------------------------------------------

MFMC_data = [];
if ~fn_MFMC_prepare_to_write_or_read_file(fname)
    return
end

if isempty(varargin)
    frame_index = [];
else
    frame_index = varargin{1};
end

mfmc_root = fn_MFMC_utilities([], [], 'MFMC root');
mfmc_root = fn_MFMC_utilities(mfmc_root, sequence_index, 'replace symbolic index in list A with number B');
mfmc_data_location = fn_MFMC_utilities([], [], 'MFMC location');

if ~iscell(mfmc_data_location)
    mfmc_data_location{1} = mfmc_data_location;
end
for ii = 1:length(mfmc_data_location)
    hdf5_location{ii} = [mfmc_root, '/', regexprep(mfmc_data_location{ii}, '.+/', '')];
end

if isempty(frame_index)
    %read in all frames
    try
        MFMC_data = h5read(fname, hdf5_location{1});
    catch
        fprintf('No data\n');
        return
    end
    try
        MFMC_data = MFMC_data + 1i * h5read(fname, hdf5_location{2});
    catch
        %         fprintf('No imaginary data\n');
    end
else
    %read in specific frames
    for ii = 1:length(frame_index)
        try
            if ii == 1
                tmp = h5read(fname, hdf5_location{1}, [1, 1, frame_index(ii)], [inf, inf, 1]);
                MFMC_data = zeros(size(tmp,1), size(tmp,2),length(frame_index));
                MFMC_data(:, :, ii) = tmp;
            else
                MFMC_data(:, :, ii) = h5read(fname, hdf5_location{1}, [1, 1, frame_index(ii)], [inf, inf, 1]);
            end
        catch
            fprintf('No data in frame %i\n', frame_index(ii));
            continue
        end
        try
            MFMC_data = MFMC_data + 1i * h5read(fname, hdf5_location{2}, [1, 1, frame_index(ii)], [inf, inf, 1]);
        catch
            %         fprintf('No imaginary data in frame %i\n', frame_index(ii));
        end
    end
end


end