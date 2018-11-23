function errors = fn_MFMC_check_numerical_values(fname)

[dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(fname);
template = fn_MFMC_utilities([], [], 'template');

for ii = 1:length(template.must_be_drawn_from)
    tmp = fn_MFMC_utilities(dataset_list, template.must_be_drawn_from{ii}{1}, 'numerical indices from list A matching template B');
    keyboard

%     src = h5read(fname, template.must_be_drawn_from{ii}{1});
end

errors = [];
end