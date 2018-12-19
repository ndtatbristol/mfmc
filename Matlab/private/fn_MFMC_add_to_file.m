function success = fn_MFMC_add_to_file(matlab_data, fname, hdf5_location, dataset, max_size, chunk_size, start, count)
%SUMMARY
%   This is the lowest level function that writes Matlab data (must be
%   scalar, matrix of string) to hdf5_location as dataset or attribute.
%   If hdf5_location already exists in file, then data is appended if
%   possible (i.e. if there is an inf dimension)

matlab_data_dimension = size(matlab_data);

%See if field already exists in hdf5 file
try
    tmp = h5info(fname, hdf5_location);
    current_size = tmp.Dataspace.Size;
    max_size = tmp.Dataspace.MaxSize;
    jj = find(isinf(max_size));
    if ~isempty(jj)
        start(jj) = current_size(jj) + 1;
    end
    new_field = 0;
catch
    %new field
    new_field = 1;
end

try
    if dataset
        %write dataset
        
        %see what the required HDF5 data class is
        matlab_class = class(matlab_data);
        
        %write to file
        if strcmp(matlab_class, 'string') || strcmp(matlab_class, 'char')
            %this always overwrites anyway
            fn_hdf5_write_string(fname, hdf5_location, matlab_data)
        else
            %create new field if nesc
            if new_field
                if ~isempty(chunk_size)
                    h5create(fname, hdf5_location, max_size, 'Datatype', matlab_class, 'ChunkSize', chunk_size);
                else
                    h5create(fname, hdf5_location, max_size, 'Datatype', matlab_class);
                end
            end
            h5write(fname, hdf5_location, matlab_data, start, count);
        end
    else
        %write attribute
        jj = strfind(hdf5_location, '/');
        if length(jj) > 1
            loc = hdf5_location(1:jj(end)-1);
            nm = hdf5_location(jj(end)+1:end);
        else
            loc = '/';
            nm = hdf5_location(2:end);
        end
        h5writeatt(fname, loc, nm, matlab_data);
    end
    success = 1;
catch
    fprintf('Error writing to file in fn_MFMC_add_to_file function\n');
    keyboard
    success = 0;
end
end