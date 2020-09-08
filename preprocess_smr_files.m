% preprpcess_smr_files

%%

% A cell with the filenames of the SMR files to be added.
% IMPORTANT - these files need to be in the order they were recorded in, as they will be concatenated in this order
smr_file_list       = { '/Users/Joram/Data/Sharott/probe recording data for joram/NB151 200127/NB151 200127 baseline_start.smr' ...
                        '/Users/Joram/Data/Sharott/probe recording data for joram/NB151 200127/NB151 200127 20mW_ChR2_5s.smr' ...
                        '/Users/Joram/Data/Sharott/probe recording data for joram/NB151 200127/NB151 200127 30mW_ArchT_7s.smr' ...
                      	'/Users/Joram/Data/Sharott/probe recording data for joram/NB151 200127/NB151 200127 30mW_ArchT_7s 20mW_ChR2_5s.smr' ...
                        '/Users/Joram/Data/Sharott/probe recording data for joram/NB151 200127/NB151 200127 20mW_ChR2_25Hz.smr' ...
                        '/Users/Joram/Data/Sharott/probe recording data for joram/NB151 200127/NB151 200127 20mW_ChR2_60Hz.smr' ...
                        '/Users/Joram/Data/Sharott/probe recording data for joram/NB151 200127/NB151 200127 30mW_ArchT_7s 20mW_ChR2_25Hz.smr' ...
                        '/Users/Joram/Data/Sharott/probe recording data for joram/NB151 200127/NB151 200127 30mW_ArchT_7s 20mW_ChR2_60Hz.smr' ...
                        '/Users/Joram/Data/Sharott/probe recording data for joram/NB151 200127/NB151 200127 baseline_end.smr' ...
                        };

do_CAR              = true;

q_reload            = false;

% file names for Kilosort-compatible binary files
cortex_file_name    = '/Users/Joram/Data/Sharott/Kilosort_binary/cortex_binary.dat';
thalamus_file_name  = '/Users/Joram/Data/Sharott/Kilosort_binary/thalamus_binary.dat';

% file names for intermediate smr data file and experiment sync data
smr_data_save_name  = [cd filesep 'saved_smr_data'];
sync_data_file_name = '/Users/Joram/Data/Sharott/Kilosort_binary/experiment_sync_data.mat';

%% Channelmaps from Naomi's notes:
cortex_channel_map      = [ 41, 34, 44, 42, 40, 43, 45, 35; ...
                            37, 47, 36, 38, 33, 46, 32, 39; ...
                            16, 26, 18, 27, 17, 30, 29, 31; ...
                            21, 22, 24, 20, 23, 28, 25, 19] + 1 - 16; % Add 1 because of 0-indexing; channels offset by 16 channels on the 64chan headstage 

thalamus_channel_map    = [ 27, 17, 22, 21, 20, 26, 25, 30; ...
                            29, 24, 18, 19, 31, 23, 16, 28; ...
                            8,  13,  9,  2,  7, 15,  1,  0; ...
                            5,  11, 12, 10,  4, 14,  3,  6] + 1; % Add 1 because of 0-indexing

channel_x_pos           = [ 0, 0, 0, 0, 0, 0, 0, 0; ...
                            200, 200, 200, 200, 200, 200, 200, 200; ...
                            400, 400, 400, 400, 400, 400, 400, 400; ...
                            600, 600, 600, 600, 600, 600, 600, 600];
                        
channel_y_pos           = [ 0, 100, 200, 300, 400, 500, 600, 700; ...
                            0, 100, 200, 300, 400, 500, 600, 700; ...
                            0, 100, 200, 300, 400, 500, 600, 700; ...
                            0, 100, 200, 300, 400, 500, 600, 700];
                 
channel_shank_nr     	= [ 1, 1, 1, 1, 1, 1, 1, 1; ...
                            2, 2, 2, 2, 2, 2, 2, 2; ...
                            3, 3, 3, 3, 3, 3, 3, 3; ...
                            4, 4, 4, 4, 4, 4, 4, 4];


cortex_channel_map      = cortex_channel_map';
thalamus_channel_map    = thalamus_channel_map';
channel_x_pos           = channel_x_pos';
channel_y_pos           = channel_y_pos';
channel_shank_nr      	= channel_shank_nr';

%% Start the loading process if required, or use data already in memory / already stored on disk

