function spike_times = detect_spikes(spike_trace, spike_thresh, timestamps)
% function spike_times = detect_spikes(spike_trace, spike_thresh, timestamps)
% 
% Detects spikes on (high-pass filtered!) electrophysiology trace SPIKE_TRACE, 
% defined as *negative* crossings of SPIKE_THRESH * (robust standard deviation
% estimate). Robust standard deviation estimate = median(abs(spike_trace))/0.6745,
% from Quian Quiroga et al. (2004).
% 
% Returns SPIKE_TIMES in units of TIMESTAMPS if TIMESTAMPS is provided;
% if no TIMESTAMPS are provided, detected spikes are returned as sample 
% number.
% 
% INPUT:
% 
% SPIKE_TRACE: an N_SAMPLES*1 electrophysiology trace, bandpass filtered for spike
% detection (recommended passband [500 5000]).
% 
% SPIKE_THRESH: Number of standard deviations to use as a threshold. Negative
% threshold crossings are considered spikes.
% 
% TIMESTAMPS: N_SAMPLES*1 vector of timestamps, with one timestamp corresponding
% to each sample in SPIKE_TRACE. If TIMESTAMPS are not provided, DETECT_SPIKES
% will return sample number in SPIKE_TIMES.
% 
% OUTPUT:
% 
% SPIKE_TIMES: Times of spikes, taken from TIMESTAMPS if provided, otherwise
% SPIKE_TIMES will be the indices of threshold-crossing samples in SPIKE_TRACE.
% 
% Joram van Rheede 2020
% 

% If no timestamps are provided, use sample number
if nargin < 3
    timestamps = 1:length(spike_trace);
end

% Robust standard deviation estimation adopted from Quian Quiroga et al. (2004):
sigma_n             = median(abs(spike_trace))/0.6745; 

% determine standard deviation to determine threshold, detect threshold crossings (negative)
q_threshold         = (-spike_trace) > (spike_thresh * sigma_n);

% Determine instances of threshold being crossed
spike_bool          = diff(q_threshold) == 1; 

% Get the timestamps of these instances
spike_times         = timestamps(spike_bool); 

