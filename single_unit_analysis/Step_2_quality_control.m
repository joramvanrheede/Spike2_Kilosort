% Quality control / screening script.
% Currently this script will only screen recordings for numbers of active
% units in cortex and thalamus. Other criteria may be useful for the final
% analysis depending on the protocol (e.g. a minimum increase in thalamic 
% firing rate for any protocol that includes attempted ChR2 activation of 
% thalamus, etc)
% 
% You may want to have different versions of this script depending on the
% protocol you are analysing

% User set variables:

% Minimum number of active cortical units AT THE RIGHT DEPTH for this recording to be included
cortex_min_units            = 2;

% Minimum number of active thalamic units for this recording to be included
thalamus_min_units          = 5;

% Where do the active units have to be?
cortex_min_depth            = 0;
cortex_max_depth            = 1000;

% Minimal overall firing rate for a cortical unit during this protocol
cortex_min_firing_rate      = 0.2;

% Minimal overall firing rate for a thalamic unit during this protocol
thalamus_min_firing_rate    = 0.5;


%% No further user input from here:
% When the variables above are set, this code will run the quality control and 
% create a new variable: protocol_data_passed

pass_quality_control        = false(1,length(protocol_data));
for i = 1:length(protocol_data)
    
    % Set a time window running from 0 to the length of the whole trial
    full_trial_rate_win  	= [0 protocol_data(i).trial_length];
    
    % Get average spike rate for the cortical and thalamic units
    cortical_firing_rates   = spike_rate_by_channel(protocol_data(i).cortex_spikes, full_trial_rate_win);
    thalamic_firing_rates   = spike_rate_by_channel(protocol_data(i).thalamus_spikes, full_trial_rate_win);
    
    % Determine which units are 'active', i.e. have a firing rate above the
    % minimum
    cortex_unit_is_active  	= cortical_firing_rates >= cortex_min_firing_rate;
    thalamus_unit_is_active = thalamic_firing_rates >= thalamus_min_firing_rate;
    
    % Create separate variables that check whether a unit meets each depth criterion
    cortex_unit_is_min_depth    = protocol_data(i).cortex_adjusted_unit_depth >= cortex_min_depth;
    cortex_unit_is_max_depth    = protocol_data(i).cortex_adjusted_unit_depth <= cortex_max_depth;
    
    % Create a variable that checks whether each unit meets both the min
    % and the max criterion
    cortex_unit_is_depth_criterion = cortex_unit_is_min_depth & cortex_unit_is_max_depth;
    
    % Determine numbers of active units
    n_cortical_active_units = sum(cortex_unit_is_active & cortex_unit_is_depth_criterion);
    n_thalamic_active_units = sum(thalamus_unit_is_active);
    
    % Set pass_quality_control variable depending on whether criteria are
    % met
    if n_cortical_active_units >= cortex_min_units && n_thalamic_active_units >= thalamus_min_units
        pass_quality_control(i)     = true;
    else
        pass_quality_control(i)     = false;
    end
end

% This new variable only contains protocols that passed the quality
% criteria:
protocol_data_passed    = protocol_data(pass_quality_control);
