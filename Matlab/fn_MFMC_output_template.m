function output_table = fn_MFMC_output_template(template_fname, varargin)
%SUMMARY
%   Converts content of specified template file into table and optionally
%   writes to file (Excel if extension is .xlsx or CSV otherwise).
%AUTHOR
%   Paul Wilcox, November 2018
%INPUTS
%   template_fname - name of MFMC template file 
%   [output_fname] - name of output file
%OUTPUTS
%   output_table - Matlab table of information in template file
%--------------------------------------------------------------------------
if isempty(varargin)
    output_fname = '';
else
    output_fname = varargin{1};
end

template = jsondecode(fileread(template_fname));

col_names = {'Location', 'M_or_O', 'D_or_A', 'Class', 'Dimensions', 'Size'};
var_types = {'string', 'string', 'string', 'string', 'int64', 'string'};
row_names = {template.structure(:).location};
output_table = table('Size',[length(template.structure), length(col_names)], 'VariableTypes', var_types, 'VariableNames', col_names);

for ii = 1:length(template.structure)
    output_table{ii, 1} = string(template.structure(ii).location);
    if template.structure(ii).mandatory
        output_table{ii, 2} = "M";
    else
        output_table{ii, 2} = "O";
    end
    
    if template.structure(ii).dataset
        output_table{ii, 3} = "D";
    else
        output_table{ii, 3} = "A";
    end
    
    if iscell(template.structure(ii).hdf5_class)
        tmp = '';
        for jj = 1:length(template.structure(ii).hdf5_class)
            tmp = [tmp, template.structure(ii).hdf5_class{jj}];
            if jj < length(template.structure(ii).hdf5_class)
                tmp = [tmp, ' / '];
            end
        end
    else
        tmp = template.structure(ii).hdf5_class;
    end
    output_table{ii, 4} = string(tmp);
    output_table{ii, 5} = length(template.structure(ii).dimension);
    tmp = '[';
    if iscell(template.structure(ii).dimension)
        for jj = 1:length(template.structure(ii).dimension)
            if isnumeric(template.structure(ii).dimension{jj})
                tmp = [tmp, num2str(template.structure(ii).dimension{jj})];
            else
                tmp = [tmp, template.structure(ii).dimension{jj}];
            end
            if jj < length(template.structure(ii).dimension)
                tmp = [tmp, ','];
            end
        end
    else
        for jj = 1:length(template.structure(ii).dimension)
            tmp = [tmp, num2str(template.structure(ii).dimension(jj))];
            if jj < length(template.structure(ii).dimension)
                tmp = [tmp, ', '];
            end
        end
    end
    tmp = [tmp, ']'];
    output_table{ii, 6} = string(tmp);
end

if ~isempty(output_fname)
    writetable(output_table, output_fname);
end


end