if q_reload
    %% Loop for loading multiple smr files
    
    % append_mode 'write' means a file will be created, will be set to 'append' after the first iteration of the loop
    append_mode         = 'write';
    previous_rec_time   = 0;
    for i = 1:length(smr_file_list)
        
        % Load .smr file data
        smr_output  = load_smr(smr_file_list{i},do_CAR);
        
        % Write cortical file binary for Kilosort
        success = write_binary(cortex_file_name, smr_output.cortex.data, append_mode);

        % Write thalamic file binary for Kilosort
        success = write_binary(thalamus_file_name, smr_output.thalamus.data, append_mode);
        
        % Overwrite the raw data once we have written it and replace with the filename of the binary
        smr_output.cortex.data      = [cortex_file_name '_' num2str(i)];
        smr_output.thalamus.data    = [thalamus_file_name '_' num2str(i)];
        
        % Add the recording times together to keep track of time after concatenating       
        rec_start                   = previous_rec_time;
        rec_end                     = previous_rec_time + max(smr_output(1).cortex.time_stamps);
        
        smr_output.concat_rec_start = rec_start;
        smr_output.concat_rec_end 	= rec_end;
        
        previous_rec_time           = rec_end;
        
        % Set this for the following iterations of the loop:
        append_mode = 'append';
        
        % Store all sync and metadata in larger 'smr' variable 
        smr(i)      = smr_output;
    end
    
    % Save the 'smr' variable so we don't need to spend time re-loading the smr files everytime
    save(smr_data_save_name,'smr')
else
    % No reload requested - so variable either has to exist in memory or as a file.
    
    % If variable is not in memory already, try to load it using smr_data_save_name 
    if ~exist('smr','var')
        try
            load(smr_data_save_name)
        catch
            error(['Saved SMR data file:' smr_data_save_name ' not found'])
        end
    end
end

