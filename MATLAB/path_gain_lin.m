function G = path_gain_lin(d_m, is_LOS, config)
% path_gain_lin
% Converts path loss in dB into linear channel power gain.
%
% d_m    : Distance in metres
% is_LOS : true for LOS, false for NLOS
% config : Configuration structure

PL = path_loss_dB( ...
    d_m, ...
    is_LOS, ...
    config);

G = 10^(-PL / 10);

% Numerical safety

if ~isfinite(G) || G < 0
    G = 0;
end

end