% Extract synchrony cross-correlation measure across protocols

% Window for assessing baseline firing rate
baseline_win        = [0 4];

% Window for assessing firing rate during the optogenetic manipulation
target_win       	= [5.1 9.1];

% Window for assessing full trial firing rate
full_trial_win      = [0 15];

%% Selection criteria:

% Minimum (cortical unit) firing rate across ALL THREE protocols
min_firing_rate    	= 0.1;

% Thalamic firing rate criteria:

% /!\ Note the following comments: /!\

% SESSIONS are included if they meet EITHER the following two criteria:
max_thal_p         	= 0.05; % maximum p_value 
min_thal_rate     	= 0; % minimal thalamic firing rate

% OR the following criterion:
min_thal_resp_units = 3; % minimum number of significantly responsive units in thalamus

% /!\ OR BOTH! /!\

%% Some cross-correlation settings - probably leave on these defaults

% How many times to shuffle trials for the shuffled data:
n_shuffles          = 10;

% bin size of binned spike data - DO NOT CHANGE
bin_size            = 0.01;

% maximum lag for cross-correlation
xcorr_bin_lag       = 1;

% time vector for the bins
bin_vec             = 0:bin_size:(1500*bin_size);
bin_vec             = bin_vec(1:end-1);

% Selection boolean to select appropriate sections of binned spike data
baseline_bins       = bin_vec >= baseline_win(1) & bin_vec < baseline_win(2);
target_bins         = bin_vec >= target_win(1) & bin_vec < target_win(2);
    