%% Now use loaded smr data to divide protocols up into trials, and align LFP data to trials
clear sync_data
for i = 1:length(smr)
    
    disp(['Synching recording number ' num2str(i) '...'])
    
    % No keypress in baseline conditions
    if ~isempty(smr(i).keypress.ids)
        protocol_code   = smr(i).keypress.ids(1);
    else
        protocol_code   = 'baseline';
    end
    
    % Initialise variables that may or may not be filled depending on experimental protocol
    n_trials                = 1;
    trial_starts            = [];
    trial_ends              = [];
    
    laser478_onsets         = [];
    laser478_burst_onsets   = [];
    pulse478_length         = [];
    
    laser561_onsets         = [];
    laser561_burst_onsets   = [];
    pulse561_length         = [];
    switch protocol_code
        case 'baseline'
            % No events
            protocol_description    = 'baseline';
            trial_starts            = smr(i).cortex.time_stamps(1);
            trial_ends              = smr(i).cortex.time_stamps(end);
        case 'e' % 5 pulses 25Hz 50 repeats 2s 478
            protocol_description    = '5 pulses 25Hz 50 repeats 2s 478';
            
            burst_diff_threshold    = 1; % gaps of longer than this amount in seconds are considered separate bursts
            pre_burst_time          = 1; % how much time pre-burst to consider as part of trial
            post_burst_time         = 1.17; % how much time post-burst onset to consider as part of trial
            
            pulse478_length       	= 0.005; % how long is the laser pulse
            
            laser478_onsets       	= smr(i).laser478.event_times;
            
            laser478_onset_diffs	= diff(laser478_onsets);
            
            is_478_burst_start    	= laser478_onset_diffs > burst_diff_threshold;
            is_478_burst_start    	= [true; is_478_burst_start(:)];
            
            laser478_burst_onsets 	= laser478_onsets(is_478_burst_start);
            
            n_trials                = length(laser478_burst_onsets);
            trial_starts            = laser478_burst_onsets - pre_burst_time;
            trial_ends              = laser478_burst_onsets + post_burst_time;
            
        case 'f' % 5s continuous on -10s off - 20 rpts
            protocol_description    = '5s continuous on -10s off - 20 rpts';
            pre_burst_time          = 5; % how much time pre-burst to consider as part of trial
            post_burst_time         = 10; % how much time post-burst onset to consider as part of trial
            pulse478_length       	= 5; %
            
            laser478_onsets       	= smr(i).laser478.event_times;
            laser478_burst_onsets   = laser478_onsets;

            n_trials                = length(laser478_onsets);
            trial_starts            = laser478_onsets - pre_burst_time;
            trial_ends              = laser478_onsets + post_burst_time;
            
        case 'g' % 5 pulses 60Hz 50 rpts 2s
            protocol_description    = '5 pulses 60Hz 50 rpts 2s';
            burst_diff_threshold    = 1; % gaps of longer than this amount in seconds are considered separate bursts
            pre_burst_time          = 1; % how much time pre-burst to consider as part of trial
            post_burst_time         = 1.08; % how much time post-burst onset to consider as part of trial
            pulse478_length       	= 0.005; %
            
            laser478_onsets       	= smr(i).laser478.event_times;
            
            laser478_onset_diffs	= diff(laser478_onsets);
            
            is_478_burst_start    	= laser478_onset_diffs > burst_diff_threshold;
            is_478_burst_start    	= [true; is_478_burst_start(:)];
            
            laser478_burst_onsets 	= laser478_onsets(is_478_burst_start);
            
            n_trials                = length(laser478_burst_onsets);
            trial_starts            = laser478_burst_onsets - pre_burst_time;
            trial_ends              = laser478_burst_onsets + post_burst_time;
            
        case 'p' % 5s continuous ChR2 x20
            protocol_description    = '5s continuous ChR2 x20';
            pre_burst_time          = 5; % how much time pre-burst to consider as part of trial
            post_burst_time         = 10; % how much time post-burst onset to consider as part of trial
            pulse478_length       	= 5; %
            
            laser478_onsets       	= smr(i).laser478.event_times;
            laser478_burst_onsets   = laser478_onsets;
            
            n_trials                = length(laser478_onsets);
            trial_starts            = laser478_onsets - pre_burst_time;
            trial_ends              = laser478_onsets + post_burst_time;
            
        case 'q' % 7s continuous archt x20
            protocol_description    = '7s continuous archt x20';
            pre_burst_time          = 4; % how much time pre-burst to consider as part of trial
            post_burst_time         = 11; % how much time post-burst onset to consider as part of trial
            pulse561_length       	= 7; %
            
            laser561_onsets         = smr(i).laser561.event_times;
            laser561_burst_onsets   = laser561_onsets;

            n_trials                = length(laser561_onsets);
            trial_starts            = laser561_onsets - pre_burst_time;
            trial_ends              = laser561_onsets + post_burst_time;
            
        case 'r' % archt 7s, chr2 5s, x20, 15s cycle
            protocol_description    = 'archt 7s, chr2 5s, x20, 15s cycle';
            pre_burst_time          = 5; % how much time pre-burst to consider as part of trial
            post_burst_time         = 10; % how much time post-burst onset to consider as part of trial
            pulse478_length       	= 5; %
            pulse561_length         = 7;
            
            laser478_onsets       	= smr(i).laser478.event_times;
            laser478_burst_onsets   = laser478_onsets;
            
            laser561_onsets         = smr(i).laser561.event_times;
            laser561_burst_onsets   = laser561_onsets;
            
            n_trials                = length(laser478_onsets);
            trial_starts            = laser478_onsets - pre_burst_time;
            trial_ends              = laser478_onsets + post_burst_time;
            
        case 's' % 25Hz 5 pulses x30, 2.22s cycle
            protocol_description    = '25Hz 5 pulses x30, 2.22s cycle';
          	burst_diff_threshold    = 1; % gaps of longer than this amount in seconds are considered separate bursts
            pre_burst_time          = 1; % how much time pre-burst to consider as part of trial
            post_burst_time         = 1.22; % how much time post-burst onset to consider as part of trial
            pulse478_length       	= 0.005; % how long is the laser pulse
            
            laser478_onsets       	= smr(i).laser478.event_times;
            
            laser478_onset_diffs	= diff(laser478_onsets);
            
            is_478_burst_start    	= laser478_onset_diffs > burst_diff_threshold;
            is_478_burst_start    	= [true; is_478_burst_start(:)];
            
            laser478_burst_onsets 	= laser478_onsets(is_478_burst_start);
            
            n_trials                = length(laser478_burst_onsets);
            trial_starts            = laser478_burst_onsets - pre_burst_time;
            trial_ends              = laser478_burst_onsets + post_burst_time;
            
        case 't' % 60Hz ChR2 with 7s archt, cycle 15s
            protocol_description    = '60Hz ChR2 with 7s archt, cycle 15s';
         	burst_diff_threshold    = 3; % gaps of longer than this amount in seconds are considered separate bursts
            pre_burst_time          = 5; % how much time pre-burst to consider as part of trial
            post_burst_time         = 10; % how much time post-burst onset to consider as part of trial
            pulse478_length       	= 0.005; % how long is the laser pulse
            
            laser478_onsets       	= smr(i).laser478.event_times;
            
            laser478_onset_diffs	= diff(laser478_onsets);
            
            is_478_burst_start    	= laser478_onset_diffs > burst_diff_threshold;
            is_478_burst_start    	= [true; is_478_burst_start(:)];
            
            laser478_burst_onsets 	= laser478_onsets(is_478_burst_start);
            
            pulse561_length         = 7;
            laser561_onsets         = smr(i).laser561.event_times;
            
            n_trials                = length(laser478_burst_onsets);
            trial_starts            = laser478_burst_onsets - pre_burst_time;
            trial_ends              = laser478_burst_onsets + post_burst_time;
            
        case 'u' % 25Hz ChR2 with 7s archt, cycle 15s
            protocol_description    = '25Hz ChR2 with 7s archt, cycle 15s';
            burst_diff_threshold    = 3; % gaps of longer than this amount in seconds are considered separate bursts
            pre_burst_time          = 5; % how much time pre-burst to consider as part of trial
            post_burst_time         = 10; % how much time post-burst onset to consider as part of trial
            pulse478_length       	= 0.005; % how long is the laser pulse
            
            laser478_onsets       	= smr(i).laser478.event_times;
            
            laser478_onset_diffs	= diff(laser478_onsets);
            
            is_478_burst_start    	= laser478_onset_diffs > burst_diff_threshold;
            is_478_burst_start    	= [true; is_478_burst_start(:)];
            
            laser478_burst_onsets 	= laser478_onsets(is_478_burst_start);
            
            pulse561_length         = 7;
            laser561_onsets         = smr(i).laser561.event_times;
            
            n_trials                = length(laser478_burst_onsets);
            trial_starts            = laser478_burst_onsets - pre_burst_time;
            trial_ends              = laser478_burst_onsets + post_burst_time;
            
        case 'l' % 10s continuous archt x 20, 20s cycle
            protocol_description    = '10s continuous archt x 20, 20s cycle';
            pre_burst_time          = 5; % how much time pre-burst to consider as part of trial
            post_burst_time         = 15; % how much time post-burst onset to consider as part of trial
            pulse561_length       	= 10; %
            
            laser561_onsets       	= smr(i).laser561.event_times;
            laser561__burst_onsets 	= laser561_onsets;

            n_trials                = length(laser561_onsets);
            trial_starts            = laser561_onsets - pre_burst_time;
            trial_ends              = laser561_onsets + post_burst_time;
        case 'm' % 30s continuous archt x 5, 60s cycle length
            protocol_description    = '30s continuous archt x 5, 60s cycle';
            pre_burst_time          = 15; % how much time pre-burst to consider as part of trial
            post_burst_time         = 45; % how much time post-burst onset to consider as part of trial
            pulse561_length       	= 30; %
            
            laser561_onsets       	= smr(i).laser561.event_times;
            laser561__burst_onsets 	= laser561_onsets;
            
            n_trials                = length(laser561_onsets);
            trial_starts            = laser561_onsets - pre_burst_time;
            trial_ends              = laser561_onsets + post_burst_time;
        case 'n' % 5s continuous archt x 15, 15s cycle
            protocol_description    = '5s continuous archt x 15, 15s cycle';
            pre_burst_time          = 5; % how much time pre-burst to consider as part of trial
            post_burst_time         = 10; % how much time post-burst onset to consider as part of trial
            pulse561_length       	= 5; %
            
            laser561_onsets       	= smr(i).laser561.event_times;
            laser561__burst_onsets 	= laser561_onsets;
            
            n_trials                = length(laser561_onsets);
            trial_starts            = laser561_onsets - pre_burst_time;
            trial_ends              = laser561_onsets + post_burst_time;
        otherwise 
            
            error('Unrecognised protocol')
    end
    
    % Protocol name and title
    sync_data(i).protocol_code       	= protocol_code;
    sync_data(i).protocol_description   = protocol_description;
    
    sync_data(i).sample_rate            = 1/smr(i).cortex.sample_interval;
    sync_data(i).rec_start_time         = smr(i).concat_rec_start;
    sync_data(i).rec_end_time           = smr(i).concat_rec_end;
    
    sync_data(i).n_trials             	= n_trials;
    sync_data(i).trial_starts        	= trial_starts;
    sync_data(i).trial_ends          	= trial_ends;

    % Not sure if we need the individual laser onsets?
