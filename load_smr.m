function [smr_contents] = load_smr(smr_file_name, do_CAR)
% function [smr_contents] = load_smr(smr_file_name, do_CAR)
% 
% Extracts electrophysiology data and associated event data from a spike2 
% '.smr' file.
% 
% INPUTS:
% 
% SMR_FILE_NAME: full file name of .smr data file
% 
% DO_CAR: Whether or not to do common average referencing (true/false)
% 
% OUTPUT:
% 
% SMR_CONTENTS: a data structure containing the following:
%
% smr_contents.cortex.data            	= the n_channels * n_samples cortical ephys recording
% smr_contents.cortex.time_stamps     	= timestamps, length == n_samples
% smr_contents.cortex.units            	= the units, e.g. mV
% smr_contents.cortex.scale            	= scale factor for the values in 'data' to obtain 'units'
% smr_contents.cortex.LFP              	= bandpass filtered and resampled 'data'
% smr_contents.cortex.LFP_time_stamps 	= time stamps associated with LFP
% 
% smr_contents.thalamus.data           	= the n_channels * n_samples thalamic ephys recording
% smr_contents.thalamus.time_stamps    	= timestamps, length == n_samples
% smr_contents.thalamus.units         	= the units, e.g. mV
% smr_contents.thalamus.scale          	= scale factor for the values in 'data' to obtain 'units'
% smr_contents.thalamus.LFP            	= bandpass filtered and resampled 'data'
% smr_contents.thalamus.LFP_time_stamps	= time stamps associated with LFP
% 
% smr_contents.piezo.data            	= data from piezo element
% smr_contents.piezo.time_stamps      	= time_stamps (piezo is resampled to match up with ephys)
% smr_contents.piezo.units            	= units from the piezo element
% smr_contents.piezo.scale            	= scale factor for the values in 'data' to obtain 'units'
% 
% smr_contents.laser478.event_times    	= event times for 478nm laser**
% smr_contents.laser561.event_times   	= event times for 561nm laser**
% ** NOTE: if there is no laser present in the recording there will most
% likely be 2 event times; these represent the start and end of recording
% 
% smr_contents.keypress.ids           	= Keys pressed on keyboard
% smr_contents.keypress.time_stamps   	= The times associated with the key presses
% 
%
% Joram van Rheede 2020
% 

% Keep track of time:
tic


% Hardcoded target channels
target_chans_A          = 17:48;  
target_chans_B          = 1:32;

% Hardcoded LFP parameters
LFP_filt_band           = [0.5 300]; % Passband for local field potential
LFP_downsample_factor   = 20; % Resample filtered signal for this frequency for LFP

% Hardcoded spike detection parameters
spike_filt_band         = [500 5000]; % Passband for spike detection
spike_thresh            = 5; % Threshold for spike detection in robust standard deviation estimates

% if do_CAR is not specified, default to true (= do Common Average Referencing)
if nargin < 2
    do_CAR = true;
end

%% Code execution starts here

