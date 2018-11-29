function success = fn_MFMC_prepare_to_write_or_read_file(fname)
%SUMMARY
%   Gets template filename from MFMC file, checks against named template in
%   fn_MFMC_utilities and loads new template file if required.
%AUTHOR
%   Paul Wilcox, November 2018
%INPUTS
%   fname - name of MFMC file 
%OUTPUTS
%   success - 1 if successful, 0 if not
%--------------------------------------------------------------------------

global template_path

success = 0;

if ~exist(fname)
    fprintf('MFMC file does not exist\n');
    return
end

try 
    template_fname_in_file = h5readatt(fname, '/', 'TEMPLATE_FILENAME');
catch
    fprintf('Failed to read template filename from file\n');
    return
end

current_template_fname = fn_MFMC_utilities([], [], 'template filename');
if ~isempty(current_template_fname) && strcmp(current_template_fname, template_fname_in_file)
    success = 1;
    return
end

try 
    template = jsondecode(fileread([template_path, filesep, template_fname_in_file]));
catch
    fprintf('Failed to read required template file\n');
    return
end

%prime utilities function
fn_MFMC_utilities([], [], [], template);
end