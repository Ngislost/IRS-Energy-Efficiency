%% run_monte_carlo.m
% Monte Carlo simulation for IRS energy-efficiency comparison.
%
% NOTE:
% G_ELEMENT_DBI is currently a TEMPORARY CST placeholder.
% Replace it with the final CST-validated value when available.

clear;
clc;

%% Load configuration

matlab_root = fileparts(mfilename('fullpath'));
addpath(matlab_root);

cfg = config();

%% Simulation parameters

d = 100;                    % IRS-to-UE distance (m)
beta = 0.50;                % Fixed blockage probability
N_values = [32 64 128];     % Smoke-test element counts
n_trials = 100;             % Temporary smoke-test size

schemes = {'no_irs', 'passive', 'active', 'relay'};

%% Header

fprintf('\n========================================\n');
fprintf('       MONTE CARLO SMOKE TEST\n');
fprintf('========================================\n');

fprintf('\nParameters:\n');
fprintf('Distance:          %.1f m\n', d);
fprintf('Blockage beta:     %.2f\n', beta);
fprintf('Trials per point:  %d\n', n_trials);
fprintf('Temporary element gain: %.2f dBi\n', ...
    cfg.G_ELEMENT_DBI);

fprintf('\nRunning simulation...\n');

%% Initialize result storage

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

    % Temporary storage for this N
    SNR_sum = zeros(length(schemes), 1);
    EE_sum = zeros(length(schemes), 1);
    throughput_sum = zeros(length(schemes), 1);
    power_sum = zeros(length(schemes), 1);

    %% Trials

    for trial = 1:n_trials

        % ---------------------------------------------------------
        % Save RNG state BEFORE generating the channel realization.
        %
        % Each scheme will restore this state, so all schemes see
        % the same LOS/NLOS and shadow-fading realization.
        % ---------------------------------------------------------

        channel_rng_state = rng;

        for s = 1:length(schemes)

            scheme = schemes{s};

            % Restore identical channel realization for every scheme
            rng(channel_rng_state);

            %% Instantaneous SNR

            SNR_trial = compute_SNR( ...
                scheme, ...
                N, ...
                d, ...
                beta, ...
                cfg.G_ELEMENT_LIN, ...
                cfg);

            %% Instantaneous EE

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

        SNR_avg = SNR_sum(s) / n_trials;
        EE_avg = EE_sum(s) / n_trials;
        throughput_avg = throughput_sum(s) / n_trials;
        power_avg = power_sum(s) / n_trials;

        %% Store results

        results.(scheme).SNR(n_idx) = SNR_avg;
        results.(scheme).EE(n_idx) = EE_avg;
        results.(scheme).throughput(n_idx) = ...
            throughput_avg;
        results.(scheme).power(n_idx) = ...
            power_avg;

        %% Display

        SNR_avg_dB = 10 * log10(SNR_avg);

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
fprintf('%8s %12s %12s %12s %12s\n', ...
    'N', ...
    'no_irs', ...
    'passive', ...
    'active', ...
    'relay');

for n_idx = 1:length(N_values)

    fprintf( ...
        '%8d %12.2f %12.2f %12.2f %12.2f\n', ...
        N_values(n_idx), ...
        10 * log10(results.no_irs.SNR(n_idx)), ...
        10 * log10(results.passive.SNR(n_idx)), ...
        10 * log10(results.active.SNR(n_idx)), ...
        10 * log10(results.relay.SNR(n_idx)));

end

%% Store simulation metadata

results.N_values = N_values;
results.distance = d;
results.beta = beta;
results.n_trials = n_trials;
results.element_gain_dBi = cfg.G_ELEMENT_DBI;
results.element_gain_is_temporary = true;

%% Save results

results_dir = fullfile(matlab_root, 'results');

if ~exist(results_dir, 'dir')
    mkdir(results_dir);
end

results_file = fullfile( ...
    results_dir, ...
    'smoke_test_results.mat');

save(results_file, 'results');

fprintf('\nResults saved to:\n%s\n', results_file);

fprintf('\n========================================\n');
fprintf('       SMOKE TEST COMPLETE\n');
fprintf('========================================\n');