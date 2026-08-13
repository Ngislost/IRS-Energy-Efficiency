function [EE, throughput, total_power] = compute_EE(SNR, scheme, N, config)
% compute_EE
% Computes throughput, total power consumption, and energy efficiency
% for one channel realization.
%
% SNR        : Instantaneous linear SNR
% scheme     : 'no_irs', 'passive', 'active', or 'relay'
% N          : Number of IRS elements
% config     : Configuration structure
%
% EE         : Energy efficiency (bit/J)
% throughput : Achievable throughput (bit/s)
% total_power: Total power consumption (W)

    %% Throughput
    %
    % Shannon capacity:
    % R = B * log2(1 + SNR)

    throughput = config.BW_HZ * ...
                 log2(1 + max(SNR, 0));


    %% Total power consumption

    switch lower(scheme)

        case 'no_irs'

            % No IRS hardware is present.
            % BS transmit power only.

            total_power = config.PT_W;


        case 'passive'

            % Passive IRS:
            % BS transmit power
            % + static IRS hardware power
            % + per-element controller power.

            total_power = config.PT_W + ...
                          config.PSTATIC_W + ...
                          N * config.PC_W;


        case 'active'

            % Simplified active-IRS power-budget model.
            %
            % N*Pc is treated as amplification power and is already
            % included in the effective transmit power used in
            % compute_SNR.m.
            %
            % Therefore N*Pc is NOT added again here.

            total_power = config.PT_W + ...
                          config.PSTATIC_W;


        case 'relay'

            % Fixed relay power budget.
            % Independent of the IRS element-count sweep.

            total_power = config.P_RELAY_W;


        otherwise

            error('Unknown scheme: %s', scheme);

    end


    %% Energy efficiency

    EE = throughput / total_power;

end