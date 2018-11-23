function [errors, dim_list] = fn_MFMC_check_file_against_template(fname, file_location, template_struct)
errors = {};
dim_list = [];
% dim_list = {};
%check for presence
if template_struct.dataset
    try
        info = h5info(fname, file_location);
    catch
        if template_struct.mandatory
            errors{end + 1, 1} = ['Mandatory dataset ', file_location, ' missing'];
        end
        return
    end
else
    try
        jj = strfind(file_location, '/');
        if length(jj) > 1
            loc = file_location(1:jj(end)-1);
            nm = file_location(jj(end)+1:end);
        else
            loc = '/';
            nm = file_location(2:end);
        end
        data = h5readatt(fname, loc, nm);
    catch
        if template_struct.mandatory
            errors{end + 1, 1} = ['Mandatory attribute ', file_location, ' missing'];
        end
        return
    end
end

if template_struct.dataset
    %check class
    if ~strcmp(info.Datatype.Class, template_struct.hdf5_class)
        errors{end + 1, 1} = ['Dataset ', file_location, ' is class ', info.Datatype.Class,' but should be ', template_struct.hdf5_class];
    end
    %check dimensions
    dims_ok = 1;
    for ii = 1:length(template_struct.dimension)
        if isnumeric(template_struct.dimension{ii})
            if template_struct.dimension{ii} ~= info.Dataspace.Size(ii)
                dims_ok = 0;
                errors{end + 1, 1} = sprintf(['Dataset ', file_location, ' dimension %i is %i but should be %i'], ii, info.Dataspace.Size(ii), template_struct.dimension{ii});
            end
        else
            %need to replace symbols in dimension with numeric values from
            %file location where possible
            tmp.dim_name = template_struct.dimension{ii};
            [a,b]=regexp(file_location, '<\d+?>');
            for jj = 1:length(a)
                 tmp.dim_name = regexprep(tmp.dim_name, template_struct.location(a(jj):b(jj)), file_location(a(jj):b(jj)));
            end
            tmp.file_location = file_location;
            tmp.value = info.Dataspace.Size(ii);
            dim_list = [dim_list; tmp];
        end
    end
else
    %attribute checks should be here
end

end