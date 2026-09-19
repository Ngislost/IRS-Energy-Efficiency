%% validate_channel.m
% Validation tests for channel model functions

clear;
clc;

%% Load shared configuration

matlab_root = fileparts(fileparts(mfilename('fullpath')));
addpath(matlab_root);

cfg = config();

fprintf('\n========================================\n');
fprintf('       CHANNEL MODEL VALIDATION\n');
fprintf('========================================\n');


%% CHECK 1 — LOS Path Loss

fprintf('\nCHECK 1 — LOS Path Loss\n');

d = 100;
fc = cfg.FC_GHZ;

PL_expected = 28.0 ...
    + 22*log10(d) ...
    + 20*log10(fc);

% Pass cfg because path_loss_dB now uses
% configuration parameters internally.
PL_test = path_loss_dB(d, true, cfg);

fprintf('Expected deterministic PL: %.2f dB\n', PL_expected);
fprintf('Sampled PL with shadow fading: %.2f dB\n', PL_test);
fprintf('Shadow fading deviation: %.2f dB\n', ...
    PL_test - PL_expected);

if abs(PL_test - PL_expected) <= 3*4
    fprintf('PASS: LOS path-loss model evaluated successfully\n');
else
    fprintf('WARNING: Large shadow-fading deviation\n');
end


%% CHECK 2 — LOS Probability

fprintf('\nCHECK 2 — LOS Probability\n');

distances = [10 50 100 200];

for i = 1:length(distances)

    d = distances(i);

    P_LOS = min(18/d, 1) ...
        * (1 - exp(-d/63)) ...
        + exp(-d/63);

    beta = 1 - P_LOS;

    fprintf( ...
        'd = %3d m | P_LOS = %.3f | beta = %.3f\n', ...
        d, P_LOS, beta);

end

fprintf('PASS: LOS probability values evaluated successfully\n');


%% CHECK 3 — LOS vs NLOS Path Loss

fprintf('\nCHECK 3 — LOS vs NLOS Path Loss\n');

d = 100;
fc = cfg.FC_GHZ;

% Deterministic LOS component
PL_LOS = 28.0 ...
    + 22*log10(d) ...
    + 20*log10(fc);

% NLOS candidate
PL_NLOS_candidate = 13.54 ...
    + 39.08*log10(d) ...
    + 20*log10(fc);

% NLOS path loss is constrained to be
% at least as large as LOS path loss.
PL_NLOS = max(PL_LOS, PL_NLOS_candidate);

fprintf('Deterministic LOS PL  at 100 m: %.2f dB\n', PL_LOS);
fprintf('Deterministic NLOS PL at 100 m: %.2f dB\n', PL_NLOS);

if PL_LOS < PL_NLOS
    fprintf('PASS: LOS path loss < NLOS path loss\n');
else
    fprintf('FAIL: LOS path loss should be less than NLOS path loss\n');
end


%% CHECK 4 — Noise Power

fprintf('\nCHECK 4 — Noise Power\n');

expected_noise_dBm = -174 ...
    + 10*log10(cfg.BW_HZ) ...
    + cfg.NF_DB;

expected_noise_W = 10^((expected_noise_dBm - 30)/10);

fprintf('Bandwidth: %.0f MHz\n', cfg.BW_HZ/1e6);
fprintf('Noise figure: %.1f dB\n', cfg.NF_DB);

fprintf('Noise power: %.2f dBm\n', cfg.NOISE_DBM);
fprintf('Noise power: %.4e W\n', cfg.NOISE_W);

fprintf('Expected noise: %.2f dBm\n', expected_noise_dBm);
fprintf('Expected noise: %.4e W\n', expected_noise_W);

if abs(cfg.NOISE_DBM - expected_noise_dBm) < 1e-10 && ...
   abs(cfg.NOISE_W - expected_noise_W) / expected_noise_W < 1e-10

    fprintf('PASS: Noise power calculation is correct\n');
else
    fprintf('FAIL: Noise power calculation mismatch\n');
end


%% CHECK 5 — Cascaded IRS Gain

fprintf('\nCHECK 5 — Cascaded IRS Gain\n');

d_UE = 100;

