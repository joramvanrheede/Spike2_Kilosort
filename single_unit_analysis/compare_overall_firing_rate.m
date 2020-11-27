function [delta_rate, p_val, h_up_down] = compare_overall_firing_rate(spikes, baseline_window, target_window)
% function [delta_rates, p_val, H_up_down] = compare_overall_firing_rate(spikes, baseline_window, target_window)
% Compares firing rates in spikes between 2 time windows, generating a
% delta spike rate as well as a nonparametric p value (based on differences 
% across multiple trials). All channels / units are lumped together to generate
% a single delta_rate, p_value and h_up_down
% 
% 

if isempty(spikes)
    delta_rate  = NaN;
    p_val       = NaN;
    h_up_down   = NaN;
    return
end

% Get spike rate in baseline window and target window for each trial
baseline_rates      = spike_rate_by_trial(spikes, baseline_window);
target_rates        = spike_rate_by_trial(spikes, target_window);

% Take the mean rate across trials in baseline and target windows
mean_baseline_rate  = mean(baseline_rates);
mean_target_rate    = mean(target_rates);

% Calculate difference (delta) between target window and baseline window
delta_rate          = mean_target_rate - mean_baseline_rate;

%% now determine significance

% Do a paired nonparametric test to determine whether there is a
% significant difference between baseline and the target time window
[p_val, h]          = signrank(baseline_rates,target_rates);

h_up_down           = h .* sign(delta_rate);