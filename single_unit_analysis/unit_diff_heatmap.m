function diff_counts = unit_diff_heatmap(spikes, bin_spec, ref_win)
% function unit_diff_heatmap = unit_diff_heatmap(SPIKES, BIN_SPEC, REF_WIN)
% 
% Creates a heatmap of unit / channel firing rates relative to a reference 
% window.
% 
% INPUTS:
% 
% SPIKES: an n_units x n_trials x n_spikes array of spike times, padded 
% with NaNs for empty values.
%
% OPTIONAL INPUTS:
% 
% BIN_SPEC: Specification of the time bins for counting spike responses for 
% the heat map. Can be provided as a single value to specify bin size, or
% as the edges of the bins to be used for binning responses, default is to 
% set bins between the range of spike times with 10ms bins:
% [min(spikes(:)):0.01:max(spikes(:))]
%
% REF_WIN: The window to use as a reference time period; differences in
% firing rate will be calculated with respect to the mean rate in this
% period. By default, the function will use the mean rate in the whole
% range of spike times.
% 
% OUTPUT:
% 
% DIFF_HEATMAP: The values used to generate the heatmap in the resulting
% image.
% 
% Joram van Rheede 2020/10/12


%% Setting defaults for optional inputs
if nargin < 2
    bin_edges 	= [min(spikes(:)):0.01:max(spikes(:))];
elseif isscalar(bin_spec)
    bin_edges   = [min(spikes(:)):bin_spec:max(spikes(:))];
elseif length(bin_spec) > 1
    bin_edges  	= bin_spec;
end


if nargin < 3
    ref_win     = [min(spikes(:)) max(spikes(:))];
end


%% Make a heatmap of colours that is white [1 1 1] in the middle, blue []
diff_heatmap            = ones(128,3);
diff_heatmap(1:64,1)    = linspace(0,1,64);
diff_heatmap(1:64,2)    = linspace(0,1,64);
diff_heatmap(65:128,2) 	= 1-linspace(0,1,64);
diff_heatmap(65:128,3) 	= 1-linspace(0,1,64);

% Hardcoded default smoothing window
smooth_win              = 7;

%%
bin_size        = mean(diff(bin_spec));

n_bins          = length(bin_edges) - 1;
n_units         = size(spikes,1);
count_data      = NaN(n_units,n_bins);
ref_rates       = NaN(n_units);
for a = 1:n_units
    count_data(a,:) = histcounts(spikes(a,:,:),bin_edges);
end

%% Convert to rate in Hz
count_data      = count_data / bin_size; 

ref_rates       = spike_rate_by_channel(spikes,ref_win);

diff_counts     = bsxfun(@minus,count_data,ref_rates); 

diff_counts     = smoothdata(diff_counts,2,'movmedian',smooth_win);


imagesc(diff_counts)
colormap(diff_heatmap)

c_lims      = get(gca,'CLim');
max_c_val   = max(abs(c_lims));
set(gca,'CLim',[-max_c_val max_c_val])
figure(gcf)

