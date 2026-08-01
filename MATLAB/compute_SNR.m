function SNR = compute_SNR(scheme, N, d_UE, beta, G_elem, config)
% compute_SNR
% Computes SNR for one channel realization.
%
% scheme:
%   'no_irs'
%   'passive'
%   'active'
%   'relay'
%
% N       : Number of IRS elements
% d_UE    : IRS-to-UE distance in metres
% beta    : Blockage probability
%           NaN -> use 3GPP distance-dependent LOS probability
% G_elem  : CST-validated IRS element gain (linear)
% config  : configuration structure

    %% Direct BS-to-UE path

    is_LOS_direct = sample_LOS(d_UE, beta);

    G_d = path_gain_lin(d_UE, is_LOS_direct);


    %% IRS reflected path

    % BS-to-IRS is assumed LOS because IRS is wall-mounted.

    G_r = G_elem * path_gain_lin(d_UE, true);


    %% Select communication scheme

    switch lower(scheme)

        case 'no_irs'

            % Direct link only
            SNR = config.PT_W * G_d / config.NOISE_W;


        case 'passive'

            % Passive IRS
            %
            % SNR = Pt * (sqrt(G_d) +
            %             N*kappa*sqrt(G_r))^2 / Noise

            kappa = config.KAPPA_3BIT;

            amp = sqrt(max(G_d, 0)) + ...
                  N * kappa * sqrt(max(G_r, 0));

            SNR = config.PT_W * amp^2 / config.NOISE_W;


        case 'active'

            % Active IRS model
            %
            % Amplification power budget:
            % P_amp = N * Pc

            P_amp = N * config.PC_W;

            SNR = (config.PT_W + P_amp) * ...
                  N^2 * G_r / config.NOISE_W;


        case 'relay'

            % Power-equivalent DF relay

            N_avg = round(median(config.N_RANGE));

            P_relay = config.PT_W + ...
                      config.PSTATIC_W + ...
                      N_avg * config.PC_W;

            SNR = P_relay * G_d / config.NOISE_W;


        otherwise

            error('Unknown scheme: %s', scheme);

    end

end