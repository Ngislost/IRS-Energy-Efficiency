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


%% CHECK 1 — LOS path loss at 100 m

fprintf('\nCHECK 1 — LOS Path Loss\n');

PL_expected = 32.4 ...
    + 20*log10(28) ...
    + 20*log10(100);

fprintf('Expected deterministic PL: %.2f dB\n', PL_expected);

PL_test = path_loss_dB(100, true);

fprintf('Sampled PL from function: %.2f dB\n', PL_test);

fprintf('Difference from expected: %.2f dB\n', ...
    PL_test - PL_expected);


%% CHECK 2 — LOS probability

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


%% CHECK 3 — Deterministic LOS vs NLOS path loss

fprintf('\nCHECK 3 — LOS vs NLOS Path Loss\n');

d = 100;

PL_LOS = 32.4 ...
    + 20*log10(28) ...
    + 20*log10(d);

PL_NLOS = PL_LOS + 20;

fprintf('Deterministic LOS PL  at 100 m: %.2f dB\n', PL_LOS);
fprintf('Deterministic NLOS PL at 100 m: %.2f dB\n', PL_NLOS);

if PL_LOS < PL_NLOS
    fprintf('PASS: LOS path loss < NLOS path loss\n');
else
    fprintf('FAIL: LOS path loss should be less than NLOS path loss\n');
end


%% CHECK 4 — Passive IRS vs No IRS

fprintf('\nCHECK 4 — SNR comparison\n');

N = 64;
d = 100;
beta = 0.5;

SNR_irs = compute_SNR( ...
    'passive', ...
    N, ...
    d, ...
    beta, ...
    cfg.G_ELEMENT_LIN, ...
    cfg);

SNR_no_irs = compute_SNR( ...
    'no_irs', ...
    1, ...
    d, ...
    beta, ...
    cfg.G_ELEMENT_LIN, ...
    cfg);

SNR_irs_dB = 10*log10(SNR_irs);
SNR_no_irs_dB = 10*log10(SNR_no_irs);

fprintf('Passive IRS SNR: %.2f dB\n', SNR_irs_dB);
fprintf('No-IRS SNR:      %.2f dB\n', SNR_no_irs_dB);

fprintf('IRS improvement: %.2f dB\n', ...
    SNR_irs_dB - SNR_no_irs_dB);

if SNR_irs > SNR_no_irs
    fprintf('PASS: Passive IRS improves SNR\n');
else
    fprintf('WARNING: Passive IRS does not improve SNR\n');
end


%% Final message

fprintf('\n========================================\n');
fprintf('       VALIDATION COMPLETE\n');
fprintf('========================================\n');