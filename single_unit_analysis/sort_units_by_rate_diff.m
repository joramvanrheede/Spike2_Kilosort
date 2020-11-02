function [ordered_unit_spikes, sort_inds] = sort_units_by_rate_diff(unit_spikes,target_win, ref_win)
% function ordered_unit_spikes = sort_units_by_rate_diff(unit_spikes,ref_win,target_win)
%
% Will reorder an N_units x N_trials x Nspike_times matrix of spike times
% along the first axis (units) according to change in firing rate between a
% target window and a reference window. Units are sorted in descending
% order, i.e. units with the largest increase in firing rate in the target
% window vs. the reference window will be first, and units with the largest
% negative difference will be last. If no reference window is provided,
% unit spikes will instead be ordered simply by firing rate in the target
% window.
% 
% INPUTS:
% 
% UNIT_SPIKES: an N_units x N_trials x N_spike_times matrix of spike times,
% padded with NaNs for empty values.
% 
% TARGET_WIN: [tmin tmax] time window for the target firing rates. If no
% ref_win is specified, unit spikes will be sorted by the absolute firing
% rate in this window. Defaults to [min(UNIT_SPIKES(:)) max(UNIT_SPIKES(:))]
% if not specified.
% 
% REF_WIN: [tmin tmax] time window for reference / comparison with the
% target window. If provided, units spikes will be sorted according to the 
% difference between TARGET_WIN and REF_WIN.
% 
% OUTPUTs:
% 
% ORDERED_UNIT_SPIKES: N_units x N_trials X N_spike_times reordered spike
% times matrix, ordered along the first  in descending order according to
% firing rate (difference).
% 
% SORT_INDS: Indices used to reorder the original spike matrix:
% ordered_unit_spikes = unit_spikes(sort_inds,:,:)
%
%
% Joram van Rheede 2020_10_12

if nargin < 2
    target_win = [min(unit_spikes(:)) max(unit_spikes(:))];
end

if nargin < 3
    mode = 'abs';
else
    mode = 'diff';
end

target_rates    = spike_rate_by_channel(unit_spikes,target_win);

switch mode
    case 'diff'
        ref_rates       = spike_rate_by_channel(unit_spikes,ref_win);
        rate_diff       = target_rates - ref_rates;
        [~, sort_inds]	= sort(rate_diff,'descend');
    case 'abs'
        [~, sort_inds]	= sort(target_rates,'descend');
end
        
ordered_unit_spikes     = unit_spikes(sort_inds,:,:);
