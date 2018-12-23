function frame = fn_MFMC_generate_dummy_frame_data(N_Tm, N_Am, N_Fm, N_Bm_max, N_Pm, raw_data_type)

% N_Tm - number of time points
% N_Am - number of A-scans
% N_Fm - number of frames
% N_Bm_max - max unique firing indices per frame
% N_Pm - number of probes in use
% raw_data_type - type of data

N_Bm = randi(N_Bm_max, 1, N_Fm);

frame.probe_position =      rand(3, N_Pm, sum(N_Bm) * N_Fm);    %3×N_(B,m)×N_(P,m)×N_(F,m)
frame.probe_x_direction =   rand(3, N_Pm, sum(N_Bm) * N_Fm);    %3×N_(B,m)×N_(P,m)×N_(F,m)
frame.probe_y_direction =   rand(3, N_Pm, sum(N_Bm) * N_Fm);    %3×N_(B,m)×N_(P,m)×N_(F,m)
frame.mfmc_data =           rand(N_Tm, N_Am, N_Fm);             %N_(T,m)×N_(A,m)×N_(F,m)
frame.position_index = int64(zeros(N_Am, N_Fm));
for ii = 1:N_Fm
    if ii == 1
        jj = [1:N_Bm(ii)];
    else
        jj = [1:N_Bm(ii)] + sum(N_Bm(1:ii - 1));
    end
        
    frame.position_index(:, ii) = jj(randi(N_Bm(ii), N_Am, 1));
end

switch raw_data_type
    case 'int8'
        frame.mfmc_data = int8(frame.mfmc_data);
    case 'int16'
        frame.mfmc_data = int16(frame.mfmc_data);
    case 'complex'
        frame.mfmc_data_im = rand(size(frame.mfmc_data));
end

end
