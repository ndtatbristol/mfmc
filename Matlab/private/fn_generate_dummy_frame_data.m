function frame = fn_MFMC_generate_dummy_frame_data(N_Tm, N_Am, N_Fm, N_Bm, N_Pm, raw_data_type)
frame.probe_position =      rand(3, N_Bm, N_Pm, N_Fm);%3×N_(B,m)×N_(P,m)×N_(F,m)
frame.probe_x_direction =    rand(3, N_Bm, N_Pm, N_Fm);%3×N_(B,m)×N_(P,m)×N_(F,m)
frame.probe_y_direction =    rand(3, N_Bm, N_Pm, N_Fm);%3×N_(B,m)×N_(P,m)×N_(F,m)
frame.mfmc_data =           rand(N_Tm, N_Am, N_Fm); %N_(T,m)×N_(A,m)×N_(F,m)
switch raw_data_type
    case 'int8'
        frame.mfmc_data = int8(frame.mfmc_data);
    case 'int16'
        frame.mfmc_data = int16(frame.mfmc_data);
    case 'complex'
        frame.mfmc_data_im = rand(size(frame.mfmc_data));
end
end
