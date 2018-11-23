function res = fn_MFMC_read_into_matlab_structure(fname, varargin)
if length(varargin) >= 1
    hdf5_root = varargin{1};
else
    hdf5_root = '';
end
if length(varargin) >= 2
    ignore_locations = varargin{2};
else
    ignore_locations = '';
end

%This reads in all fields in MFMC file and puts them in a matching Matlab 
%data structure based on the names in the file. Nothing is checked, and
%structure will exactly match what is in file

[dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(fname);
total_list = [dataset_list; attribute_list];
match = startsWith(total_list, hdf5_root);
if ~isempty(ignore_locations)
    match = match & ~endsWith(total_list, ignore_locations);
end
dataset = [ones(length(dataset_list), 1); zeros(length(attribute_list), 1)];

total_list = total_list(match);
dataset = dataset(match);

matlab_fields = regexprep(total_list, ['^', hdf5_root], '');
matlab_fields = fn_MFMC_utilities(matlab_fields, [], 'convert list A to matlab fields');


%read everything in
for ii = 1:length(total_list)
    if dataset(ii)
        %read in datasets
        data = h5read(fname, total_list{ii});
        %deal with null-terminated strings
        info = h5info(fname, total_list{ii});
        if strcmp(info.Datatype.Class, 'H5T_STRING')
            for jj = 1:length(data)
                data{jj} = strsplit(data{jj}, '\0');
            end
        end
    else
        %read in attributes
        tmp = total_list{ii};
        jj = strfind(tmp, '/');
        if length(jj) > 1
            loc = tmp(1:jj(end)-1);
            nm = tmp(jj(end)+1:end);
        else
            loc = '/';
            nm = tmp(2:end);
        end
        data = h5readatt(fname, loc, nm);
    end
    %stick into Matlab structure
    eval(['res', matlab_fields{ii}, ' = data;'])
end


end
