% Extract firing rates across protocols

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

%% 

unit_results_table  = [];
for i = 1:length(matched_ChR2)
    
    %% Get spike data from data structures
    ChR2_cortex_spikes          = matched_ChR2(i).cortex_spikes;
    ArchT_cortex_spikes         = matched_ArchT(i).cortex_spikes;
    ChR2_ArchT_cortex_spikes    = matched_ChR2_ArchT(i).cortex_spikes;
    
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
    
    ChR2_n_thalamus_up      = sum(ChR2_thalamus_unit_h == 1);
    ChR2_n_thalamus_down    = sum(ChR2_thalamus_unit_h == -1);
    
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
        ChR2_cortex_spikes                  = ChR2_cortex_spikes(q_all_rate,:,:);
    end
    if ~isempty(ArchT_cortex_spikes)
        ArchT_cortex_spikes                 = ArchT_cortex_spikes(q_all_rate,:,:);
    end
    if ~isempty(ChR2_ArchT_cortex_spikes)
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
        unit_id_str         = num2str(unit_nrs(j),'%02.f');
        unique_unit_ids{j}  = [session_id '_' unit_id_str];
    end
    
    % pre-making this this will be useful for missing data
    nan_array           = NaN(n_units,1);
    
    %% ChR2-only data
    
    if ~isempty(ChR2_cortex_spikes)
        ChR2_baseline_rates     = spike_rate_by_channel(ChR2_cortex_spikes,baseline_win);
        ChR2_target_rates       = spike_rate_by_channel(ChR2_cortex_spikes,target_win);
        ChR2_trial_rates        = spike_rate_by_channel(ChR2_cortex_spikes,full_trial_win);
        [ChR2_delta_rates, ChR2_p_vals, ChR2_h_up_down] = compare_firing_rates(ChR2_cortex_spikes, baseline_win, target_win);
        
    else
        ChR2_baseline_rates     = nan_array;
        ChR2_target_rates     	= nan_array;
        ChR2_trial_rates        = nan_array;
        ChR2_delta_rates        = nan_array;
        ChR2_p_vals             = nan_array;
        ChR2_h_up_down          = nan_array;
    end
    
    %% ChR2-only data
    
    if ~isempty(ArchT_cortex_spikes)
        ArchT_baseline_rates     = spike_rate_by_channel(ArchT_cortex_spikes,baseline_win);
        ArchT_target_rates       = spike_rate_by_channel(ArchT_cortex_spikes,target_win);
        ArchT_trial_rates        = spike_rate_by_channel(ArchT_cortex_spikes,full_trial_win);
        [ArchT_delta_rates, ArchT_p_vals, ArchT_h_up_down] = compare_firing_rates(ArchT_cortex_spikes, baseline_win, target_win);
        
    else
        ArchT_baseline_rates     = nan_array;
        ArchT_target_rates          = nan_array;
        ArchT_trial_rates        = nan_array;
        ArchT_delta_rates        = nan_array;
        ArchT_p_vals             = nan_array;
        ArchT_h_up_down          = nan_array;
    end
    
    %% ChR2_ArchT-only data
    
    if ~isempty(ChR2_ArchT_cortex_spikes)
        ChR2_ArchT_baseline_rates     = spike_rate_by_channel(ChR2_ArchT_cortex_spikes,baseline_win);
        ChR2_ArchT_target_rates       = spike_rate_by_channel(ChR2_ArchT_cortex_spikes,target_win);
        ChR2_ArchT_trial_rates        = spike_rate_by_channel(ChR2_ArchT_cortex_spikes,full_trial_win);
        [ChR2_ArchT_delta_rates, ChR2_ArchT_p_vals, ChR2_ArchT_h_up_down] = compare_firing_rates(ChR2_ArchT_cortex_spikes, baseline_win, target_win);
        
    else
        ChR2_ArchT_baseline_rates     = nan_array;
        ChR2_ArchT_target_rates     	= nan_array;
        ChR2_ArchT_trial_rates        = nan_array;
        ChR2_ArchT_delta_rates        = nan_array;
        ChR2_ArchT_p_vals             = nan_array;
        ChR2_ArchT_h_up_down          = nan_array;
    end
    
    %% 
    ChR2_thalamus_delta_rate        = ChR2_thalamus_delta_rate * ones(n_units,1);
    ChR2_thalamus_p                 = ChR2_thalamus_p * ones(n_units,1);
    
    ArchT_thalamus_delta_rate       = ArchT_thalamus_delta_rate * ones(n_units,1);
   	ArchT_thalamus_p                = ArchT_thalamus_p * ones(n_units,1);
    
   	ChR2_ArchT_thalamus_delta_rate 	= ChR2_ArchT_thalamus_delta_rate * ones(n_units,1);
   	ChR2_ArchT_thalamus_p          	= ChR2_ArchT_thalamus_p * ones(n_units,1);
    

    %% Make a table of the results for this session
    this_results_table  = table(repmat({session_id}, size(unit_depths)), unique_unit_ids(:), unit_depths, ...
                                ChR2_thalamus_delta_rate, ChR2_thalamus_p, repmat(ChR2_n_thalamus_up,size(unit_depths)), repmat(ChR2_n_thalamus_down,size(unit_depths)), ChR2_baseline_rates, ChR2_target_rates, ChR2_trial_rates, ChR2_delta_rates, ChR2_p_vals, ChR2_h_up_down, ...
                                ArchT_thalamus_delta_rate, ArchT_thalamus_p, ArchT_baseline_rates, ArchT_target_rates, ArchT_trial_rates, ArchT_delta_rates, ArchT_p_vals, ArchT_h_up_down, ...
                              	ChR2_ArchT_thalamus_delta_rate, ChR2_ArchT_thalamus_p, ChR2_ArchT_baseline_rates, ChR2_ArchT_target_rates, ChR2_ArchT_trial_rates, ChR2_ArchT_delta_rates, ChR2_ArchT_p_vals, ChR2_ArchT_h_up_down, ...
                              	'VariableNames',{'session_id','unit_id', 'unit_depth', ...
                               	'ChR2_thal_delta', 'ChR2_thal_p','ChR2_thal_n_up','ChR2_thal_n_down','ChR2_baseline','ChR2_target','ChR2_trial','ChR2_delta','ChR2_p','ChR2_h_up_down', ...
                               	'ArchT_thal_delta', 'ArchT_thal_p','ArchT_baseline','ArchT_target','ArchT_trial','ArchT_delta','ArchT_p','ArchT_h_up_down', ...
                               	'ChR2_ArchT_thal_delta', 'ChR2_ArchT_thal_p','ChR2_ArchT_baseline','ChR2_ArchT_target','ChR2_ArchT_trial','ChR2_ArchT_delta','ChR2_ArchT_p','ChR2_ArchT_h_up_down'});
    
  	% Add the results for this session to the big unit_results_table:
	unit_results_table  = [unit_results_table; this_results_table];
end
% output is 'unit_results_table':
% a table with 1 entry (row) for each cortical unit
