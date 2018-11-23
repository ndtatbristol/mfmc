function [dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(fname)
%SUMMARY
%   Returns cell arrays of datasets and attributes in specified hdf5 file.
%   This means that, e.g. subsequent call to h5read(fname, dataset_list{1})
%   will read in the data from the file for the first dataset in the list.
%INPUTS
%   fname - filename (includng path if nesc) of hdf5 file.
%OUTPUTS
%   dataset_list - cell array of names of datasets in file
%   attribute_list - cell array of name of attributes in file

%--------------------------------------------------------------------------
[dataset_list, attribute_list] = fn_read_lists(fname, '/', {}, {});
if ~isempty(dataset_list)
    dataset_list = dataset_list(:);
end
if ~isempty(attribute_list)
    attribute_list = attribute_list(:);
end
end
    
    
function [dataset_list, attribute_list] = fn_read_lists(fname, loc, dataset_list, attribute_list)
info = h5info(fname, loc);
%don't add extra separator if location is root
if strcmp(loc, '/')
    sep = '';
else
    sep = '/';
end
for ii = 1:length(info.Datasets)
    dataset_list{end + 1} = [loc, sep, info.Datasets(ii).Name];
end
for ii = 1:length(info.Attributes)
    attribute_list{end + 1} = [loc, sep, info.Attributes(ii).Name];
end
for ii = 1:length(info.Groups)
    [dataset_list, attribute_list] = fn_read_lists(fname, info.Groups(ii).Name, dataset_list, attribute_list);
end
end
