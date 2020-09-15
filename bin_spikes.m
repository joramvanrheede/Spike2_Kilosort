function binned_spikes = bin_spikes(spike_times, bin_size, max_edge)
% function binned_spikes = bin_spikes(spike_times, bin_size)
% 

% min_val     = min(spike_times(:));
% 
% 
% min_edge    = floor(min_val / bin_size) * bin_size

if nargin < 3
    max_val     = max(spike_times(:));
    max_edge    = ceil(max_val / bin_size) * bin_size;
end

min_edge      	= 0;

edges           = min_edge:bin_size:max_edge;
n_bins          = length(edges) - 1;

spike_dims      = size(spike_times);


binned_spikes = NaN(spike_dims(1), spike_dims(2), n_bins);
% Loop over channels / units
for a = 1:size(spike_times,1)
    % Loop over trials
    for b = 1:size(spike_times,2)
        binned_spikes(a,b,1:n_bins)     = histcounts(spike_times(a,b,:),edges);
    end
end
