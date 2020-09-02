function LFP_data = filter_for_LFP(ephys_data,LFP_filt_band, ephys_sample_freq)
% function LFP_data = filter_for_LFP(ephys_data,LFP_filt_band, ephys_sample_freq)
% 
% Filter N_channels * n_samples EPHYS_DATA acquired at EPHYS_SAMPLE_FREQ to 
% pass only frequencies within LFP_FILT_BAND. This function uses the matlab 
% 'filtfilt' function for zero phase lag. 
% 
% INPUTS:

% EPHYS_DATA: N_channels * n_samples electrophysiology data
% 
% LFP_FILT_BAND: LFP filter passband in Hz as [low high], e.g. [0.5 300]
% 
% EPHYS_SAMPLE_FREQ: Sampling frequency of the input data
% 
% OUTPUT:
% 
% LFP_DATA: N_channels * n_samples bandpass filtered electrophysiology data
% as data type 'int16'
% 
% 
% Joram van Rheede
% August 2020

% Generate butterworth filter parameters
[LFP_filt_b, LFP_filt_a] 	= butter(2, LFP_filt_band/(ephys_sample_freq/2));

% Filter the traces
LFP_data      = zeros(size(ephys_data),'int16');
for i = 1:size(ephys_data)
    % Use 'filtfilt' function for zero-phase filtering.
    % Convert to double for filtering, convert back to int16 for memory efficiency
    LFP_data(i,:)     = int16(filtfilt(LFP_filt_b,LFP_filt_a,double(ephys_data(i,:))));
end