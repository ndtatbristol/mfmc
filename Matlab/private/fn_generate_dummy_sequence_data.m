function sequence = fn_generate_dummy_sequence_data(N_Ep, N_Am, N_Lm, N_Clm_max, N_Pm)

% N_Ep - Number of elements per probe (vector for all probes in file)
% N_Am - Number of A-scans in frame
% N_Lm - Number of laws in frame
% N_Elm_max - Max number of entries in each law
% N_Pm - Number of probes involved in this frame (subset of this length
% drawn randomly from number of probes available in file)


Pm = int64(randperm(length(N_Ep), N_Pm));
Pm = Pm(:);
sequence.common.probe_index = int64(Pm);

sequence.common.transmit_law_index = int64(randi(N_Lm, N_Am, 1));
sequence.common.receive_law_index = int64(randi(N_Lm, N_Am, 1));


for jj = 1:N_Lm
    N_Clm = randi(N_Clm_max, 1, 1);
    sequence.common.law(jj, 1).probe = Pm(randi(N_Pm, N_Clm, 1));
    sequence.common.law(jj, 1).element = int64(zeros(N_Clm, 1));
    for kk = 1:length(sequence.common.law(jj, 1).element)
        sequence.common.law(jj, 1).element(kk) = int64(randi(N_Ep(sequence.common.law(jj, 1).probe(kk)), 1, 1));
    end
    sequence.common.law(jj, 1).delay = rand(N_Clm, 1);
    sequence.common.law(jj, 1).weighting = rand(N_Clm, 1);
end

sequence.common.time_step = rand(1); %1
sequence.common.start_time = rand(1); %1
sequence.common.specimen_velocity = rand(2, 1); %2

sequence.common.tag = 'An MFMC sequence';
sequence.common.operator = 'Random person';
sequence.common.date_and_time = datestr(datetime('now'));
sequence.common.user.numbers = rand(5);
sequence.common.user.details = 'Some user data about this sequence';
end