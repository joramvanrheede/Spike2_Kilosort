function filtered_signal = filter_ephys_signal(ephys_data,filt_band, sample_freq)
% function filtered_signal = filter_for_LFP(ephys_data,LFP_filt_band, ephys_sample_freq)
% 
% Filter N_channels * n_samples EPHYS_DATA acquired at EPHYS_SAMPLE_FREQ to 
% pass only frequencies within FILT_BAND. This function uses the matlab 
% 'filtfilt' function for zero phase lag.
% 
% Use e.g. filt_band = [0.5 300] for LFP and filt_band = [500 5000] for 
% spikes.
% 
% INPUTS:

% EPHYS_DATA: N_channels * n_samples electrophysiology data
% 
% FILT_BAND: Filter passband in Hz as [low high], e.g. [0.5 300]
% 
% SAMPLE_FREQ: Sampling frequency of the input data
% 
% OUTPUT:
% 
% filtered_signal: N_channels * n_samples bandpass filtered electrophysiology data
% as data type 'int16'
% 
% 
% Joram van Rheede
% August 2020

% Generate butterworth filter parameters
[filt_b, filt_a] 	= butter(2, filt_band/(sample_freq/2));

% Filter the traces
filtered_signal      = zeros(size(ephys_data),'int16');
for i = 1:size(ephys_data)
    % Use 'filtfilt' function for zero-phase filtering.
    % Convert to double for filtering, convert back to int16 for memory efficiency
    filtered_signal(i,:)     = int16(filtfilt(filt_b,filt_a,double(ephys_data(i,:))));
end