%     sync_data(i).laser478_onsets    	= laser478_onsets;
%     sync_data(i).laser478_burst_onsets  = laser478_burst_onsets;

    
%     sync_data(i).laser561_onsets    	= laser561_onsets;
%     sync_data(i).laser561_burst_onsets  = laser561_burst_onsets;
    
    % For each protocol, 
    if ~isempty(laser478_burst_onsets)
        sync_data(i).laser478_start        = median(laser478_burst_onsets - trial_starts);
    else
        sync_data(i).laser478_start        = [];
    end
    
    sync_data(i).laser478_length        = pulse478_length;
    
    if ~isempty(laser561_burst_onsets)
        sync_data(i).laser561_start        = median(laser561_burst_onsets - trial_starts);
    else
        sync_data(i).laser561_start        = [];
    end
    
    sync_data(i).laser561_length        = pulse561_length;
    
	% channel map details
    sync_data(i).cortex_map             = cortex_channel_map(:);
    sync_data(i).thalamus_map           = thalamus_channel_map(:);
    sync_data(i).channel_x_pos          = channel_x_pos(:);
    sync_data(i).channel_y_pos          = channel_y_pos(:);
    sync_data(i).channel_shank_nr       = channel_shank_nr(:);
    
    %% Distribute LFP traces and spikes across trials
    
    % apply channelmap here to re-order channels:
    cortex_all_spikes     	= smr(i).cortex.spikes(cortex_channel_map(:),:);
    thalamus_all_spikes   	= smr(i).thalamus.spikes(cortex_channel_map(:),:);
    
    cortex_LFP_trace        = smr(i).cortex.LFP(cortex_channel_map(:),:);
    thalamus_LFP_trace      = smr(i).cortex.LFP(thalamus_channel_map(:),:);
    LFP_time_stamps         = smr(i).cortex.LFP_time_stamps;
    
    cortex_LFP      = [];
    thalamus_LFP    = [];
    cortex_spikes   = [];
    thalamus_spikes = [];
    for j = 1:length(trial_starts)
        this_trial_start    = trial_starts(j);
        this_trial_end      = trial_ends(j);
        
        q_LFP               = (LFP_time_stamps >= this_trial_start) & (LFP_time_stamps <= this_trial_end);
        n_samps             = sum(q_LFP);
        

        % cortex_LFP and thalamus_LFP will be an n_channels * n_trials * n_samples matrix
        cortex_LFP(:,j,1:n_samps)   = cortex_LFP_trace(:,q_LFP);
        thalamus_LFP(:,j,1:n_samps) = thalamus_LFP_trace(:,q_LFP);
        
        % Distribute cortical spikes over trials
        for k = 1:length(cortex_channel_map(:))
            chan_trial_spikes       = cortex_all_spikes(k,:);
            q_trial_spikes          = (chan_trial_spikes >= this_trial_start) & (chan_trial_spikes <= this_trial_end);
            cortex_spikes(k,j,1:sum(q_trial_spikes))    = chan_trial_spikes(q_trial_spikes) - this_trial_start;
        end
        
        % Distribute thalamic spikes over trials
        for k = 1:length(thalamus_channel_map(:))
            chan_trial_spikes       = thalamus_all_spikes(k,:);
            q_trial_spikes          = (chan_trial_spikes >= this_trial_start) & (chan_trial_spikes <= this_trial_end);
            thalamus_spikes(k,j,1:sum(q_trial_spikes))  = chan_trial_spikes(q_trial_spikes) - this_trial_start;
        end
        
        cortex_spikes(cortex_spikes == 0)       = NaN;
        thalamus_spikes(thalamus_spikes == 0)   = NaN;
    end
    
    sync_data(i).cortex_spikes          = cortex_spikes;
    sync_data(i).thalamus_spikes        = thalamus_spikes;
    
	sync_data(i).cortex_LFP             = cortex_LFP;
    sync_data(i).thalamus_LFP           = thalamus_LFP;
    
end

% Save sync data file - to be populated with Kilosorted spikes using sync_kilosort_units
save(sync_data_file_name,'sync_data')


