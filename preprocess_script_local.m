%% Preprocess script
% This script shows how to use the 'preprocess_smr_files' function

%% Variables that need changing for each new experimental session:

% The folder containing the SMR data files to be concatenated and sorted
smr_data_folder     = '\\MARS\Sharott_Lab\users\naomi\recording data\NB116\D1';

% This will become the name of the folder that the preprocessed and sorted 
% data will end up in:
session_ID          = 'NB116_020719';

% A cell array of strings containing the filenames of the SMR files for the
% experimental session.
% IMPORTANT - these files need to be in the order they were recorded in, as 
% they will be concatenated in this order
smr_file_list       = { 'NB151 200127 baseline_start.smr' ...
                        'NB151 200127 20mW_ChR2_5s.smr' ...
                        'NB151 200127 30mW_ArchT_7s.smr' ...
                      	'NB151 200127 30mW_ArchT_7s 20mW_ChR2_5s.smr' ...
                        'NB151 200127 20mW_ChR2_25Hz.smr' ...
                        'NB151 200127 20mW_ChR2_60Hz.smr' ...
                        'NB151 200127 30mW_ArchT_7s 20mW_ChR2_25Hz.smr' ...
                        'NB151 200127 30mW_ArchT_7s 20mW_ChR2_60Hz.smr' ...
                        'NB151 200127 baseline_end.smr' ...
                        };

%% Defaults from here

% The kilosort target directory for this data set
processed_data_dir	= 'C:\Spike_sorting\processed_data\';

kilosort_dir        = [processed_data_dir filesep session_ID];


%% Code execution begins here

% Keep track of time
start_time          = clock;
disp(['Starting preprocessing of experimental session ' session_ID '...' ])

% This is the actual function that loads smr files, extracts trial info, etc.
preprocess_smr_files(smr_data_folder, smr_file_list, kilosort_dir)

% Report preprocessing time
preprocess_time     = etime(clock, start_time);
disp(['Finished preprocessing data from ' session_ID ' in ' num2str(preprocess_time/60) 'minutes.' ])

