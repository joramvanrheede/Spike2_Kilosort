function [unit_burst_rate, burst_to_spike_ratio, unit_spikes_per_burst] = burst_rate_by_channel(spikes, time_win, max_intra_burst_ISI)
% function [unit_burst_rate, unit_spikes_per_burst] = burst_rate_by_channel(spikes, time_win, max_intra_burst_ISI)
% Quantify bursting

%% Input checks / fixing 
if nargin < 3
    max_intra_burst_ISI = 0.01;
end


%% 

n_units     = size(spikes,1);
n_trials    = size(spikes,2);

n_bursts                = NaN(n_units, n_trials);
n_spikes                = NaN(n_units, n_trials);
spikes_per_burst        = NaN(n_units, n_trials);
n_spikes_not_in_burst   = NaN(n_units, n_trials);
n_spikes_in_burst       = NaN(n_units, n_trials);
for a = 1:n_units
    for b = 1:n_trials
        
        these_spikes            = squeeze(spikes(a,b,:));
        these_spikes            = these_spikes(these_spikes >= time_win(1) & these_spikes <= time_win(2));
        
        
        
        these_spike_ISIs        = diff(these_spikes);
        
        q_inter_burst_gap       = these_spike_ISIs > max_intra_burst_ISI;
        
        burst_start_indices     = find(q_inter_burst_gap); 
        
        burst_start_diff        = diff(burst_start_indices);
        
        n_bursts(a,b)         	= sum(burst_start_diff > 1);
        n_spikes(a,b)           = sum(~isnan(these_spikes));
        spikes_per_burst(a,b)  	= mean(burst_start_diff(burst_start_diff > 1));
        
        n_spikes_not_in_burst(a,b)   = sum(burst_start_diff(burst_start_diff == 1));
        n_spikes_in_burst(a,b)       = sum(burst_start_diff(burst_start_diff > 1));
        
        
    end
end

% convert to rates
time_win_size       = time_win(2) - time_win(1);

burst_rates       	= n_bursts / time_win_size;
spike_rates         = n_spikes / time_win_size;

unit_burst_rate         = nanmean(burst_rates,2);
unit_spike_rate         = nanmean(spike_rates,2);
unit_spikes_per_burst   = nanmean(spikes_per_burst,2);

unit_mean_spikes_in_burst       = nanmean(n_spikes_in_burst,2);
unit_mean_spikes_not_in_burst   = nanmean(n_spikes_not_in_burst,2);

burst_to_spike_ratio    = unit_mean_spikes_in_burst ./ (unit_mean_spikes_in_burst + unit_mean_spikes_not_in_burst);
