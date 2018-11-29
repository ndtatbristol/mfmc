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
        %args: '/MFMC<1>', '/MFMC<m>', {..., '/COMMON/TRANSMIT_FOCAL_LAW<t>/PROBE', ...}, {..., '/COMMON/TRANSMIT_FOCAL_LAW<1>/PROBE', ...}
        indexed_template_locations = fn_MFMC_utilities(template_location_list, [], 'unique indexed locations in A');
        nonindexed_template_locations = fn_MFMC_utilities(template_location_list, [], 'non-indexed locations in A');

        %check of each item that is not indexed
        for iii = 1:length(nonindexed_template_locations)
            %this is where the actual checking function should be called
            test_file_location = [file_location_root, nonindexed_template_locations{iii}];
            template_struct = fn_MFMC_utilities(test_file_location, [], 'template structure for file location A');
            [tmp_errors, tmp_dim_list] = fn_MFMC_check_file_against_template(fname, test_file_location, template_struct); %should return error if template_struct is empty (i.e. no matching template entry found) or does this never arise because test_file_location is dervied from template_struct anyway?
            errors = [errors; tmp_errors(:)];
            dim_list = [dim_list; tmp_dim_list(:)];
        end
        
        %for each indexed item, recursively call this function for all
        %index values
        for iii = 1:length(indexed_template_locations)
            %find matching locations in file that match index
            new_template_root = [template_root, indexed_template_locations{iii}];%OK
            indices = fn_MFMC_utilities(file_location_list, indexed_template_locations{iii}, 'unique indices from list A based on root B');%OK
            new_template_location_list = template_location_list(startsWith(template_location_list, indexed_template_locations{iii}));
            new_template_location_list = regexprep(new_template_location_list, indexed_template_locations{iii}, '');
            
            for jjj = 1:length(indices)
                file_location_root_ext = fn_MFMC_utilities(indexed_template_locations{iii}, indices(jjj), 'replace symbolic index in list A with number B');
                new_file_location_list = file_location_list(startsWith(file_location_list, file_location_root_ext));
                new_file_location_list = regexprep(new_file_location_list, file_location_root_ext, '');
                new_file_location_root = [file_location_root, file_location_root_ext];
                fn_recursive_match_against_template(new_file_location_root, new_template_root, new_template_location_list, new_file_location_list);
            end
            
        end
    end

end