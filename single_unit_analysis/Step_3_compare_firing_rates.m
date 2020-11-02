% This script provides an example of how to go through multiple protocols
% and extract information that you can use to compare the results of your
% optogenetic manipulations across different experimental sessions.
% 
% The script will output a table with some overview information - you can
% change the code to add your own measures

%% Some user input options:

% Minimal overall firing rate in Hz for a cortical unit to be included
cortex_min_firing_rate      = 0.2; 

% Where does a cortical unit have to be (depth-wise) to be included?
cortex_min_depth            = 0;
cortex_max_depth            = 500;

% Minimal overall firing rate in HZ for a thalamic unit to be included
thalamus_min_firing_rate    = 0.5; 

% time window in seconds [start_time end_time] for taking baseline acrivity
% levels
baseline_window             = [0 5];

% time window in seconds [start_time end_time] where your manipulation is 
% happening (e.g. optogenetics is ON)
target_window               = [5 10]; 

%% No more user input variables from here - running code starts here

n_protocols                     = length(protocol_data_passed);

cortex_p_values                 = NaN(n_protocols,1);
thalamus_p_values               = NaN(n_protocols,1);

cortex_increase_percentage      = NaN(n_protocols,1);
thalamus_increase_percentage    = NaN(n_protocols,1);

cortex_mean_delta               = NaN(n_protocols,1);
thalamus_mean_delta             = NaN(n_protocols,1);

cortex_perc_up                  = NaN(n_protocols,1);
thalamus_perc_down              = NaN(n_protocols,1);
cortex_perc_up                  = NaN(n_protocols,1);
thalamus_perc_down              = NaN(n_protocols,1);
cortex_n_units                  = NaN(n_protocols,1);
thalamus_n_units                = NaN(n_protocols,1);

for i = 1:length(protocol_data_passed)
    this_protocol           = protocol_data_passed(i);
    
    cortex_spikes           = this_protocol.cortex_spikes;
    thalamus_spikes         = this_protocol.thalamus_spikes;
    
    %% See if individual units meet firing rate criteria:
    full_trial_rate_win  	= [0 this_protocol.trial_length];
    
    % What is the firing rate of each unit?
    cortex_unit_rates     	= spike_rate_by_channel(cortex_spikes, full_trial_rate_win);
    thalamus_unit_rates     = spike_rate_by_channel(thalamus_spikes, full_trial_rate_win);
    
    % Create a boolean to select only units meeting a minimum level of
    % activity
    cortex_unit_is_active   = cortex_unit_rates >= cortex_min_firing_rate; 
    thalamus_unit_is_active = thalamus_unit_rates >= thalamus_min_firing_rate;
    
    %% See if individual units meet depth criteria
    
	% Create separate variables that check whether a unit meets each depth criterion
    cortex_unit_is_min_depth    = protocol_data_passed(i).cortex_adjusted_unit_depth >= cortex_min_depth;
    cortex_unit_is_max_depth    = protocol_data_passed(i).cortex_adjusted_unit_depth <= cortex_max_depth;
    
    % Create a variable that checks whether each unit meets both the min
    % and the max criterion
    cortex_unit_is_depth_criterion = cortex_unit_is_min_depth & cortex_unit_is_max_depth;
    
    % Create a boolean variable that sees if a cortical unit is selected
    % based on both the activity and depth criteria
    cortex_unit_is_selected     = cortex_unit_is_active & cortex_unit_is_depth_criterion;
    
    %% Apply criteria
    
	% Keep track of how many units pass the activity criterion:
    cortex_n_units(i)    	= sum(cortex_unit_is_selected);
    thalamus_n_units(i)   	= sum(thalamus_unit_is_active);
    
    % only select the data from units that meet the activity and depth criteria
    cortex_spikes           = cortex_spikes(cortex_unit_is_selected,:,:);
    thalamus_spikes         = thalamus_spikes(thalamus_unit_is_active,:,:);
  
    
    %% Quality control is done - now quantify spike rates for the selected units:
    
    % Get spike rate in baseline window
    cortex_baseline_rates   = spike_rates_individual(cortex_spikes, baseline_window);
    thalamus_baseline_rates = spike_rates_individual(thalamus_spikes, baseline_window);
    
    % Get spike rates from target window FOR EACH TRIAL
    cortex_target_rates     = spike_rates_individual(cortex_spikes, target_window);
    thalamus_target_rates   = spike_rates_individual(thalamus_spikes, target_window);
    
    % Take the mean baseline rate across trials
    cortex_mean_baseline_rates      = mean(cortex_baseline_rates,2);  
    thalamus_mean_baseline_rates    = mean(thalamus_baseline_rates,2);
    
    % Take the mean rate in the target window across trials
    cortex_mean_target_rates        = mean(cortex_target_rates,2);
    thalamus_mean_target_rates      = mean(thalamus_target_rates,2);
    
    % Calculate difference (delta) between target window and baseline
    % window
    cortex_delta_rates      = cortex_mean_target_rates - cortex_mean_baseline_rates;
    thalamus_delta_rates    = thalamus_mean_target_rates - thalamus_mean_baseline_rates;
    
	% Do a paired t-test for each unit to determine whether there is a
    % significant difference between baseline and the target time window
    [~, cortex_rate_p]      = ttest(cortex_baseline_rates',cortex_target_rates');
    [~, thalamus_rate_p]    = ttest(thalamus_baseline_rates',thalamus_target_rates');
    
    % Determine the units where firing rate is significantly UP in target
    % window
    cortex_is_up            = (cortex_rate_p' < 0.05) & (cortex_delta_rates > 0);
    thalamus_is_up          = (thalamus_rate_p' < 0.05) & (thalamus_delta_rates > 0);
    
    % Calculate for what percentage of units firing rate is significantly UP
    % in target window
    cortex_perc_up(i)    	= sum(cortex_is_up) / length(cortex_is_up) * 100;
    thalamus_perc_up(i)  	= sum(thalamus_is_up) / length(thalamus_is_up) * 100;
    
    % Determine the units where firing rate is significantly DOWN in target
    % window
    cortex_is_down      	= (cortex_rate_p' < 0.05) & (cortex_delta_rates < 0);
    thalamus_is_down      	= (thalamus_rate_p' < 0.05) & (thalamus_delta_rates < 0);
    
    % Calculate for what percentage of units firing rate is significantly
    % DOWN in target window
    cortex_perc_down(i)   	= sum(cortex_is_down) / length(cortex_is_down) * 100;
    thalamus_perc_down(i) 	= sum(thalamus_is_down) / length(thalamus_is_down) * 100;
    
    % Calculate mean firing rate difference across units to get an idea of
    % whether overall activity was UP or DOWN
    cortex_mean_delta(i)   	= mean(cortex_delta_rates);
    thalamus_mean_delta(i)	= mean(thalamus_delta_rates);
    
end

% Create a table to visualise some key info for each protocol:
table({protocol_data_passed(:).protocol_ID}',cortex_n_units(:),cortex_perc_up(:),cortex_perc_down(:),cortex_mean_delta(:),thalamus_n_units(:),thalamus_perc_up(:),thalamus_perc_down(:),thalamus_mean_delta(:), 'VariableNames',{'Protocol ID' 'Cortex N units' 'Cortex % up' 'Cortex % down' 'Cortex mean delta FR' 'Thalamus N units' 'Thalamus % up' 'Thalamus % down' 'Thalamus mean delta FR'})


