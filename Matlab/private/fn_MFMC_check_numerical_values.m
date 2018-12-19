function errors = fn_MFMC_check_numerical_values(fname)

[dataset_list, attribute_list] = fn_MFMC_dataset_and_attribute_lists(fname);
template = fn_MFMC_utilities([], [], 'template');

%"if ()"


for ii = 1:length(template.must_be_drawn_from)
%     tmp = fn_MFMC_utilities(dataset_list, template.must_be_drawn_from{ii}{1}, 'numerical indices from list A matching template B');
    
    %following should go in utilities
    
    %find datasets to check
    pat = template.must_be_drawn_from{ii}{1};
    syms = regexp(pat, '(<\S>)', 'tokens');
    pat = ['^', regexprep(pat, '<\S>', '<(\\d+?)>'), '$'];

    datasets_to_check = regexp(dataset_list, pat, 'match');
    datasets_to_check(cellfun('isempty', datasets_to_check)) = [];
    datasets_to_check = cellfun(@(c) c{1}, datasets_to_check, 'UniformOutput', false);
    
    
    %find the "must be drawn from" values
    pat = ['^.*', template.must_be_drawn_from{ii}{2}, '.*$'];
    %find template locations that contain pat, then file locations that
    %match these and then unique indices associated with pat
    template_matches = regexp({template.structure.location}', pat, 'match');
    template_matches(cellfun('isempty', template_matches)) = [];
    template_matches = cellfun(@(c) c{1}, template_matches, 'UniformOutput', false);
    for jj = 1:length(template_matches)
        pat = template_matches{jj};
        syms = regexp(pat, '(<\S>)', 'tokens');
        pat = ['^', regexprep(pat, '<\S>', '<(\\d+?)>'), '$'];
        %need to find file locations that match pattern, extract index and
        %record unique ones
    end
    %
    
    %loop over datasets to check
    for jj = 1:length(datasets_to_check)
        src = h5read(fname, datasets_to_check{jj});
%         keyboard
    end
    
    

    
end

errors = [];
end