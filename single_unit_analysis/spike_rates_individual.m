function spike_rates = spike_rates_individual(spikes, time_win)
% function spike_rates = spike_rates_individual(SPIKES, TIME_WIN)
% 
% Returns SPIKE_RATES in Hz in a given TIME_WIN. Individual spike rates are
% given for each channel / unit and for each trial.
% 
% INPUTS:
% 
% SPIKES: a N_CHANNELS (or N_UNITS) * N_TRIALS * N_SPIKES matrix of spike times, 
% padded with NaNs for empty values.
% 
% TIME_WIN: a time window, [T1 T2]. Function counts spikes from 
% TSPIKE >= T1 to TSPIKE <= T2.
% 
% OUTPUTS:
% 
% SPIKE_RATES:
% An N_CHANNELS (or N_UNITS) * N_TRIALS matrix of spike rates.
% 
% Joram van Rheede 2020
% 

% Count spike times within time window
spikes_in_win                       = spikes >= time_win(1) & spikes <= time_win(2);
spike_counts_by_trial_by_channel    = sum(spikes_in_win,3);

% How long is time window?
delta_t                             = time_win(2) - time_win(1);

% Convert to rate by dividing by delta_t
spike_rates                         = spike_counts_by_trial_by_channel / delta_t;