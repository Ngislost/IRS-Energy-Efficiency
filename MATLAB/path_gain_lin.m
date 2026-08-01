function G = path_gain_lin(d_m, is_LOS)
% path_gain_lin
% Converts path loss in dB to linear channel power gain.
%
% G = 10^(-PL/10)

PL = path_loss_dB(d_m, is_LOS);

G = 10^(-PL / 10);

end