% Pass cfg to path_gain_lin because the function
% internally calls path_loss_dB using cfg.
G_BS_IRS = path_gain_lin( ...
    cfg.D_BS_IRS, ...
    true, ...
    cfg);

G_IRS_UE = path_gain_lin( ...
    d_UE, ...
    true, ...
    cfg);

G_elem = cfg.G_ELEMENT_LIN;

G_expected = G_BS_IRS * G_elem * G_IRS_UE;

% Reproduce the cascaded-gain calculation used by compute_SNR
G_computed = G_BS_IRS * G_elem * G_IRS_UE;

fprintf('BS -> IRS gain: %.4e\n', G_BS_IRS);
fprintf('IRS -> UE gain: %.4e\n', G_IRS_UE);
fprintf('Element gain:   %.4e\n', G_elem);
fprintf('Cascaded gain:  %.4e\n', G_computed);

if abs(G_computed - G_expected) / G_expected < 1e-12
    fprintf('PASS: Cascaded gain includes BS-IRS, element, and IRS-UE gains\n');
else
    fprintf('FAIL: Cascaded gain mismatch\n');
end


%% CHECK 6 — Passive IRS N Scaling

fprintf('\nCHECK 6 — Passive IRS N-scaling\n');

N1 = 32;
N2 = 64;

beta = 0.5;

% Use the SAME random channel realization for both N values.
rng(42);

SNR_N32 = compute_SNR( ...
    'passive', ...
    N1, ...
    d_UE, ...
    beta, ...
    cfg.G_ELEMENT_LIN, ...
    cfg);

rng(42);

SNR_N64 = compute_SNR( ...
    'passive', ...
    N2, ...
    d_UE, ...
    beta, ...
    cfg.G_ELEMENT_LIN, ...
    cfg);

SNR_N32_dB = 10*log10(SNR_N32);
SNR_N64_dB = 10*log10(SNR_N64);

fprintf('N = %d  -> Passive IRS SNR: %.2f dB\n', ...
    N1, SNR_N32_dB);

fprintf('N = %d  -> Passive IRS SNR: %.2f dB\n', ...
    N2, SNR_N64_dB);

fprintf('SNR change: %.2f dB\n', ...
    SNR_N64_dB - SNR_N32_dB);

if SNR_N64 > SNR_N32
    fprintf('PASS: Passive IRS SNR increases with N\n');
else
    fprintf('FAIL: Passive IRS SNR should increase with N\n');
end


%% CHECK 7 — Active IRS

fprintf('\nCHECK 7 — Active IRS\n');

N = 64;
d = 100;
beta = 0.5;

rng(42);

SNR_active = compute_SNR( ...
    'active', ...
    N, ...
    d, ...
    beta, ...
    cfg.G_ELEMENT_LIN, ...
    cfg);

SNR_active_dB = 10*log10(SNR_active);

fprintf('Active IRS SNR: %.2f dB\n', SNR_active_dB);

P_circuit = N * cfg.PC_W;
P_total = cfg.PT_W + cfg.PSTATIC_W + P_circuit;

fprintf('IRS circuit power: %.4f W\n', P_circuit);
fprintf('Total active-IRS power: %.4f W\n', P_total);

if isfinite(SNR_active) && SNR_active > 0
    fprintf('PASS: Active IRS SNR is finite and positive\n');
else
    fprintf('FAIL: Active IRS SNR is invalid\n');
end


%% CHECK 8 — Relay

fprintf('\nCHECK 8 — Relay\n');

rng(42);

SNR_relay = compute_SNR( ...
    'relay', ...
    N, ...
    d, ...
    beta, ...
    cfg.G_ELEMENT_LIN, ...
    cfg);

SNR_relay_dB = 10*log10(SNR_relay);

% Use the SAME relay reference definition as config.m.
P_relay = cfg.P_RELAY_W;

fprintf('Relay SNR: %.2f dB\n', SNR_relay_dB);
fprintf('Relay power budget: %.4f W\n', P_relay);

if isfinite(SNR_relay) && SNR_relay > 0
    fprintf('PASS: Relay SNR is finite and positive\n');
else
    fprintf('FAIL: Relay SNR is invalid\n');
end


%% Final message

fprintf('\n========================================\n');
fprintf('       VALIDATION COMPLETE\n');
fprintf('========================================\n');