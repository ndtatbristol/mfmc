function MFMC = fn_MFMC_open_file(fname, varargin)
%SUMMARY
%   Opens MFMC file for reading or writing. If file does not exist it is 
%   created. If file exists but non-existent root path is specified, the 
%   path is created in the file.
%INPUTS
%   fname - name (including path if necessary of file)
%   root_path - optional location of MFMC data in file. Default is root,
%   i.e. '/'
%OUTPUTS
%   MFMC - structure for subsequent calls to MFMC functions with fields:
%       .fname - file name
%       .root_path - location of MFMC data in file
%       .TYPE = 'MFMC'
%       .VERSION = '2.0.0'
%       .probe_name_template - template used for automatically generated
%       probe groups
%       .sequence_name_template - template used for automatically generated
%       sequence groups
%       .law_name_template - template used for automatically generated
%       focal law groups
%--------------------------------------------------------------------------

MFMC.fname = fname;
MFMC.probe_name_template = 'PROBE<%i>';
MFMC.sequence_name_template = 'SEQUENCE<%i>';
MFMC.law_name_template = 'LAW<%i>';
MFMC.TYPE = 'MFMC';
MFMC.VERSION = '2.0.0';

if length(varargin) < 1
    MFMC.root_path = '/';
else
    MFMC.root_path = varargin{1};
    if ~strcmp(MFMC.root_path(end), '/')
        MFMC.root_path = [MFMC.root_path, '/'];
    end
end

%If file does not exist, create it
if ~exist(fname, 'file')
    fcpl = H5P.create('H5P_FILE_CREATE');
    fapl = H5P.create('H5P_FILE_ACCESS');
    file_id = H5F.create(MFMC.fname, 'H5F_ACC_TRUNC', fcpl, fapl);
else
    file_id = H5F.open(fname); %will throw error if not HDF5 file
end
H5F.close(file_id);

%If root path exists and contains correct attribute, exit here
try
    a = fn_hdf5_read_to_matlab(MFMC.fname, [MFMC.root_path, '/']);
    if isfield(a, 'TYPE') && strcmp(a.TYPE, MFMC.TYPE)
        return
    else
        error('Root path exists but does not contain MFMC data');
    end
catch ME
    if strcmp(ME.message, 'Root path exists but does not contain MFMC data')
        rethrow(ME);
    end
end

%Create root attributes
fn_hdf5_create_entry(MFMC, MFMC.fname, [MFMC.root_path, 'TYPE'],    'M', 'A');
fn_hdf5_create_entry(MFMC, MFMC.fname, [MFMC.root_path, 'VERSION'], 'M', 'A');

end

