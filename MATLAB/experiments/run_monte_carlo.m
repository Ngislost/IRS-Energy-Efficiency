%% run_monte_carlo.m
% Monte Carlo smoke test for IRS energy-efficiency comparison.
%
% This script is intended for model verification.
%
% For final paper experiments, replace:
%
%   N_values = [32 64 128]
%   n_trials = 100
%
% with the full configuration ranges.

clear;
clc;

%% Reproducibility

rng(42);

%% Locate MATLAB root

matlab_root = fileparts(mfilename('fullpath'));

addpath(matlab_root);

%% Load configuration

cfg = config();


%% Smoke-test parameters

d = 100;                    % IRS-to-UE distance (m)

beta = 0.50;                % Blockage probability

N_values = [32 64 128];     % Smoke-test IRS sizes

n_trials = 100;             % Smoke-test trial count


%% Schemes

schemes = { ...
    'no_irs', ...
    'passive', ...
    'active', ...
    'relay'};


%% Header

fprintf('\n========================================\n');
fprintf('       MONTE CARLO SMOKE TEST\n');
fprintf('========================================\n');

fprintf('\nParameters:\n');

fprintf('Distance:          %.1f m\n', d);

fprintf('Blockage beta:     %.2f\n', beta);

fprintf('Trials per point:  %d\n', n_trials);

fprintf('Element gain:      %.3f dBi\n', ...
    cfg.G_ELEMENT_DBI);

fprintf('Noise power:       %.4e W\n', ...
    cfg.NOISE_W);

fprintf('Relay power:       %.4f W\n', ...
    cfg.P_RELAY_W);

fprintf('\nRunning simulation...\n');


%% Initialize results

results = struct();

for s = 1:length(schemes)

    scheme = schemes{s};

    results.(scheme).SNR = ...
        zeros(length(N_values), 1);

    results.(scheme).EE = ...
        zeros(length(N_values), 1);

    results.(scheme).throughput = ...
        zeros(length(N_values), 1);

    results.(scheme).power = ...
        zeros(length(N_values), 1);

end


%% Monte Carlo simulation

for n_idx = 1:length(N_values)

    N = N_values(n_idx);

    fprintf('\nN = %d\n', N);


    %% Accumulators

    SNR_sum = ...
        zeros(length(schemes), 1);

    EE_sum = ...
        zeros(length(schemes), 1);

    throughput_sum = ...
        zeros(length(schemes), 1);

    power_sum = ...
        zeros(length(schemes), 1);


    %% Trials

    for trial = 1:n_trials

        % Save RNG state before generating this channel realization.
        %
        % All schemes will use the same channel realization.

        channel_rng_state = rng;


        for s = 1:length(schemes)

            scheme = schemes{s};

            % Restore identical channel realization.

            rng(channel_rng_state);


            %% Compute instantaneous SNR

            SNR_trial = compute_SNR( ...
                scheme, ...
                N, ...
                d, ...
                beta, ...
                cfg.G_ELEMENT_LIN, ...
                cfg);


            %% Compute instantaneous EE

            [EE_trial, ...
             throughput_trial, ...
             power_trial] = compute_EE( ...
                SNR_trial, ...
                scheme, ...
                N, ...
                cfg);


            %% Accumulate

            SNR_sum(s) = ...
                SNR_sum(s) + SNR_trial;

            EE_sum(s) = ...
                EE_sum(s) + EE_trial;

            throughput_sum(s) = ...
                throughput_sum(s) + throughput_trial;

            power_sum(s) = ...
                power_sum(s) + power_trial;

        end

    end


    %% Average over trials

    for s = 1:length(schemes)

        scheme = schemes{s};


        SNR_avg = ...
            SNR_sum(s) / n_trials;

        EE_avg = ...
            EE_sum(s) / n_trials;

        throughput_avg = ...
            throughput_sum(s) / n_trials;

        power_avg = ...
            power_sum(s) / n_trials;


        %% Store results

        results.(scheme).SNR(n_idx) = ...
            SNR_avg;

        results.(scheme).EE(n_idx) = ...
            EE_avg;

        results.(scheme).throughput(n_idx) = ...
            throughput_avg;

        results.(scheme).power(n_idx) = ...
            power_avg;


        %% Display

        SNR_avg_dB = ...
            10 * log10(max(SNR_avg, eps));


        fprintf( ...
            '%-10s : SNR = %7.2f dB | EE = %.4e bit/J\n', ...
            scheme, ...
            SNR_avg_dB, ...
            EE_avg);

    end

end


%% Results summary

fprintf('\n========================================\n');
fprintf('       SMOKE TEST RESULTS\n');
fprintf('========================================\n');

fprintf('\n');

fprintf( ...
    '%8s %12s %12s %12s %12s\n', ...
    'N', ...
    'no_irs', ...
    'passive', ...
    'active', ...
    'relay');


for n_idx = 1:length(N_values)

    fprintf( ...
        '%8d %12.2f %12.2f %12.2f %12.2f\n', ...
        N_values(n_idx), ...
        10 * log10(max( ...
            results.no_irs.SNR(n_idx), eps)), ...
        10 * log10(max( ...
            results.passive.SNR(n_idx), eps)), ...
        10 * log10(max( ...
            results.active.SNR(n_idx), eps)), ...
        10 * log10(max( ...
            results.relay.SNR(n_idx), eps)));

end


%% Store metadata

results.N_values = N_values;

results.distance = d;

results.beta = beta;

results.n_trials = n_trials;

results.element_gain_dBi = ...
    cfg.G_ELEMENT_DBI;

results.element_gain_is_temporary = false;

results.random_seed = 42;

results.relay_reference_N = ...
    cfg.N_REF_RELAY;

results.relay_power_W = ...
    cfg.P_RELAY_W;


%% Save results

results_dir = ...
    fullfile(matlab_root, 'results');


if ~exist(results_dir, 'dir')

    mkdir(results_dir);

end


results_file = ...
    fullfile( ...
        results_dir, ...
        'smoke_test_results.mat');


save( ...
    results_file, ...
    'results');


fprintf('\nResults saved to:\n%s\n', results_file);


%% Complete

fprintf('\n========================================\n');
fprintf('       SMOKE TEST COMPLETE\n');
fprintf('========================================\n');