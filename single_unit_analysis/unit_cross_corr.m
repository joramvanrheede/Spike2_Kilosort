function [unit_coupling_score, unit_xcorr_matrix, all_pair_corrs]  = unit_cross_corr(binned_spikes, bin_shift)
% function [unit_coupling_score, unit_xcorr_matrix]  = unit_cross_corr(binned_spikes, bin_shift)
% 


n_units         = size(binned_spikes,1);
n_trials        = size(binned_spikes,2);

% Loop over each trial
trial_xcorr_matrix               = NaN(n_units,n_units,n_trials);
for i = 1:n_trials
    trial_binned_spikes         = squeeze(binned_spikes(:,i,:));
    trial_binned_spikes         = trial_binned_spikes';
    
    xcorr_traces                = xcorr(trial_binned_spikes, bin_shift, 'normalized');
    max_xcorrs                  = max(xcorr_traces);
    
    trial_xcorr_matrix(:,:,i)   = reshape(max_xcorrs,n_units,n_units);
    
end

unit_xcorr_matrix       = nanmean(trial_xcorr_matrix,3);

identity_matrix         = logical(eye(n_units));

unit_xcorr_matrix(identity_matrix) = 0;

unit_coupling_score 	= nansum(unit_xcorr_matrix) / (n_units - 1);

all_pair_corrs       	= uniq_pairs_from_corr_mat(unit_xcorr_matrix);

% output: an n_units * n_units cross-correlation matrix?
% Do an xcorr on shuffled spike bins as control
% Can use monte carlo method, reshuffling spike trials, to get p value?