function errors = fn_MFMC_recursive_error_check_against_template(fname)
%iterate recursively through locations in template
template = fn_MFMC_utilities([], [], 'template');

errors = {};
dim_list = [];

template_location_list = fn_MFMC_utilities([], [], 'template location list');
[dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(fname);
file_location_list = [dataset_list; attribute_list];

fn_recursive_match_against_template('', '', template_location_list, file_location_list);

%convert dimension list to table and analyse
dim_table = table({dim_list.dim_name}', {dim_list.file_location}', [dim_list.value]');
[~, ii] = unique(dim_table(:,[1,3]), 'rows');
dim_table = dim_table(ii, :);
%look for duplicated names - which means that they have inconsistent
%dimensions
[~,~,jj] = unique(dim_table(:,1), 'rows');
unique_jj = unique(jj);
for ii = 1:length(unique_jj)
    match = find(jj == unique_jj(ii));
    if length(match) >= 2
        tmp = ['Dimension ', cell2mat(dim_table{unique_jj(ii), 1}), ' is '];
        for kk = 1:length(match)
            tmp = [tmp, sprintf('%i', dim_table{match(kk), 3}), ' in ', cell2mat(dim_table{match(kk), 2})];
            if kk < length(match)
                tmp = [tmp, ', '];
            end
        end
        errors{end + 1, 1} = tmp;
    end
    
end

    function fn_recursive_match_against_template(file_location_root, template_root, template_location_list, file_location_list)
        
        unique_indexed_template_locations = fn_MFMC_utilities(template_location_list, [], 'unique indexed locations in A');
        nonindexed_template_locations = fn_MFMC_utilities(template_location_list, [], 'non-indexed locations in A');

        %check of each item that is not indexed
        for ii = 1:length(nonindexed_template_locations)
            %this is where the actual checking function should be called
            file_location = [file_location_root, nonindexed_template_locations{ii}];
            template_struct = fn_MFMC_utilities(file_location, [], 'template structure for file location A');
            [tmp_errors, tmp_dim_list] = fn_MFMC_check_file_against_template(fname, file_location, template_struct);
            errors = [errors; tmp_errors(:)];
            dim_list = [dim_list; tmp_dim_list(:)];
        end
        
        %for each indexed item, recursively call this function for all
        %index values
        for ii = 1:length(unique_indexed_template_locations)
            %find matching locations in file that match index
            new_template_root = [template_root, fn_MFMC_utilities(unique_indexed_template_locations{ii}, [], 'trim A after first index')];
            indices = fn_MFMC_utilities(file_location_list, new_template_root, 'unique indices from list A based on root B');
            new_template_location_list = template_location_list(startsWith(template_location_list, new_template_root));
            new_template_location_list = regexprep(new_template_location_list, new_template_root, '');
            
            for jj = 1:length(indices)
                tmp_file_location_root = fn_MFMC_utilities([file_location_root, new_template_root], indices(jj), 'replace symbolic index in list A with number B');
                new_file_location_list = file_location_list(startsWith(file_location_list, tmp_file_location_root));
                new_file_location_list = regexprep(new_file_location_list, tmp_file_location_root, '');
                fn_recursive_match_against_template(tmp_file_location_root, new_template_root, new_template_location_list, new_file_location_list);
            end
            
        end
    end

end