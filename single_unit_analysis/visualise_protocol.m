function fig_h = visualise_protocol(protocol_data, bin_size, target_win, ref_win)
% function fig_h = visualise_protocol(PROTOCOL_DATA, BIN_SIZE, TARGET_WIN, REF_WIN)
% 
% Quick raster plot, heatmap and psth function to visualise unit behaviour 
% in a given protocol for both cortex and thalamus.
%
% INPUTS:
% 
% PROTOCOL_DATA: 
% The data structure with sorted and curated data for a single protocol.
% 
% BIN_SIZE:
% The bin size to be used in the PSTH and the difference heatmap. Default
% is 0.01 (= 10ms for spike times in seconds)
% 
% TARGET_WIN:
% The time window of interest, e.g. during which an optogenetic manipulation 
% is ongoing, as [start_time end_time]
% 
% REF_WIN:
% The reference window to be used for calculating the differences in the
% difference heatmap, specified as [tmin tmax]. If not provided, by default 
% differences will be relative to the mean rate during the entire trial.
% 
% OUTPUTS:
%
% FIG_H:
% Handle of the figure with the protocol visualisation
% 
% Joram van Rheede 2020/10/12

if nargin < 4
    ref_win     = [0 protocol_data.trial_length];
end

% Get spikes from protocol_data structure
cortex_spikes       = protocol_data.cortex_spikes;
thalamus_spikes     = protocol_data.thalamus_spikes;

% re-order by firing rate difference (for visualisation)
cortex_spikes       = sort_units_by_rate_diff(cortex_spikes,target_win, ref_win);
thalamus_spikes  	= sort_units_by_rate_diff(thalamus_spikes,target_win, ref_win);


% Generate 10ms bins for the length of the trial
psth_bins           = [0:bin_size:protocol_data.trial_length];

%% Create figure and set its size
fig_h = figure;
set(fig_h,'Units','Normalized','Position',[0.1 0.1 0.8 0.8])

%% Make cortical raster plot
subplot(2,3,1)
raster_plot(cortex_spikes)
title('Raster for cortical units')
ylabel('Unit number')
xlabel('Time (s)')
fixplot

%% Make cortical difference heatmap
subplot(2,3,2)
unit_diff_heatmap(cortex_spikes,psth_bins,ref_win)
title('Difference map for cortical units')
ylabel('Unit number')
xlabel('Time (s)')
fixplot

%% Make cortical PSTH
subplot(2,3,3)
psth(cortex_spikes,psth_bins)
title('PSTH for cortical units')
ylabel('Spike count')
xlabel('Time (s)')
fixplot


%% Make thalamic raster plot
subplot(2,3,4)
raster_plot(thalamus_spikes)
title('Raster for thalamic units')
ylabel('Unit number')
xlabel('Time (s)')
fixplot


%% Make thalamic difference heatmap
subplot(2,3,5)
unit_diff_heatmap(thalamus_spikes,psth_bins,ref_win)
title('Difference map for thalamic units')
ylabel('Unit number')
xlabel('Time (s)')
fixplot


%% Make thalamic PSTH
subplot(2,3,6)
psth(thalamus_spikes,psth_bins)
title('PSTH for thalamic units')
ylabel('Spike count')
xlabel('Time (s)')
fixplot

