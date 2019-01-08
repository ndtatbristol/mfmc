function warnings = fn_MFMC_check_for_extra_fields(fname)

warnings = {};

[dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(fname);
file_location_list = [dataset_list; attribute_list];

valid_locations = fn_MFMC_utilities(file_location_list, [], 'template structure for file location A');
extra_indices = find(cellfun(@(c) isempty(c), valid_locations));

for ii = 1:length(extra_indices)
    warnings{end + 1, 1} = ['Field ', file_location_list{extra_indices(ii)}, ' is not part of MFMC format'];
end

end