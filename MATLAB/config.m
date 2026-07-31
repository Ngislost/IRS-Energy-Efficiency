%% config.m
% Shared simulation parameters for IRS energy-efficiency study
% Edit simulation parameters here rather than hard-coding them elsewhere.

%% =========================
% Carrier and system parameters
% ==========================

FC_GHZ = 28;              % Carrier frequency (GHz)
BW_HZ = 200e6;            % System bandwidth (Hz)

PT_DBM = 23;              % BS transmit power (dBm)
PT_W = 10^((PT_DBM-30)/10);

NF_DB = 7;                % Receiver noise figure (dB)
TEMP_K = 290;             % System temperature (K)

% Thermal noise power
NOISE_DBM = -174 + 10*log10(BW_HZ) + NF_DB;
NOISE_W = 10^((NOISE_DBM-30)/10);


%% =========================
% IRS hardware parameters
% ==========================

PSTATIC_W = 3.0;          % Static IRS/controller power (W)
PC_W = 20e-3;             % Circuit power per IRS element (W)


%% =========================
% IRS element gain
% ==========================

% Temporary placeholder until CST simulation is finalized.
% DO NOT treat this as the final CST result.

G_ELEMENT_DBI = 6.16;
G_ELEMENT_LIN = 10^(G_ELEMENT_DBI/10);


%% =========================
% Geometry
% ==========================

D_BS_IRS = 20;            % BS-to-IRS distance (m)


%% =========================
% IRS size sweep
% ==========================

N_RANGE = 4:4:256;


%% =========================
% Blockage probability
% ==========================

BETA_RANGE = 0:0.05:1.0;


%% =========================
% Distance sweep
% ==========================

D_RANGE = 10:10:300;


%% =========================
% Phase-resolution factors
% ==========================

KAPPA_CONT = 1.00;        % Continuous phase
KAPPA_3BIT = 0.84;        % 3-bit phase resolution
KAPPA_1BIT = 0.63;        % 1-bit phase resolution


%% =========================
% Monte Carlo settings
% ==========================

N_TRIALS = 10000;


%% =========================
% Sensitivity analysis
% ==========================

PSTATIC_LIST = [1.5, 3.0, 4.8];      % W
PC_LIST = [10e-3, 20e-3, 30e-3];     % W