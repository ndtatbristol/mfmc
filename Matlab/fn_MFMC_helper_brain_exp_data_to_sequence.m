function [SEQUENCE]=fn_MFMC_helper_brain_exp_data_to_sequence(exp_data,PROBE,varargin)

    % Convert BRAIN (relevant) exp_data data structure to SEQUENCE of MFMC format
    % Associate this SEQUENCE with PROBE
    %optional arguments are longitudinal and shear velocities; if
    %longitudinal velocity argument is non-empty it is used instead of 
    %exp_data.ph_velocity. If shear velocity not specified then shear
    %velocity of half longitudinal velocity is written to MFMC file

    SEQUENCE.TIME_STEP = exp_data.time(2)-exp_data.time(1);
    SEQUENCE.START_TIME = exp_data.time(1);
    if length(varargin) >= 1 && ~isempty(varargin{1})
        long_vel=varargin{1};
    else
        long_vel=exp_data.ph_velocity;
    end
    if length(varargin) >= 2 && ~isempty(varargin{2})
        shear_vel=varargin{2};
    else
        shear_vel=exp_data.ph_velocity*0.5;
        warning('Using shear velocity = 0.5 * longitudinal velocity');
    end
    SEQUENCE.SPECIMEN_VELOCITY = [shear_vel, long_vel];
    
    SEQUENCE.PROBE_LIST = PROBE.ref; %this is the HDF5 object reference

    for jj = 1:length(exp_data.array.el_xc)
        SEQUENCE.LAW{jj}.ELEMENT = int32(jj);       %identify individual element
        SEQUENCE.LAW{jj}.PROBE = PROBE.ref;         %reference to probe
    end
    %Now define the focal laws for transmission and reception associated with
    %each A-scan in data. In Matlab these are defined by indices referring to
    %the focal laws above; in the file, these are converted into HDF5 object 
    %references
    SEQUENCE.transmit_law_index=exp_data.tx;                                                          
    SEQUENCE.receive_law_index=exp_data.rx;

end