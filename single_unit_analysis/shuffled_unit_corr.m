function [shuffled_coupling, shuffled_corr_matrix, shuffled_pairwise] = shuffled_unit_corr(binned_spikes, bin_lag, n_shuffles)
% function [shuffled_corr_matrix, shuffled_coupling] = shuffled_unit_corr(binned_spikes, bin_lag, n_shuffles)


n_trials    = size(binned_spikes,2);
n_units     = size(binned_spikes,1);

shuffled_matrices           = NaN(n_units,n_units,n_shuffles);
shuffled_coupling_score     = NaN(n_units,n_shuffles);
% Repeat for n_shuffles
for i = 1:n_shuffles
    
    
    shuffled_binned_spikes  = NaN(size(binned_spikes));
    % Do a separate shuffle of all trials for each unit
    for j = 1:n_units
        shuffled_binned_spikes(j,:,:)   = binned_spikes(j,randperm(n_trials),:);
    end
    
    [shuffled_coupling_score(:,i), shuffled_matrices(:,:,i)]  = unit_cross_corr(shuffled_binned_spikes, bin_lag);
end

shuffled_corr_matrix        = nansum(shuffled_matrices,3) / n_shuffles;
shuffled_pairwise           = uniq_pairs_from_corr_mat(shuffled_corr_matrix);
shuffled_coupling           = nansum(shuffled_coupling_score,2) / n_shuffles;
