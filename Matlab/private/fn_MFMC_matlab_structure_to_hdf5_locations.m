function [hdf5_locations, matlab_field_names] = fn_MFMC_matlab_structure_to_hdf5_locations(matlab_struct)
%SUMMARY
%   Returns cell arrays of names of all fields in structure str as
%   (a) hdf5 locations and (b) matlab field names
%   Latter can subsequently used as eval([STR, matlab_field_names{i}]); where STR is the name
%   of the structure
global hdf5_locations matlab_field_names
hdf5_locations = {};
matlab_field_names = {};
fn_recursive(matlab_struct, '', '');
end

function fn_recursive(str, hdf5_root, matlab_root)
global hdf5_locations matlab_field_names
for ii = 1:length(str)
    if isstruct(str(ii))
        fn = fieldnames(str(ii));
        for jj = 1:length(fn)
            if length(str) > 1
                tmp_hdf5 = [hdf5_root, fn_MFMC_utilities(ii, [], 'file location index string for value A'), '/', upper(fn{jj})];
                tmp_matlab = sprintf([matlab_root, '(%i).', fn{jj}], ii);
            else
                tmp_hdf5 = [hdf5_root, '/', upper(fn{jj})];
                tmp_matlab = [matlab_root, '.', fn{jj}];
            end
            if isstruct(str(ii).(fn{jj}))
                fn_recursive(str(ii).(fn{jj}), tmp_hdf5, tmp_matlab);
            else
                hdf5_locations{end+1, 1} = tmp_hdf5;
                matlab_field_names{end + 1, 1} = tmp_matlab;
            end
        end
    end
end
end