% Use ImportSMR function from SON2 toolbox (Malcolm Lidierth, but obtained from https://github.com/tjrantal/Spike-smr-reader)
disp(['Loading ' smr_file_name ' using ImportSMR...'])
smr_file_data   = ImportSMR(smr_file_name);

% Initialise data for headstages A and B
chan_data_A     = int16([]);
chan_data_B     = int16([]);

% Some baseline recordings might not have these channels present, make these with NaNs
laser_478_chan  = NaN;
laser_561_chan  = NaN;
keyboard_chan   = NaN;

% Loop over all elements in smr_file_data structure to construct an
% n_channels * n_samples int16 data matrix for headstages A and B
disp([num2str(toc) 's: Extracting relevant channels from imported data...'])
for a = 1:length(smr_file_data)

    % Not all elements of struct contain data; continue to avoid errors due 
    % to empty fields
    if isempty(smr_file_data(a).hdr)
        continue
    end
    
    % Get the name for this data channel
    chan_name       = smr_file_data(a).hdr.title;
    
    % See if chan_name contains 'Rhd' - this means it is one of the headstage channels
    is_ephys_chan   = any(regexp(chan_name,'Rhd'));
    
    % if we are dealing with one of the ephys channels...
    if is_ephys_chan
        
        % Find out which headstage it is from
        headstage_ID    = chan_name(4);
        
    	% What channel number is it? (add 1 because Spike2 counts from 0)
        chan_nr_ind     = regexp(chan_name,'\d');
        chan_nr         = str2num(chan_name(chan_nr_ind:end))+1;
        
        % Most recent ephys channel # will be used as ephys_chan further down in script
        ephys_chan      = a; 
        
        switch headstage_ID
            % Pick relevant headstage data field and place data in correct channel number
            case 'A'
                chan_data_A(chan_nr,:)    = smr_file_data(a).imp.adc;
            case 'B'
                chan_data_B(chan_nr,:)    = smr_file_data(a).imp.adc;
        end
    else
        % This could be an event channel, see if it is and remember the number:
        switch chan_name
            case 'piezo'
                piezo_chan      = a;
            case 'stim1'
                laser_478_chan  = a;
            case 'laser di'
                laser_561_chan  = a;
            case 'Keyboard'
                keyboard_chan   = a;
        end
        
    end
    
end

% Select the target channels from the headstages, discard unnecessary channels
chan_data_A     = chan_data_A(target_chans_A,:);
chan_data_B     = chan_data_B(target_chans_B,:);

% If common average referencing is required:
if do_CAR
    disp([num2str(toc) 's: Applying common average reference...'])
    % Find common average for A
	ref_mean_A  = int16(mean(chan_data_A));
    % Subtract common average using implicit expansion
    chan_data_A = chan_data_A - ref_mean_A;
    
    % Find common average for B
    ref_mean_B  = int16(mean(chan_data_B));
    % Subtract common average using implicit expansion
    chan_data_B = chan_data_B - ref_mean_B;
end


%% 478 laser

if ~isnan(laser_478_chan) && ~isempty(smr_file_data(laser_478_chan).hdr) 
    % get timing info from the header
    laser_478_tinfo         = smr_file_data(laser_478_chan).hdr.tim;
    
    % Timestamps are clockticks and need to be multiplied by a scale and a factor
    % to obtain the value in seconds
    laser_478_scale         = laser_478_tinfo.Scale;
    laser_478_units         = laser_478_tinfo.Units;
    laser_478_factor        = laser_478_scale * laser_478_units;
    
    % Use the scale and factor to obtain time in seconds
    laser_478_event_times 	= double(smr_file_data(laser_478_chan).imp.tim) * double(laser_478_factor);
else
    laser_478_event_times 	= [];
end

%% 561 laser

if ~isnan(laser_561_chan) && ~isempty(smr_file_data(laser_561_chan).hdr)
    
    % get timing info from the header
    laser_561_tinfo         = smr_file_data(laser_561_chan).hdr.tim;
    
    % Timestamps are clockticks and need to be multiplied by a scale and a factor
    % to obtain the value in seconds
    laser_561_scale         = laser_561_tinfo.Scale;
    laser_561_units         = laser_561_tinfo.Units;
    laser_561_factor        = laser_561_scale * laser_561_units;
    
    % Use the scale and factor to obtain time in seconds
    laser_561_event_times 	= double(smr_file_data(laser_561_chan).imp.tim) * double(laser_561_factor);
else
    laser_561_event_times 	= [];
end


%% Ephys data time stamps

% Get timing information
ephys_tinfo             = smr_file_data(ephys_chan).hdr.tim;
ephys_time_scale      	= ephys_tinfo.Scale;
ephys_units             = ephys_tinfo.Units;
ephys_factor            = ephys_time_scale * ephys_units; 

% Multiply clock tick timestamps by the scaling factor to get event times in seconds
ephys_event_times       = double(smr_file_data(ephys_chan).imp.tim) * double(ephys_factor);

% Determine start and end time
rec_start               = ephys_event_times(1);
rec_end                 = ephys_event_times(2);

% Obtain the sampling interval and multiply by scaling factor
ephys_sample_interval 	= smr_file_data(ephys_chan).hdr.adc.SampleInterval;
ephys_sample_interval  	= ephys_sample_interval(1)*ephys_sample_interval(2);

% Use the start and end time of the recording and the sample interval
% to generate a time stamp for each data point
ephys_time_stamps       = rec_start:ephys_sample_interval:rec_end;

%% ephys data scale
ephys_units             = smr_file_data(ephys_chan).hdr.adc.Units;
ephys_scale             = smr_file_data(ephys_chan).hdr.adc.Scale;

%% Piezo data

piezo_data              = smr_file_data(piezo_chan).imp.adc;

piezo_tinfo             = smr_file_data(piezo_chan).hdr.tim;
piezo_scale             = piezo_tinfo.Scale;
piezo_units             = piezo_tinfo.Units;
piezo_factor            = piezo_scale * piezo_units; 

piezo_event_times      	= double(smr_file_data(piezo_chan).imp.tim) * double(piezo_factor);

piezo_start             = piezo_event_times(1);
piezo_end               = piezo_event_times(2);

piezo_sample_interval 	= smr_file_data(piezo_chan).hdr.adc.SampleInterval;
piezo_sample_interval 	= piezo_sample_interval(1)*piezo_sample_interval(2);

piezo_time_stamps       = piezo_start:piezo_sample_interval:piezo_end;

% Resample the piezo data so that it aligns completely with the ephys_data 
% (and can use the same time stamps)
piezo_data           	= int16(interp1(piezo_time_stamps, double(piezo_data), ephys_time_stamps));
piezo_time_stamps       = ephys_time_stamps;

piezo_units             = smr_file_data(piezo_chan).hdr.adc.Units;
piezo_scale             = smr_file_data(piezo_chan).hdr.adc.Scale;


%% Keyboard data

if ~isnan(keyboard_chan) && ~isempty(smr_file_data(keyboard_chan).hdr)
    
    keyboard_tinfo          = smr_file_data(keyboard_chan).hdr.tim;
    keyboard_scale          = keyboard_tinfo.Scale;
    keyboard_units          = keyboard_tinfo.Units;
    keyboard_factor         = keyboard_scale * keyboard_units;
    
    % Event times for keyboard presses
    keyboard_event_times 	= double(smr_file_data(keyboard_chan).imp.tim) * double(keyboard_factor);
    
    % Keys are registered as ASCII codes - convert to relevant characters:
    key_id              	= char(smr_file_data(keyboard_chan).imp.mrk(:,1)); %
else
    
    keyboard_event_times    = [];
    key_id                  = [];
    
end

% Generate sampling frequency from ephys_sample_interval obtained from .smr file
ephys_sample_freq   = 1/ephys_sample_interval;

%% Spikes: Filter signal and extract spike times

disp([num2str(toc) 's: Filtering signal and detecting spikes'])

spike_traces_A          = filter_ephys_signal(chan_data_A,spike_filt_band, ephys_sample_freq);
spike_traces_B          = filter_ephys_signal(chan_data_B,spike_filt_band, ephys_sample_freq);

% Detect spikes for all channels, headstage A
spikes_A = [];
for i = 1:size(spike_traces_A,1)
    channel_spike_times     = detect_spikes(spike_traces_A(i,:),spike_thresh,ephys_time_stamps);
    spikes_A(i,1:length(channel_spike_times))   = channel_spike_times;
end

% Detect spikes for all channels, headstage B
for i = 1:size(spike_traces_B,1)
    channel_spike_times     = detect_spikes(spike_traces_B(i,:),spike_thresh,ephys_time_stamps);
    spikes_B(i,1:length(channel_spike_times))   = channel_spike_times;
end

% Unequal numbers of spikes mean that spikes_A and spikes_B are padded with
% 0s, change these to NaNs instead so we don't count them as spike times
spikes_A(spikes_A == 0) = NaN;
spikes_B(spikes_B == 0) = NaN;


%% LFP: Filter and resample data for storing LFP traces

disp([num2str(toc) 's: Filtering and resampling LFP'])

% Bandpass filter ephys data to get LFP
LFP_data_A          = filter_ephys_signal(chan_data_A,LFP_filt_band, ephys_sample_freq);
LFP_data_B          = filter_ephys_signal(chan_data_B,LFP_filt_band, ephys_sample_freq);

% Downsample LFP data using simple indexing, and obtain relevant timestamps
LFP_data_A          = LFP_data_A(:,1:LFP_downsample_factor:end);
LFP_data_B          = LFP_data_B(:,1:LFP_downsample_factor:end);

LFP_time_stamps   	= ephys_time_stamps(1:LFP_downsample_factor:end); 

%% Adjust all time stamps to be relative to time stamp 0 on the ephys traces 
% this will be come useful when working with multiple concatenated ephys data
% files as it will then be possible to infer time in seconds simply from sample 
% number
min_ephys_time          = min(ephys_time_stamps);

ephys_time_stamps       = ephys_time_stamps - min_ephys_time;
LFP_time_stamps         = LFP_time_stamps - min_ephys_time;
piezo_time_stamps       = piezo_time_stamps - min_ephys_time;
laser_478_event_times   = laser_478_event_times - min_ephys_time;
laser_561_event_times   = laser_561_event_times - min_ephys_time;
keyboard_event_times    = keyboard_event_times - min_ephys_time;

rec_length              = max(ephys_time_stamps);

%% Generate output data structure

disp([num2str(toc) 's: Returning data'])

% add some generic file info
smr_contents.fileinfo.filename          = smr_file_data(ephys_chan).hdr.source.name;
smr_contents.fileinfo.date              = smr_file_data(ephys_chan).hdr.source.date;
smr_contents.fileinfo.datenum           = smr_file_data(ephys_chan).hdr.source.datenum;

% Make cortex data structure
smr_contents.cortex.data              	= chan_data_A;
smr_contents.cortex.time_stamps      	= ephys_time_stamps;
smr_contents.cortex.units             	= ephys_units;
smr_contents.cortex.scale            	= ephys_scale;
smr_contents.cortex.spikes              = spikes_A;
smr_contents.cortex.LFP                	= LFP_data_A;
smr_contents.cortex.LFP_time_stamps   	= LFP_time_stamps;
smr_contents.cortex.rec_length          = rec_length;
smr_contents.cortex.sample_interval     = ephys_sample_interval;

% Make thalamus data structure
smr_contents.thalamus.data            	= chan_data_B;
smr_contents.thalamus.time_stamps     	= ephys_time_stamps;
smr_contents.thalamus.units            	= ephys_units;
smr_contents.thalamus.scale           	= ephys_scale;
smr_contents.thalamus.spikes            = spikes_B;
smr_contents.thalamus.LFP           	= LFP_data_B;
smr_contents.thalamus.LFP_time_stamps   = LFP_time_stamps;
smr_contents.thalamus.rec_length      	= rec_length;
smr_contents.thalamus.sample_interval 	= ephys_sample_interval;

% Make piezo data structure
smr_contents.piezo.data               	= piezo_data;
smr_contents.piezo.time_stamps       	= piezo_time_stamps;
smr_contents.piezo.units              	= piezo_units;
smr_contents.piezo.scale              	= piezo_scale;

% Get event times from laser channels
smr_contents.laser478.event_times   	= laser_478_event_times;
smr_contents.laser561.event_times      	= laser_561_event_times;

% Get keypress ID and time stamps
smr_contents.keypress.ids              	= key_id;
smr_contents.keypress.time_stamps     	= keyboard_event_times;




