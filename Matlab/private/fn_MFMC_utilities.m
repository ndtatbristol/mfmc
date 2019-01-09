function output = fn_MFMC_utilities(A, B, operation, varargin)
%Try to make everything that involves template go through this function!

persistent template c1 c2 symbolic_index_pattern numeric_index_pattern any_index_pattern any_index_pattern_for_regexp_insert template_location_list
if ~isempty(varargin)
    template = varargin{1};
    c1 = template.index_start_char;
    c2 = template.index_end_char;
    symbolic_index_pattern = [c1, '\D+?', c2];
    numeric_index_pattern = [c1, '\d+?', c2];
    any_index_pattern = [c1, '\S+?', c2];
    any_index_pattern_for_regexp_insert = [c1, '\\S+?', c2];
    template_location_list = {template.structure.location}';
end
if strcmp(operation, 'template version')
    if ~isempty(template)
        output = template.version;
    else
        output = [];
    end
    return
end
if isempty(template)
    error('template not set')
end
if isempty(operation)
    output = [];
    return
end
switch operation

    %operations that just return basic information from template
    case 'template location list' %internal, fn_MFMC_recursive_error_check_against_template
        output = template_location_list;
        
    case 'MFMC location' %fn_MFMC_read_sequence
        output = template.mfmc_data;
        
    case 'expandable dimension' %fn_add_from_matlab_according_to_template
        output = template.expandable_dimension;
        
    case 'probe root' %fn_MFMC_add_probe
        output = template.probe_root;

    case 'MFMC root' %fn_MFMC_add_sequence
        output = template.mfmc_root;
        
    case 'template' %fn_MFMC_recursive_error_check_against_template
        output = template;
        
   %operation that probes template locations (this is just one function for various purposes)
   case 'template structure for file location A' 
        if ~iscell(A)
            A = {A};
            input_was_cell = 0;
        else
            input_was_cell = 1;
        end
%         user_template_list_pattern = regexprep(template.user_locations, any_index_pattern, any_index_pattern_for_regexp_insert);
        file_location_pattern = regexprep(A, numeric_index_pattern, any_index_pattern_for_regexp_insert);
        for ii = 1:length(A)
            tmp = regexp(template_location_list, ['^', file_location_pattern{ii}, '$'], 'match', 'once');
            jj = find(cell2mat(cellfun(@(c) ~isempty(c), tmp, 'UniformOutput', false)));
            if ~isempty(jj)
                output{ii} = template.structure(jj);
            else
                output{ii} = [];
            end
        end
        output = reshape(output, size(A));
        if ~input_was_cell
            output = output{1};
        end
        
    %operations for indexing
    case 'numerical indices from list A based on root B' %fn_MFMC_add_probe
        B = regexprep(B, [c1, '(\D+?)', c2], '');
        n = regexp(A, [B, c1, '(\d+?)', c2], 'tokens');
        max_indices = 0;
        for ii = 1:length(n)
            if ~isempty(n{ii})
                max_indices = max(max_indices, length(n{ii}));
            end
        end
        indices = NaN(length(n), max_indices);
        for ii = 1:length(n)
            if ~isempty(n{ii})
                for jj = 1:length(n{ii})
                    indices(ii, jj) = str2num(char(n{ii}{jj}));
                end
            end
        end
        output = indices;
        
    case 'match numeric indices in A to symbolic indices in B'
        tmp1 = regexp(A, ['(', numeric_index_pattern, ')'], 'tokens');
        tmp2 = regexp(B, ['(', symbolic_index_pattern, ')'], 'tokens');
        if length(tmp1) ~= length(tmp2)
            output = [];
            return
        end
        for ii = 1:length(tmp1)
            output{ii}.name = tmp2{ii}{1};
            output{ii}.value = tmp1{ii}{1};
        end
        
    case 'unique indices from list A based on root B' %fn_MFMC_add_probe
        output = fn_MFMC_utilities(A, B, 'numerical indices from list A based on root B');
        if size(output, 2) > 1
            error('Unable to determine unique indices from locations with multi-dimensional indexing');
        end
        output = unique(output(~isnan(output)));
        
    case 'next index from list A based on root B' %fn_MFMC_add_probe
        output = fn_MFMC_utilities(A, B, 'unique indices from list A based on root B');
        if isempty(output)
            output = 1;
        else
            output = max(output) + 1;
        end
        
    case 'replace symbolic index in list A with number B' %fn_MFMC_add_probe
        output = regexprep(A, ...
            symbolic_index_pattern, ...
            sprintf([c1, '%i', c2], B));

    case 'file location index string for value A' %fn_MFMC_matlab_structure_to_hdf5_locations
        output = sprintf([c1, '%i', c2], A);
        
    case 'unique indexed locations in A' %fn_MFMC_recursive_error_check_against_template
        unique_indexed_terms = unique(regexprep(A, ['([^', c1, '^', c2, ']+', c1, '\S+?', c2, '?).+'], '$1'));
        tmp = regexp(unique_indexed_terms, ['.+', c1, '\S+?', c2,]);
        tmp2 = zeros(length(tmp), 1);
        for ii = 1:length(tmp)
            tmp2(ii) = ~isempty(tmp{ii});
        end
        output = unique_indexed_terms(find(tmp2));

    case 'non-indexed locations in A' %fn_MFMC_recursive_error_check_against_template
        tmp = regexp(A, ['.+', c1, '\S+?', c2]);
        tmp2 = zeros(length(tmp), 1);
        for ii = 1:length(tmp)
            tmp2(ii) = isempty(tmp{ii});
        end
        output = A(find(tmp2));

    %other operations
    case 'convert list A to matlab fields' %fn_MFMC_read_into_matlab_structure, from fn_MFMC_file_summary
        output = regexprep(A, ...
            [c1, '(\S+?)', c2], ...
            '\($1\)');
        output = regexprep(lower(output), '/', '.');
        
    case 'remove trailing index from list A'
        output = regexprep(A, ...
            [symbolic_index_pattern, '$'], ...
            '');
        
        

end

end

