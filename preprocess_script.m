%% Preprocess script
% This script provides an example of how to use the preprocess_smr_files function
% 

% 
smr_data_folder     = 'Z:\temp_share - contents deleted periodically\probe recording data for joram\NB151 200127';

% A cell with the filenames of the SMR files to be added.
% IMPORTANT - these files need to be in the order they were recorded in, as they will be concatenated in this order
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

% The kilosort directory for this data set
kilosort_dir        = 'C:\Spike_sorting\Naomi\preprocessed';

% This is the actual function that loads smr files, extracts trial info, etc.
preprocess_smr_files(smr_data_folder, smr_file_list, kilosort_dir)
