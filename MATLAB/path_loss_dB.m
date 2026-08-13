function PL = path_loss_dB(d_m, is_LOS)
% path_loss_dB
% 3GPP TR 38.901 UMa path-loss model at 28 GHz.
%
% d_m    : distance in metres
% is_LOS : true for LOS, false for NLOS
%
% Returns:
%   PL : path loss in dB

    % UMa model is valid from 10 m
    d_m = max(d_m, 10.0);

    % Carrier frequency in GHz
    fc = 28;

    % LOS path loss
    PL_LOS = 28.0 + ...
             22 * log10(d_m) + ...
             20 * log10(fc);

    if is_LOS

        % LOS shadow fading
        sigma = 4.0;
        PL = PL_LOS + sigma * randn();

    else

        % NLOS path loss
        % hUT = 1.5 m, so the height correction is zero
        PL_NLOS = 13.54 + ...
                  39.08 * log10(d_m) + ...
                  20 * log10(fc);

        % 3GPP specifies max(LOS, NLOS candidate)
        PL = max(PL_LOS, PL_NLOS);

        % NLOS shadow fading
        sigma = 6.0;
        PL = PL + sigma * randn();

    end

end