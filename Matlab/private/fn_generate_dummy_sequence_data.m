function sequence = fn_generate_dummy_sequence_data(N_Ep, N_Am, N_TEtm, N_RErm, N_P)

if isempty(N_TEtm)
    sequence.common.transmit_probe = int64(randi(length(N_Ep), N_Am, 1));
    sequence.common.transmit_element = int64(zeros(N_Am, 1));
    for ii = 1:length(sequence.common.transmit_element)
        sequence.common.transmit_element(ii) = randi(N_Ep(sequence.common.transmit_probe(ii)), 1);
    end
else
    sequence.common.transmit_probe = int64(zeros(N_Am, 1));
    sequence.common.transmit_element = int64(randi(length(N_TEtm), N_Am, 1));
    for jj = 1:length(N_TEtm)
        sequence.common.transmit_focal_law(jj, 1).probe = int64(randi(N_P, N_TEtm(jj), 1));
        sequence.common.transmit_focal_law(jj, 1).element = int64(randi(N_P, N_TEtm(jj), 1));
        sequence.common.transmit_focal_law(jj, 1).delay = rand(N_TEtm(jj), 1);
        sequence.common.transmit_focal_law(jj, 1).weighting = rand(N_TEtm(jj), 1);
    end
end

if isempty(N_RErm)
    sequence.common.receive_probe = int64(randi(length(N_Ep), N_Am, 1));
    sequence.common.receive_element = int64(zeros(N_Am, 1));
    for ii = 1:length(sequence.common.receive_element)
        sequence.common.receive_element(ii) = randi(N_Ep(sequence.common.receive_probe(ii)), 1);
    end
else
    sequence.common.receive_probe = int64(zeros(N_Am, 1));
    sequence.common.receive_element = int64(randi(length(N_RErm), N_Am, 1));
    for jj = 1:length(N_RErm)
        sequence.common.receive_focal_law(jj, 1).probe = int64(randi(N_P, N_RErm(jj), 1));
        sequence.common.receive_focal_law(jj, 1).element = int64(randi(N_P, N_RErm(jj), 1));
        sequence.common.receive_focal_law(jj, 1).delay = rand(N_RErm(jj), 1);
        sequence.common.receive_focal_law(jj, 1).weighting = rand(N_RErm(jj), 1);
    end
end

sequence.common.firing_index = sequence.common.transmit_element; %N_(A,m)
sequence.common.time_step = rand(1); %1
sequence.common.start_time = rand(1); %1
sequence.common.specimen_velocity = rand(1, 2); %2
probes = [];
if isempty(N_TEtm)
    probes = unique([probes; sequence.common.transmit_probe(:)]);
else
    for jj = 1:length(N_TEtm)
        probes = unique([probes; sequence.common.transmit_focal_law(jj, 1).probe(:)]);
    end
end
if isempty(N_RErm)
    probes = unique([probes; sequence.common.receive_probe(:)]);
else
    for jj = 1:length(N_RErm)
        probes = unique([probes; sequence.common.receive_focal_law(jj, 1).probe(:)]);
    end
end

N_Pm = length(probes);
    
sequence.common.probe_list = int64(randi(N_P, N_Pm, 1));
sequence.common.tag = 'An MFMC sequence';
sequence.common.operator = 'Random person';
sequence.common.date_and_time = datestr(datetime('now'));
sequence.common.user.numbers = rand(5);
sequence.common.user.details = 'Some user data about this sequence';
end