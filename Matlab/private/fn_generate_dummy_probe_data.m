function probe = fn_MFMC_generate_dummy_probe_data(N_Ep)
probe.element_position = rand(3, N_Ep);
probe.element_minor = rand(3, N_Ep);
probe.element_major = rand(3, N_Ep);
probe.element_shape = int64(ones(N_Ep, 1));
probe.probe_tag = sprintf('A %i-element array', N_Ep);
probe.centre_frequency = rand(1) * 1e6;
probe.user.numbers = rand(3);
probe.user.details = 'some user details about this probe';
end
