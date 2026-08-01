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