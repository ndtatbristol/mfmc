function warnings = fn_MFMC_check_for_extra_fields(fname)

warnings = {};

[dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(fname);
file_location_list = [dataset_list; attribute_list];

extra_indices = find(~fn_MFMC_utilities(file_location_list, [], 'is A valid location in template'));

for ii = 1:length(extra_indices)
    warnings{end + 1, 1} = ['Field ', file_location_list{extra_indices(ii)}, ' is not part of MFMC format'];
end

end