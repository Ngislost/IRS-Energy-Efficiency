function [EE, throughput, total_power] = compute_EE( ...
    SNR, scheme, N, config)

% compute_EE
% Computes throughput, total power consumption, and
% energy efficiency for one channel realization.
%
% SNR        : Instantaneous linear SNR
% scheme     : 'no_irs', 'passive', 'active', or 'relay'
% N          : Number of IRS elements
% config     : Configuration structure
%
% EE         : Energy efficiency in bit/J
% throughput : Achievable throughput in bit/s
% total_power: Total power consumption in W

%% Numerical safety

SNR = max(SNR, 0);


%% Throughput

% Shannon achievable rate:
%
% R = B * log2(1 + SNR)

throughput = ...
    config.BW_HZ * log2(1 + SNR);


%% Total power consumption

switch lower(scheme)

    %% ---------------------------------------------------------
    case 'no_irs'

        % Direct BS -> UE communication.
        % Only BS transmit power is counted.

        total_power = ...
            config.PT_W;


        %% ---------------------------------------------------------
    case 'passive'

        % Passive IRS:
        %
        % BS transmit power
        % + static IRS hardware power
        % + per-element controller power

        total_power = ...
            config.PT_W ...
            + config.PSTATIC_W ...
            + N * config.PC_W;


        %% ---------------------------------------------------------
    case 'active'

        % Simplified active-IRS power-budget model.
        %
        % N*Pc has already been incorporated into the
        % effective transmit power in compute_SNR.m.
        %
        % Therefore it is NOT added again here.

        total_power = ...
            config.PT_W ...
            + config.PSTATIC_W;


        %% ---------------------------------------------------------
    case 'relay'

        % Fixed relay reference power.

        total_power = ...
            config.P_RELAY_W;


        %% ---------------------------------------------------------
    otherwise

        error('Unknown scheme: %s', scheme);

end


%% Energy efficiency

EE = throughput / total_power;

end