function config = config()

%% =========================================================
%  config.m
%  Shared simulation parameters
%  Edit this file to change simulation parameters.
%  =========================================================


%% CST-validated IRS element gain

% Realized gain obtained from CST at 28 GHz.
G_ELEMENT_DBI = 5.724;

% Convert dBi to linear scale.
G_ELEMENT_LIN = 10^(G_ELEMENT_DBI / 10);


%% =========================================================
%  Transmit power
%  =========================================================

PT_DBM = 23;

% Convert dBm to watts.
PT_W = 10^((PT_DBM - 30) / 10);


%% =========================================================
%  IRS hardware power
%  =========================================================

% Static power consumed by the IRS controller/hardware.
PSTATIC_W = 3.0;

% Power consumed per IRS element.
PC_W = 20e-3;


%% =========================================================
%  Channel parameters
%  =========================================================

FC_GHZ = 28;

% System bandwidth.
BW_HZ = 200e6;

% Receiver noise figure.
NF_DB = 7.0;

% Noise temperature.
TEMP_K = 290;

% BS -> IRS horizontal distance.
D_BS_IRS = 20;

% BS and UE heights used by the channel model.
H_BS_M = 25.0;
H_UT_M = 1.5;


%% =========================================================
%  Monte Carlo parameters
%  =========================================================

N_TRIALS = 10000;


%% =========================================================
%  Thermal noise power
%  =========================================================

% Noise power in dBm.
NOISE_DBM = -174 + 10 * log10(BW_HZ) + NF_DB;

% Convert dBm to watts.
NOISE_W = 10^((NOISE_DBM - 30) / 10);


%% =========================================================
%  IRS element-number sweep
%  =========================================================

N_RANGE = 4:4:256;


%% =========================================================
%  Blockage probability sweep
%  =========================================================

BETA_RANGE = 0:0.05:1.0;


%% =========================================================
%  UE distance sweep
%  =========================================================

D_RANGE = 10:10:300;


%% =========================================================
%  IRS phase-resolution factors
%  =========================================================

% Ideal continuous phase control.
KAPPA_CONT = 1.00;

% Approximate coherent-combining factor for 3-bit phase control.
KAPPA_3BIT = 0.84;

% Approximate coherent-combining factor for 1-bit phase control.
KAPPA_1BIT = 0.63;


%% =========================================================
%  Hardware-power sensitivity analysis
%  =========================================================

% Static IRS power values to test.
PSTATIC_LIST = [1.5, 3.0, 4.8];

% Per-element power values to test.
PC_LIST = [10e-3, 20e-3, 30e-3];


%% =========================================================
%  Relay reference configuration
%  =========================================================

% Reference number of elements used to define the
% equivalent relay power budget.
N_REF_RELAY = 64;

% Fixed relay power budget.
P_RELAY_W = ...
    PT_W + PSTATIC_W + N_REF_RELAY * PC_W;


%% =========================================================
%  Store parameters in configuration structure
%  =========================================================

config.G_ELEMENT_DBI = G_ELEMENT_DBI;
config.G_ELEMENT_LIN = G_ELEMENT_LIN;

config.PT_DBM = PT_DBM;
config.PT_W = PT_W;

config.PSTATIC_W = PSTATIC_W;
config.PC_W = PC_W;

config.FC_GHZ = FC_GHZ;
config.BW_HZ = BW_HZ;
config.NF_DB = NF_DB;
config.TEMP_K = TEMP_K;

config.D_BS_IRS = D_BS_IRS;
config.H_BS_M = H_BS_M;
config.H_UT_M = H_UT_M;

config.N_TRIALS = N_TRIALS;

config.NOISE_DBM = NOISE_DBM;
config.NOISE_W = NOISE_W;

config.N_RANGE = N_RANGE;
config.BETA_RANGE = BETA_RANGE;
config.D_RANGE = D_RANGE;

config.KAPPA_CONT = KAPPA_CONT;
config.KAPPA_3BIT = KAPPA_3BIT;
config.KAPPA_1BIT = KAPPA_1BIT;

config.PSTATIC_LIST = PSTATIC_LIST;
config.PC_LIST = PC_LIST;

config.N_REF_RELAY = N_REF_RELAY;
config.P_RELAY_W = P_RELAY_W;

end