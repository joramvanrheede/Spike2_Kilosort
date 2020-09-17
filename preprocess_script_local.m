%% Preprocess script
% This script shows how to use the 'preprocess_smr_files' function

%% Variables that need changing for each new experimental session:

% The folder containing the SMR data files to be concatenated and sorted
smr_data_folder     = '\\MARS\Sharott_Lab\temp_share - contents deleted periodically\probe recording data for joram\NB151 200127';

% This will become the name of the folder that the preprocessed and sorted 
% data will end up in:
session_ID          = 'NB151 200127';

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

% This is the actual function that loads smr files, extracts trial info, etc.
preprocess_smr_files(smr_data_folder, smr_file_list, kilosort_dir)
