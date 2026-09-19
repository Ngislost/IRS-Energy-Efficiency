function PL = path_loss_dB(d_m, is_LOS, config)
% path_loss_dB
% Simplified 3GPP TR 38.901 UMa path-loss model.
%
% d_m    : 2D distance in metres
% is_LOS : true for LOS, false for NLOS
% config : Configuration structure
%
% Returns:
%   PL : Path loss in dB
%
% Assumptions:
%   hBS = 25 m
%   hUT = 1.5 m
%   fc  = 28 GHz

    %% Basic parameters

    d_m = max(d_m, 10.0);

    fc = config.FC_GHZ;

    hBS = config.H_BS_M;
    hUT = config.H_UT_M;


    %% Effective antenna-height correction

    d3D = sqrt( ...
        d_m^2 + ...
        (hBS - hUT)^2);


    %% Breakpoint distance

    % Effective environment height.

    hE = 1.0;

    % Breakpoint distance:
    %
    % d_BP' = 4 h'_BS h'_UT fc / c

    c = 3e8;

    hBS_prime = hBS - hE;
    hUT_prime = hUT - hE;

    d_BP = ...
        4 * hBS_prime * hUT_prime ...
        * (fc * 1e9) / c;


    %% LOS path loss

    PL1 = ...
        28.0 ...
        + 22 * log10(d3D) ...
        + 20 * log10(fc);


    PL2 = ...
        28.0 ...
        + 40 * log10(d3D) ...
        + 20 * log10(fc) ...
        - 9 * log10( ...
            d_BP^2 ...
            + (hBS - hUT)^2);


    if d_m <= d_BP

        PL_LOS = PL1;

    else

        PL_LOS = PL2;

    end


    %% Apply LOS/NLOS model

    if is_LOS

        % LOS shadow fading

        sigma = 4.0;

        PL = PL_LOS ...
            + sigma * randn();

    else

        % NLOS candidate path loss

        PL_NLOS = ...
            13.54 ...
            + 39.08 * log10(d3D) ...
            + 20 * log10(fc);


        % 3GPP structure:
        % NLOS path loss cannot be lower than LOS path loss.

        PL_NLOS = max(PL_LOS, PL_NLOS);


        % NLOS shadow fading

        sigma = 6.0;

        PL = PL_NLOS ...
            + sigma * randn();

    end

end