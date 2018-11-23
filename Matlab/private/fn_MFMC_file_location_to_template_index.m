function ii = fn_MFMC_file_location_to_template_index(file_location, template)
template_pattern = regexprep(file_location, '<\d+?>', '<\\S+?>');
[first_indices, last_indices] = regexp({template.structure(:).location}, template_pattern);
ii = zeros(length(first_indices),1);
for jj = 1:length(first_indices)
    if ~isempty(first_indices{jj})
        ii(jj) = first_indices{jj}(1) == 1 & last_indices{jj}(1) == length(template.structure(jj).location);
    end
end
end