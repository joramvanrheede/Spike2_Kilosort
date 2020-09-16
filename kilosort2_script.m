%% Script to control the running of Kilosort2 on cortical and thalamic data

% This is the only info that should need manual entry for each data set:
data_dir        = 'C:\Spike_sorting\processed_data\NB151 200127';

% The directory of the Spike2_Kilosort code repository
repo_dir        = 'C:\Spike_sorting\GitHub\Spike2_Kilosort';


%% These should not need to be edited

% Where should temporary files be stored (best on a fast SSD)
temp_loc                = 'C:\Spike_sorting\temp';

% Where are the Kilosort-compatible binary files?
cortex_data_dir         = [data_dir filesep 'cortex'];
thalamus_data_dir       = [data_dir filesep 'thalamus'];

% These refer to the sub-folders in the repository with the cortex- and
% thalamus-specific channelmaps and settings for Kilosort2
cortex_config_dir       = [repo_dir filesep 'cortex_config'];
thalamus_config_dir     = [repo_dir filesep 'thalamus_config'];

% Kilosort2 config files
cortex_config_file      = [cortex_config_dir filesep 'cortex_config_KS2.m'];
thalamus_config_file   	= [thalamus_config_dir filesep 'thalamus_config_KS2.m'];

cortex_chan_map_file    = [cortex_config_dir filesep 'CortexMap.mat'];
thalamus_chan_map_file	= [thalamus_config_dir filesep 'ThalamusMap.mat'];


%% Run kilosort on cortical and thalamic data
start_time      = clock;
disp('Starting Kilosort2 spike sorting of cortical data...')
run_kilosort2(cortex_data_dir, cortex_config_file, cortex_chan_map_file, temp_loc)
cortex_time 	= etime(clock, start_time);
disp(['Finished Kilosort2 spike sorting of cortical data in ' num2str(cortex_time) ' seconds'])

thalamus_start_time = clock;
disp('Starting Kilosort2 spike sorting of thalamic data...')
run_kilosort2(thalamus_data_dir, thalamus_config_file, thalamus_chan_map_file, temp_loc)
thalamus_time   = etime(clock, thalamus_start_time);
disp(['Finished Kilosort2 spike sorting of thalamic data in ' num2str(cortex_time) ' seconds'])

total_time      = etime(clock, start_time);
disp(['Total time for Kilosort2 spike sorting of cortical and thalamic data: ' num2str(total_time) ' seconds'])

