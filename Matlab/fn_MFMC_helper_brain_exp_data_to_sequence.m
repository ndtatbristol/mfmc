function [SEQUENCE]=fn_MFMC_helper_brain_exp_data_to_sequence(exp_data,PROBE,varargin)

    % Convert BRAIN (relevant) exp_data data structure to SEQUENCE of MFMC format
    % Associate this SEQUENCE with PROBE

    SEQUENCE.TIME_STEP = exp_data.time(2)-exp_data.time(1);
    SEQUENCE.START_TIME = exp_data.time(1);
    if (isfield(exp_data,'material_L_velocity'))
        long_vel=exp_data.material_L_velocity;
    elseif (~isempty(varargin))
        long_vel=varargin{1};
    elseif (isfield(exp_data,'ph_velocity'))
        long_vel=exp_data.ph_velocity;
    else
        disp('ERROR: longnitudinal velocity not specified')
        return;
    end
    if (isfield(exp_data,'material_T_velocity'))
        shear_vel=exp_data.material_T_velocity;
    elseif (~isempty(varargin))
        shear_vel=varargin{2};
    elseif (isfield(exp_data,'ph_velocity'))
        shear_vel=exp_data.ph_velocity*0.5;
    else
        disp('ERROR: shear velocity not specified')
        return;
    end
    SEQUENCE.SPECIMEN_VELOCITY = [shear_vel, long_vel];
    
    if (isfield(exp_data,'water_velocity'))
        SEQUENCE.WEDGE_VELOCITY=[NaN,exp_data.water_velocity];
    end
    
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