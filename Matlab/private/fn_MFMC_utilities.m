function output = fn_MFMC_utilities(A, B, operation, varargin)
%Try to make everything that involves template go through this function!

persistent template c1 c2 symbolic_index_pattern numeric_index_pattern any_index_pattern
if ~isempty(varargin)
    template = varargin{1};
    c1 = template.index_start_char;
    c2 = template.index_end_char;
    symbolic_index_pattern = [c1, '\D+?', c2];
    numeric_index_pattern = [c1, '\d+?', c2];
    any_index_pattern = [c1, '\S+?', c2];
end
if strcmp(operation, 'template filename')
    if ~isempty(template)
        output = template.filename;
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
    case 'template location list'
        output = {template.structure.location}';
        
    case 'MFMC location'
        output = template.mfmc_data;
        
    case 'is A valid location in template'
        if ~iscell(A)
            A = {A};
        end
        equiv_template_location = fn_MFMC_utilities(A, [], 'template location for file location A');
        template_location_list = fn_MFMC_utilities([], [], 'template location list');
        user_template_list = regexprep(template.user_locations, any_index_pattern, [c1, '\\S+\?', c2]);
        output = zeros(size(equiv_template_location));
        for ii = 1:length(equiv_template_location)
            if ~isempty(cell2mat(regexp(template_location_list, ['^', equiv_template_location{ii}, '$'])))
                output(ii) = 1;
            else
                %check it's not within user bit
                for jj = 1:length(user_template_list)
                    output(ii) = output(ii) | ~isempty(regexp(A{ii}, ['^', user_template_list{jj}]));
                end
            end
        end

    case 'numerical indices from list A matching template B'
        B = regexprep(B, [c1, '(\S+?)', c2], [c1, '(\\d+\?)', c2]);
        n = regexp(A, B, 'tokens');
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
                    indices(ii, jj) = str2num(char(n{ii}{1}{jj}));
                end
            end
        end
        output = indices;
        
    case 'numerical indices from list A based on root B'
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
        
    case 'unique indices from list A based on root B'
        output = fn_MFMC_utilities(A, B, 'numerical indices from list A based on root B');
        if size(output, 2) > 1
            error('Unable to determine unique indices from locations with multi-dimensional indexing');
        end
        output = unique(output(~isnan(output)));
        
    case 'next index from list A based on root B'
        output = fn_MFMC_utilities(A, B, 'unique indices from list A based on root B');
        if isempty(output)
            output = 1;
        else
            output = max(output) + 1;
        end
        
    case 'indices and template tokens from A'
        %find matching template string
        tmp = fn_MFMC_utilities(A, [], 'template structure for file location A');
        output.template_location = tmp.location;
        
    case 'remove trailing index from list A'
        output = regexprep(A, ...
            [c1, '(\S?+)', c2, '$'], ...
            '');
        
    case 'convert list A to matlab fields'
        output = regexprep(A, ...
            [c1, '(\S+?)', c2], ...
            '\($1\)');
        output = regexprep(lower(output), '/', '.');
        
    case 'replace symbolic index in list A with number B'
        output = regexprep(A, ...
            symbolic_index_pattern, ...
            sprintf([c1, '%i', c2], B));
        
    case 'trim A after first index'
        output = regexprep(A, ['(', c1, '\S+?', c2, ').+'], '$1');

    case 'template structure for file location A'
        template_pattern = ['^', regexprep(A, numeric_index_pattern, [c1, '\\S+?', c2]), '$'];
        [first_indices, last_indices] = regexp({template.structure(:).location}, template_pattern);
        ii = zeros(length(first_indices),1);
        for jj = 1:length(first_indices)
            if ~isempty(first_indices{jj})
                ii(jj) = first_indices{jj}(1) == 1 & last_indices{jj}(1) == length(template.structure(jj).location);
            end
        end
        
        output = find(ii);
        if isempty(output)
            output = [];
        elseif length(output) > 1
            error(['Multiple matching template locations found for: ', A]);
        else
            output = template.structure(output);
        end
        
    case 'template location for file location A'
        output = regexprep(A, numeric_index_pattern, [c1, '\\S+?', c2]);
        
    case 'file location index string for value A'
        output = sprintf([c1, '%i', c2], A);
        
    case 'unique indexed locations in A'
        unique_indexed_terms = unique(regexprep(A, ['([^', c1, '^', c2, ']+', c1, '\S+?', c2, '?).+'], '$1'));
        tmp = regexp(unique_indexed_terms, ['.+', c1, '\S+?', c2,]);
        tmp2 = zeros(length(tmp), 1);
        for ii = 1:length(tmp)
            tmp2(ii) = ~isempty(tmp{ii});
        end
        output = unique_indexed_terms(find(tmp2));

    case 'non-indexed locations in A'
        tmp = regexp(A, ['.+', c1, '\S+?', c2]);
        tmp2 = zeros(length(tmp), 1);
        for ii = 1:length(tmp)
            tmp2(ii) = isempty(tmp{ii});
        end
        output = A(find(tmp2));
        
    case 'expandable dimension'
        output = template.expandable_dimension;
        
    case 'probe root'
        output = template.probe_root;

    case 'MFMC root'
        output = template.mfmc_root;
        
    case 'template'
        output = template;
end

end

