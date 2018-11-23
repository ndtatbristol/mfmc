function success = fn_MFMC_add_from_matlab_according_to_template(fname, matlab_struct, hdf5_root)
%SUMMARY
%   Adds to HDF5 file based on Matlab structure and specified template
%   Note: HDF5 dimension order will match Matlab dimension order

success = 1;

[hdf5_locations, matlab_field_names] = fn_MFMC_matlab_structure_to_hdf5_locations(matlab_struct);
for ii = 1:length(hdf5_locations)
    %figure out expected HDF5 location from Matlab structure and template
    %root
    hdf5_location = [hdf5_root, hdf5_locations{ii}];

    %see if there is a match in template
    template_structure = fn_MFMC_utilities(hdf5_location, [], 'template structure for file location A');
    expandable_dimension = fn_MFMC_utilities([], [], 'expandable dimension');
    
    eval(['matlab_data = matlab_struct', matlab_field_names{ii}, ';']);

    %following will be entered for anything not found in template, e.g.
    %user data
    if isempty(template_structure)
        template_structure = [];
        template_structure.location = hdf5_location;
        template_structure.dataset = 1;
        template_structure.mandatory = 0;
        if ischar(matlab_data)
            template_structure.hdf5_class = 'H5T_STRING';
        elseif isfloat(matlab_data)
            template_structure.hdf5_class = 'H5T_FLOAT';
        elseif isinteger(matlab_data)
            template_structure.hdf5_class = 'H5T_INTEGER';
        else
            error(['Unrecognised type for: ' hdf5_location]);
        end
        if ischar(matlab_data)
            template_structure.dimension = 1;
            template_structure.dataset = 0;
        else
            template_structure.dimension = size(matlab_data);
        end
    end
    
    matlab_data_dimension = size(matlab_data);
    [max_size, chunk_size, start, count] = fn_calc_data_dimension(template_structure.dimension, matlab_data_dimension, expandable_dimension);
    success = success & fn_MFMC_add_to_file(matlab_data, fname, hdf5_location, template_structure.dataset, max_size, chunk_size, start, count);
end

end

function [max_size, chunk_size, start, count] = fn_calc_data_dimension(template_dimension, matlab_data_dimension, expandable_dimension)
%combines information in template and size of actual Matlab data to
%calculate dimension in HDF5 file for new field
max_size = template_dimension;
matlab_data_dimension = [matlab_data_dimension, ones(1, length(template_dimension) - length(matlab_data_dimension))];
if iscell(max_size)
    for jj = 1:length(max_size)
        if ischar(max_size{jj})
            max_size{jj} = matlab_data_dimension(jj);
        end
    end
    max_size = [max_size{:}];
end
%set expandable dimensions to inf
if iscell(template_dimension)
    for ii = 1:length(template_dimension)
        if ischar(template_dimension{ii})
            for jj = 1:length(expandable_dimension)
                if strcmp(template_dimension{ii}, expandable_dimension{jj})
                    max_size(ii) = inf;
                end
            end
        end
    end
end
%if any expandable dimensions, set chunk size, otherwise set to blank
if any(isinf(max_size))
    chunk_size = max_size;
    chunk_size(find(isinf(max_size))) = 1;
else
    chunk_size = [];
end
%set start (dimension where data is added) and count (size of block to be written)
count = matlab_data_dimension(1:length(max_size));
start = ones(size(max_size));
end