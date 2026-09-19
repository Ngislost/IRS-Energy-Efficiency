function is_LOS = sample_LOS(d_m, beta_override)
% sample_LOS
% Samples whether a link is LOS or NLOS.
%
% d_m          : Link distance in metres
% beta_override:
%                NaN -> use distance-dependent UMa LOS probability
%                [0,1] -> use supplied blockage probability
%
% beta is interpreted as:
%
%   beta = P(NLOS)
%
% Therefore:
%
%   P(LOS) = 1 - beta

%% Validate blockage probability

if nargin >= 2 && ~isnan(beta_override)

    beta = min(max(beta_override, 0), 1);

else

    %% Distance-dependent UMa LOS probability

    d_m = max(d_m, 10.0);

    % Simplified UMa LOS probability for low-height UE.

    P_LOS = ...
        min(18 / d_m, 1) ...
        * (1 - exp(-d_m / 63)) ...
        + exp(-d_m / 63);

    beta = 1 - P_LOS;

end


%% Sample LOS/NLOS state

is_LOS = rand() > beta;

end