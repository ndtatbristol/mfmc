function [res, groups] = fn_hdf5_read_to_matlab(fname, location, varargin)
%SUMMARY
%   Reads all datasets and attributes at location into fields of same name
%   in res. Groups are returned as list, but not examined. Optional
%   argument lists names of any datasets to exclude

if length(varargin) < 1
    datasets_to_exclude = [];
else
    datasets_to_exclude = varargin{1};
end

a = h5info(fname, location);
for ii = 1:length(a.Datasets)
    nm = a.Datasets(ii).Name;
    skip = 0;
    for jj = 1:length(datasets_to_exclude)
        if strcmp(nm, datasets_to_exclude{jj})
            skip = 1;
            break;
        end
    end
    if skip
        continue
    end
    if strcmp(a.Datasets(ii).Datatype.Class, 'H5T_REFERENCE')
        %special case of references
        fid = H5F.open(fname);
        dataset_id = H5D.open(fid,[location, '/', nm]);
        res.(nm) = H5D.read(dataset_id)';
        H5F.close(fid);
        H5D.close(dataset_id);
    else
        res.(nm) = h5read(fname, [location, '/', nm]);
    end
end
for ii = 1:length(a.Attributes)
    nm = a.Attributes(ii).Name;
    res.(nm) = h5readatt(fname, location, nm);
end

groups = a.Groups;

end