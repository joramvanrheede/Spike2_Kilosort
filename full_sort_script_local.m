%% Preprocess script
% This script shows how to use the 'preprocess_smr_files' function

%% Variables that need changing for each new experimental session:

% The folder containing the SMR data files to be concatenated and sorted
smr_data_folder     = '\\MARS\Sharott_Lab\users\naomi\recording data\NB116\D2';

% This will become the name of the folder that the preprocessed and sorted 
% data will end up in:
session_ID          = 'NB116_030709_C900_T3700';

% A cell array of strings containing the filenames of the SMR files for the
% experimental session.
% IMPORTANT - these files need to be in the order they were recorded in, as 
% they will be concatenated in this order
smr_file_list       = { 'NB116_D2_ctx900_thal3700_baseline.smr'...
                        'NB116_D2_ctx900_thal3700_20mW_5schr2.smr'...
                        'NB116_D2_ctx900_thal3700_30mW_7sarcht.smr'...
                        'NB116_D2_ctx900_thal3700_20mW_5schr2_30mW_7sarcht.smr'...
                      	'NB116_D2_ctx900_thal3700_20mW_10Hzchr2.smr'...
                        'NB116_D2_ctx900_thal3700_20mW_25Hzchr2.smr'...
                        'NB116_D2_ctx900_thal3700_20mW_60Hzchr2.smr'...
                        };

%% Defaults from here

% The kilosort target directory for this data set
processed_data_dir	= 'C:\Spike_sorting\processed_data\';

kilosort_dir        = [processed_data_dir filesep session_ID];

% The directory of the Spike2_Kilosort code repository
repo_dir                = 'C:\Spike_sorting\GitHub\Spike2_Kilosort';

% Where should temporary files be stored (best on a fast SSD)
temp_loc                = 'C:\Spike_sorting\temp';

% Where are the Kilosort-compatible binary files?
cortex_data_dir         = [kilosort_dir filesep 'cortex'];
thalamus_data_dir       = [kilosort_dir filesep 'thalamus'];

% These refer to the sub-folders in the repository with the cortex- and
% thalamus-specific channelmaps and settings for Kilosort2
cortex_config_dir       = [repo_dir filesep 'cortex_config'];
thalamus_config_dir     = [repo_dir filesep 'thalamus_config'];

% Kilosort2 config files
cortex_config_file      = [cortex_config_dir filesep 'cortex_config_KS2.m'];
thalamus_config_file   	= [thalamus_config_dir filesep 'thalamus_config_KS2.m'];

cortex_chan_map_file    = [cortex_config_dir filesep 'CortexMap.mat'];
thalamus_chan_map_file	= [thalamus_config_dir filesep 'ThalamusMap.mat'];


%% Preprocessing .smr files

% Keep track of time
start_time          = clock;
disp(['Starting preprocessing of experimental session ' session_ID '...' ])

% This is the actual function that loads smr files, extracts trial info, etc.
preprocess_smr_files(smr_data_folder, smr_file_list, kilosort_dir)

% Report preprocessing time
preprocess_time     = etime(clock, start_time);
disp(['Finished preprocessing data from ' session_ID ' in ' num2str(preprocess_time/60) 'minutes.' ])

%% Kilosort runs

% Time the kilosort2 runs and provide some verbose reporting
start_time      = clock;
disp('Starting Kilosort2 spike sorting of cortical data...')

% run kilosort2 on cortical data
run_kilosort2(cortex_data_dir, cortex_config_file, cortex_chan_map_file, temp_loc)

% Report elapsed time after sorting of cortical data
cortex_time 	= etime(clock, start_time);
disp(['Finished Kilosort2 spike sorting of cortical data in ' num2str(cortex_time) ' seconds'])

% Time the thalamic kilosort2 run...
thalamus_start_time = clock;
disp('Starting Kilosort2 spike sorting of thalamic data...')

% run kilosort2 on thalamic data
run_kilosort2(thalamus_data_dir, thalamus_config_file, thalamus_chan_map_file, temp_loc)

% Report elapsed time after sorting thalamic data
thalamus_time   = etime(clock, thalamus_start_time);
disp(['Finished Kilosort2 spike sorting of thalamic data in ' num2str(cortex_time) ' seconds'])

% Report total elapsed time
total_time      = etime(clock, start_time);
disp(['Total time for Kilosort2 spike sorting of cortical and thalamic data: ' num2str(total_time/60) ' minutes'])


