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