function [delta_rates, p_vals, h_up_down] = compare_firing_rates(spikes, baseline_window, target_window)
% function [delta_rates, p_val, H_up_down] = compare_firing_rates(spikes, baseline_window, target_window)
% Compares firing rates in spikes between 2 time windows, generating a
% delta spike rate as well as a nonparametric p value (based on differences 
% across multiple trials)
% 
% 

if isempty(spikes)
    delta_rates = NaN;
    p_vals      = NaN;
    h_up_down   = NaN;
    return
end

% Get spike rate in baseline window and target window for each trial
baseline_rates      = spike_rates_individual(spikes, baseline_window);
target_rates        = spike_rates_individual(spikes, target_window);

% Take the mean rate across trials in baseline and target windows
mean_baseline_rates = mean(baseline_rates,2);
mean_target_rates   = mean(target_rates,2);

% Calculate difference (delta) between target window and baseline window
delta_rates         = mean_target_rates - mean_baseline_rates;

%% now determine significance

n_units     = size(baseline_rates,1);

p_vals      = NaN(n_units,1);
h_vals      = NaN(n_units,1);
for a = 1:n_units
    % Do a paired t-test for each unit to determine whether there is a
    % significant difference between baseline and the target time window
    [p_vals(a), h_vals(a)]      = signrank(baseline_rates(a,:),target_rates(a,:));
end

h_up_down = h_vals .* sign(delta_rates);