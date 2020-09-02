function event_times = get_smr_event_times(smr_data_chan)
% function event_times = get_smr_event_times(smr_data_chan) 
% 
% Get event times from an smr file data channel.
% 
% Inputs: a single smr file data channel as obtained through ImportSMR
% 
% Output: Event times in seconds
% 

% get timing info from the header
tinfo         = smr_data_chan.hdr.tim;

% Timestamps are clockticks and need to be multiplied by a scale and a factor
% to obtain the value in seconds
scale         = tinfo.scale;
units         = tinfo.units;
factor        = scale * units; 

% Use the scale and factor to obtain time in seconds
event_times = double(smr_file_data(laser_478_chan).imp.tim) * double(laser_478_factor);

