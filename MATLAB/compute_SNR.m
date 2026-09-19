function SNR = compute_SNR(scheme, N, d_UE, beta, G_elem, config)
% compute_SNR
% Computes instantaneous linear SNR for one channel realization.

    %% Direct BS -> UE path

    is_LOS_direct = sample_LOS(d_UE, beta);

    G_d = path_gain_lin( ...
        d_UE, ...
        is_LOS_direct, ...
        config);


    %% BS -> IRS -> UE reflected path

    % BS -> IRS is assumed LOS because the IRS is wall-mounted.

    G_BS_IRS = path_gain_lin( ...
        config.D_BS_IRS, ...
        true, ...
        config);

    % IRS -> UE is assumed LOS in the current simplified model.

    G_IRS_UE = path_gain_lin( ...
        d_UE, ...
        true, ...
        config);

    % Cascaded channel gain.

    G_r = G_BS_IRS * G_elem * G_IRS_UE;


    %% Communication scheme

    switch lower(scheme)

        case 'no_irs'

            % Direct BS -> UE link only.

            SNR = ...
                config.PT_W * G_d ...
                / config.NOISE_W;


        case 'passive'

            % Passive IRS coherent-combining model.

            kappa = config.KAPPA_3BIT;

            amp = ...
                sqrt(max(G_d, 0)) ...
                + N * kappa * sqrt(max(G_r, 0));

            SNR = ...
                config.PT_W * amp^2 ...
                / config.NOISE_W;


        case 'active'

            % Simplified active-IRS power-budget baseline.

            SNR = ...
                config.PT_W ...
                * N^2 * G_r ...
                / config.NOISE_W;


        case 'relay'

            % Simplified single-equivalent-link relay baseline.

            P_relay = config.P_RELAY_W;

            SNR = ...
                P_relay * G_d ...
                / config.NOISE_W;


        otherwise

            error('Unknown scheme: %s', scheme);

    end


    %% Numerical safety

    if ~isfinite(SNR) || SNR < 0
        SNR = 0;
    end

end