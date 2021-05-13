function pair_vals  = uniq_pairs_from_corr_mat(corr_mat)
% function pair_vals  = uniq_pairs_from_corr_mat(xcorr_mat)
% Returns pair_vals, the unique pairs (excluding self-pairs) from a correlation 
% matrix xcorr_mat
% 

matrix_mask     = ones(size(corr_mat));
low_triang_mask = tril(matrix_mask,-1); % Lower triangular part excluding the diagonal (i.e. excluding self-pairings)

pair_vals       = corr_mat(logical(low_triang_mask));