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
            % Passive IRS:
            %
            % SNR = Pt * (sqrt(G_d) +
            %             N*kappa*sqrt(G_r))^2 / Noise
            %
            % Default practical phase resolution = 3-bit.

            kappa = config.KAPPA_3BIT;

            amp = sqrt(max(G_d, 0)) + ...
                  N * kappa * sqrt(max(G_r, 0));

            SNR = config.PT_W * amp^2 / config.NOISE_W;

        case 'active'
            % Active IRS model used in the current project roadmap.
            %
            % Amplification power budget:
            % P_amp = N * Pc

            P_amp = N * config.PC_W;

            SNR = (config.PT_W + P_amp) * ...
                  N^2 * G_r / config.NOISE_W;

        case 'relay'
            % Power-equivalent DF relay.
            %
            % The relay uses the same direct-link channel gain,
            % with relay hardware power included in the power budget.

            N_avg = round(median(config.N_RANGE));

            P_relay = config.PT_W + ...
                      config.PSTATIC_W + ...
                      N_avg * config.PC_W;

            SNR = P_relay * G_d / config.NOISE_W;

        otherwise
            error('Unknown scheme: %s', scheme);

    end

end


%% ============================================================
%  Function 1: 3GPP UMa path loss
%  ============================================================

function PL = path_loss_dB(d_m, is_LOS)
% path_loss_dB
% Simplified 3GPP TR 38.901 UMa path-loss model at 28 GHz.
%
% d_m    : distance in metres
% is_LOS : true for LOS, false for NLOS
%
% Returns:
%   PL : path loss in dB

    d_m = max(d_m, 1.0);

    % LOS path loss
    PL_LOS = 32.4 + ...
             20 * log10(28) + ...
             20 * log10(d_m);

    if is_LOS
        sigma = 4.0;
        PL = PL_LOS + sigma * randn();
    else
        sigma = 6.0;
        PL = PL_LOS + 20.0 + sigma * randn();
    end

end


%% ============================================================
%  Function 2: Path gain
%  ============================================================

function G = path_gain_lin(d_m, is_LOS)
% path_gain_lin
% Converts path loss in dB to linear channel power gain.
%
% G = 10^(-PL/10)

    PL = path_loss_dB(d_m, is_LOS);

    G = 10^(-PL / 10);

end


%% ============================================================
%  Function 3: LOS / blockage sampling
%  ============================================================

function is_LOS = sample_LOS(d_m, beta_override)
% sample_LOS
%
% If beta_override is supplied:
%   beta = fixed blockage probability
%
% If beta_override is NaN:
%   use the 3GPP distance-dependent LOS probability.
%
% Returns:
%   true  -> LOS
%   false -> NLOS

    if nargin > 1 && ~isnan(beta_override)

        % Fixed blockage probability
        beta = beta_override;

    else

        d_m = max(d_m, 1.0);

        % 3GPP UMa LOS probability
        P_LOS = min(18 / d_m, 1) * ...
                (1 - exp(-d_m / 63)) + ...
                exp(-d_m / 63);

        beta = 1 - P_LOS;

    end

    % rand() > beta means LOS probability = 1-beta
    is_LOS = rand() > beta;

end