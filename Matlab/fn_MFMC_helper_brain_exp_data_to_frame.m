function [SEQUENCE]=fn_MFMC_helper_brain_exp_data_to_frame(exp_data,MFMC, SEQUENCE,varargin)

    % Convert BRAIN (relevant) exp_data data structure to FRAME of MFMC format
    % Add to specified SEQUENCE in MFMC file

    % 1st optional input - conversion factor for location data
    % 2nd optional input - probe orientation vector

    FRAME.MFMC_DATA = exp_data.time_data;
    
    conversion_factor=0.0125e-3;
    
    if (length(varargin) > 0)
        conversion_factor=varargin{1};
        if (length(varargin)>1)
            probe_orientation_vectors=varargin{2};
        end
    end
        
    FRAME.PROBE_POSITION = [0; 0; 0];           %PCS origin is at GCS origin
    if (isfield(exp_data,'location'))
        FRAME.PROBE_POSITION = [exp_data.location.x*conversion_factor; exp_data.location.y*conversion_factor; exp_data.location.z*conversion_factor]; 
    end
    if (exist('probe_orientation_vectors','var'))
        FRAME.PROBE_X_DIRECTION = probe_orientation_vectors(:,1);
        FRAME.PROBE_Y_DIRECTION = probe_orientation_vectors(:,2);
    else
        FRAME.PROBE_X_DIRECTION = [1; 0; 0];    %PCS x-axis is aligned to GCS x-axis
        FRAME.PROBE_Y_DIRECTION = [0; 1; 0];    %PCS y-axis is aligned to GCS y-axis
    end
    
    % Get number of current positional vectors in SEQUENCE
    tmp = fn_MFMC_get_data_dimensions(MFMC, SEQUENCE.ref,'PROBE_POSITION');
    if (~isempty(tmp))
        counter = tmp(3);
    else
        counter=1;
    end
    
    FRAME.PROBE_PLACEMENT_INDEX = ones(length(exp_data.tx), 1)*counter; 
    
    FRAME.deflate_value=7;
    
    %Add the frame to the specified sequence
    fn_MFMC_add_frame(MFMC, SEQUENCE.ref, FRAME);
    
    %Add probe standoff and angle if known
    if (isfield(exp_data,'location') && isfield(exp_data.location,'standoff'))
        %Example of adding user dataset to sequence in file once sequence has been added
        fn_MFMC_add_user_dataset(MFMC, SEQUENCE.location, 'USER_PROBE_STANDOFF', exp_data.location.standoff);
    end
    if (isfield(exp_data,'location') && isfield(exp_data.location,'angle1'))
        %Example of adding user dataset to sequence in file once sequence has been added
        fn_MFMC_add_user_dataset(MFMC, SEQUENCE.location, 'USER_PROBE_ANGLE', exp_data.location.angle1);
    end    
    
    
end