unit_results_table  = [];
for i = 1:length(matched_ChR2)
    
    %% Get spike data from data structures
    ChR2_cortex_spikes          = matched_ChR2(i).cortex_spikes;
    ArchT_cortex_spikes         = matched_ArchT(i).cortex_spikes;
    ChR2_ArchT_cortex_spikes    = matched_ChR2_ArchT(i).cortex_spikes;
    
    ChR2_cortex_binned_spikes          = matched_ChR2(i).cortex_binned_spikes;
    ArchT_cortex_binned_spikes         = matched_ArchT(i).cortex_binned_spikes;
    ChR2_ArchT_cortex_binned_spikes    = matched_ChR2_ArchT(i).cortex_binned_spikes;
    
    ChR2_thalamus_spikes       	= matched_ChR2(i).thalamus_spikes;
    ArchT_thalamus_spikes      	= matched_ArchT(i).thalamus_spikes;
    ChR2_ArchT_thalamus_spikes  = matched_ChR2_ArchT(i).thalamus_spikes;
    
    %% Look at thalamic firing rates and see if overall thalamic firing rate of identified thalamic units is up
    
    % Get delta rate and p-value over all units
    [ChR2_thalamus_delta_rate, ChR2_thalamus_p, ChR2_thalamus_h]                  	= compare_overall_firing_rate(ChR2_thalamus_spikes,baseline_win, target_win);
    [ArchT_thalamus_delta_rate, ArchT_thalamus_p, ArchT_thalamus_h]                	= compare_overall_firing_rate(ArchT_thalamus_spikes,baseline_win, target_win);
    [ChR2_ArchT_thalamus_delta_rate, ChR2_ArchT_thalamus_p, ChR2_ArchT_thalamus_h]	= compare_overall_firing_rate(ChR2_ArchT_thalamus_spikes,baseline_win, target_win);
    
    % Get delta rates and p-values for individual units
    [ChR2_unit_thalamus_delta_rate, ~, ChR2_thalamus_unit_h]            = compare_firing_rates(ChR2_thalamus_spikes,baseline_win,target_win);
    [ArchT_unit_thalamus_delta_rate, ~, ArchT_thalamus_h]               = compare_firing_rates(ArchT_thalamus_spikes,baseline_win,target_win);
    [ChR2_ArchT_unit_thalamus_delta_rate, ~, ChR2_ArchT_thalamus_h]     = compare_firing_rates(ChR2_ArchT_thalamus_spikes,baseline_win,target_win);
    
    %% Select for thalamic activity 
    if ~isnan(ChR2_thalamus_p)
        q_thal_resp     = (ChR2_thalamus_p <= max_thal_p) & (ChR2_thalamus_delta_rate >= min_thal_rate);
    elseif ~isnan(ChR2_ArchT_thalamus_p)
        q_thal_resp     = (ChR2_thalamus_p <= max_thal_p) & (ChR2_thalamus_delta_rate >= min_thal_rate);
    else
        q_thal_resp     = false;
    end
    
    if ~isnan(ChR2_thalamus_unit_h)
        q_thal_unit_resp    = sum(ChR2_thalamus_unit_h == 1) >= min_thal_resp_units;
    elseif ~isnan(ChR2_ArchT_thalamus_unit_h)
        q_thal_unit_resp    = sum(ChR2_ArchT_thalamus_unit_h == 1) >= min_thal_resp_units;
    else
        q_thal_unit_resp = false;
    end
    
    % If not thalamically responsive, do not analyse further; move on to next session
    if ~q_thal_resp && ~q_thal_unit_resp
        continue
    end
    
    
    %% select for firing rate
    ChR2_unit_trial_rate                = spike_rate_by_channel(ChR2_cortex_spikes, full_trial_win);
    q_ChR2_rate                         = ChR2_unit_trial_rate >= min_firing_rate;
    
    ArchT_unit_trial_rate            	= spike_rate_by_channel(ArchT_cortex_spikes, full_trial_win);
    q_ArchT_rate                        = ArchT_unit_trial_rate >= min_firing_rate;
    
    ChR2_ArchT_unit_trial_rate       	= spike_rate_by_channel(ChR2_ArchT_cortex_spikes, full_trial_win);
    q_ChR2_ArchT_rate               	= ChR2_ArchT_unit_trial_rate >= min_firing_rate;
    
    if isempty(q_ChR2_rate)
        q_ChR2_rate     = ones(size(q_ChR2_ArchT_rate));
    end
    if isempty(q_ArchT_rate)
        q_ArchT_rate    = ones(size(q_ChR2_ArchT_rate));
    end
    if isempty(q_ChR2_ArchT_rate)
        q_ChR2_ArchT_rate   = ones(size(q_ChR2_rate));
    end
    
    q_all_rate                          = q_ChR2_rate & q_ArchT_rate & q_ChR2_ArchT_rate;
    
    if ~isempty(ChR2_cortex_spikes)
        ChR2_cortex_binned_spikes           = ChR2_cortex_binned_spikes(q_all_rate,:,:);
        ChR2_cortex_spikes                  = ChR2_cortex_spikes(q_all_rate,:,:);
    end
    if ~isempty(ArchT_cortex_spikes)
        ArchT_cortex_binned_spikes       	= ArchT_cortex_binned_spikes(q_all_rate,:,:);
        ArchT_cortex_spikes                 = ArchT_cortex_spikes(q_all_rate,:,:);
    end
    if ~isempty(ChR2_ArchT_cortex_spikes)
        ChR2_ArchT_cortex_binned_spikes   	= ChR2_ArchT_cortex_binned_spikes(q_all_rate,:,:);
        ChR2_ArchT_cortex_spikes          	= ChR2_ArchT_cortex_spikes(q_all_rate,:,:);
    end
    
    %% Find the number of units, and get unit_depths and session ID information from a non-empty protocol

    ChR2_n          = size(ChR2_cortex_spikes,1);
    ArchT_n         = size(ArchT_cortex_spikes,1);
    ChR2_ArchT_n    = size(ChR2_ArchT_cortex_spikes,1);
    
    [n_units, max_ind]  = max([ChR2_n ArchT_n ChR2_ArchT_n]);
    
    % Get unit depths and session ID from a non-empty protocol
    switch max_ind
        case 1
            unit_depths = matched_ChR2(i).cortex_adjusted_unit_depth;
            session_id  = matched_ChR2(i).session_ID;
        case 2
            unit_depths = matched_ArchT(i).cortex_adjusted_unit_depth;
            session_id  = matched_ArchT(i).session_ID; 
        case 3
            unit_depths = matched_ChR2_ArchT(i).cortex_adjusted_unit_depth;
            session_id  = matched_ChR2_ArchT(i).session_ID;
    end
    
    unit_depths         = unit_depths(q_all_rate);
    
    unit_nrs            = find(q_all_rate);
    
    unique_unit_ids     = [];
    for j = 1:n_units
        unit_id_str     = num2str(unit_nrs(j),'%02.f');
        unique_unit_ids{j} = [session_id '_' unit_id_str];
    end
    
    % pre-making this this will be useful for missing data
    nan_array           = NaN(n_units,1);
    
    %% ChR2-only data
    
    if ~isempty(ChR2_cortex_spikes)
        ChR2_baseline_coupling            = unit_cross_corr(ChR2_cortex_binned_spikes(:,:,baseline_bins), xcorr_bin_lag);
        ChR2_target_coupling              = unit_cross_corr(ChR2_cortex_binned_spikes(:,:,target_bins), xcorr_bin_lag);
        
        ChR2_shuffled_baseline_coupling  	= shuffled_unit_corr(ChR2_cortex_binned_spikes(:,:,baseline_bins), xcorr_bin_lag, n_shuffles);
        ChR2_shuffled_target_coupling    	= shuffled_unit_corr(ChR2_cortex_binned_spikes(:,:,target_bins), xcorr_bin_lag, n_shuffles);
        
        ChR2_trial_rates                  = spike_rate_by_channel(ChR2_cortex_spikes,full_trial_win);
    else
        ChR2_baseline_coupling            = nan_array;
        ChR2_target_coupling              = nan_array;
        ChR2_shuffled_baseline_coupling   = nan_array;
        ChR2_shuffled_target_coupling     = nan_array;
        ChR2_trial_rates                  = nan_array;
    end
    
    %% ChR2-only data
    
    if ~isempty(ArchT_cortex_spikes)
        ArchT_baseline_coupling            = unit_cross_corr(ArchT_cortex_binned_spikes(:,:,baseline_bins), xcorr_bin_lag);
        ArchT_target_coupling              = unit_cross_corr(ArchT_cortex_binned_spikes(:,:,target_bins), xcorr_bin_lag);
        
        ArchT_shuffled_baseline_coupling  	= shuffled_unit_corr(ArchT_cortex_binned_spikes(:,:,baseline_bins), xcorr_bin_lag, n_shuffles);
        ArchT_shuffled_target_coupling    	= shuffled_unit_corr(ArchT_cortex_binned_spikes(:,:,target_bins), xcorr_bin_lag, n_shuffles);
        
        ArchT_trial_rates                  = spike_rate_by_channel(ArchT_cortex_spikes,full_trial_win);
    else
        ArchT_baseline_coupling            = nan_array;
        ArchT_target_coupling              = nan_array;
        ArchT_shuffled_baseline_coupling   = nan_array;
        ArchT_shuffled_target_coupling     = nan_array;
        ArchT_trial_rates                  = nan_array;
    end
    
    %% ChR2_ArchT-only data
    
    if ~isempty(ChR2_ArchT_cortex_spikes)
        ChR2_ArchT_baseline_coupling            = unit_cross_corr(ChR2_ArchT_cortex_binned_spikes(:,:,baseline_bins), xcorr_bin_lag);
        ChR2_ArchT_target_coupling              = unit_cross_corr(ChR2_ArchT_cortex_binned_spikes(:,:,target_bins), xcorr_bin_lag);
        
        ChR2_ArchT_shuffled_baseline_coupling  	= shuffled_unit_corr(ChR2_ArchT_cortex_binned_spikes(:,:,baseline_bins), xcorr_bin_lag, n_shuffles);
        ChR2_ArchT_shuffled_target_coupling    	= shuffled_unit_corr(ChR2_ArchT_cortex_binned_spikes(:,:,target_bins), xcorr_bin_lag, n_shuffles);
        
        ChR2_ArchT_trial_rates                  = spike_rate_by_channel(ChR2_ArchT_cortex_spikes,full_trial_win);
    else
        ChR2_ArchT_baseline_coupling            = nan_array;
        ChR2_ArchT_target_coupling              = nan_array;
        ChR2_ArchT_shuffled_baseline_coupling   = nan_array;
        ChR2_ArchT_shuffled_target_coupling     = nan_array;
        ChR2_ArchT_trial_rates                  = nan_array;
    end
    

    
    %% 
    ChR2_thalamus_delta_rate        = ChR2_thalamus_delta_rate * ones(n_units,1);
    ChR2_thalamus_p                 = ChR2_thalamus_p * ones(n_units,1);
    
    ArchT_thalamus_delta_rate       = ArchT_thalamus_delta_rate * ones(n_units,1);
   	ArchT_thalamus_p                = ArchT_thalamus_p * ones(n_units,1);
    
   	ChR2_ArchT_thalamus_delta_rate 	= ChR2_ArchT_thalamus_delta_rate * ones(n_units,1);
   	ChR2_ArchT_thalamus_p          	= ChR2_ArchT_thalamus_p * ones(n_units,1);
    
    
    %% Make a table of the results for this session
    this_results_table  = table(unique_unit_ids(:), unit_depths, repmat(n_units,size(unit_depths)), ...
                                ChR2_thalamus_delta_rate, ChR2_thalamus_p, ChR2_baseline_coupling(:), ChR2_target_coupling(:), ChR2_trial_rates, ChR2_shuffled_baseline_coupling(:), ChR2_shuffled_target_coupling(:), ...
                                ArchT_thalamus_delta_rate, ArchT_thalamus_p, ArchT_baseline_coupling(:), ArchT_target_coupling(:), ArchT_trial_rates, ArchT_shuffled_baseline_coupling(:), ArchT_shuffled_target_coupling(:), ...
                              	ChR2_ArchT_thalamus_delta_rate, ChR2_ArchT_thalamus_p, ChR2_ArchT_baseline_coupling(:), ChR2_ArchT_target_coupling(:), ChR2_ArchT_trial_rates, ChR2_ArchT_shuffled_baseline_coupling(:), ChR2_ArchT_shuffled_target_coupling(:), ...
                              	'VariableNames',{'unit_id', 'unit_depth','n_cortical_units' ...
                               	'ChR2_thal_delta', 'ChR2_thal_p','ChR2_baseline_coupling','ChR2_target_coupling','ChR2_trial_rate','ChR2_shuffled_baseline_coupling','ChR2_shuffled_target_coupling', ...
                               	'ArchT_thal_delta', 'ArchT_thal_p','ArchT_baseline_coupling','ArchT_target_coupling','ArchT_trial_rate','ArchT_shuffled_baseline_coupling','ArchT_shuffled_target_coupling', ...
                               	'ChR2_ArchT_thal_delta', 'ChR2_ArchT_thal_p','ChR2_ArchT_baseline_coupling','ChR2_ArchT_target_coupling','ChR2_ArchT_trial_rate','ChR2_ArchT_shuffled_baseline_coupling','ChR2_ArchT_shuffled_target_coupling'});
    
  	% Add the results for this session to the big unit_results_table:
	unit_results_table  = [unit_results_table; this_results_table];
end
% output is 'unit_results_table':
% a table with 1 entry (row) for each cortical unit
