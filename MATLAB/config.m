function config = config()

%% config.m
% Shared simulation parameters
% Edit ONLY this file to change simulation parameters.

%% CST-validated element gain

% TEMPORARY VALUE — replace with actual CST result later.
G_ELEMENT_DBI = 6.16;
G_ELEMENT_LIN = 10^(G_ELEMENT_DBI / 10);


%% Transmit power

PT_DBM = 23;
PT_W = 10^((PT_DBM - 30) / 10);


%% IRS hardware power

PSTATIC_W = 3.0;
PC_W = 20e-3;


%% Channel parameters

FC_GHZ = 28;
BW_HZ = 200e6;
NF_DB = 7.0;
TEMP_K = 290;

% BS -> IRS distance
D_BS_IRS = 20;

N_TRIALS = 10000;


%% Noise power

NOISE_DBM = -174 ...
    + 10 * log10(BW_HZ) ...
    + NF_DB;

NOISE_W = 10^((NOISE_DBM - 30) / 10);


%% Sweep ranges

N_RANGE = 4:4:256;

BETA_RANGE = 0:0.05:1.0;

D_RANGE = 10:10:300;


%% Phase factors

KAPPA_CONT = 1.00;

KAPPA_3BIT = 0.84;

KAPPA_1BIT = 0.63;


%% Sensitivity analysis

PSTATIC_LIST = [1.5, 3.0, 4.8];

PC_LIST = [10e-3, 20e-3, 30e-3];


%% Relay reference power

% The relay power budget is fixed and does NOT change
% with the IRS element-count sweep.

N_REF_RELAY = 64;

P_RELAY_W = PT_W ...
    + PSTATIC_W ...
    + N_REF_RELAY * PC_W;


%% Create shared configuration structure

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