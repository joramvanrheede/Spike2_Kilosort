%% Example script for running the postprocess_kilosort function

% Filename to save the synched & sorted data
sorted_data_save_name       = 'Experiment_ID_Sorted.mat';

kilosort_folder             = '/Users/Joram/Data/Sharott/Kilosort_binary';

postprocess_kilosort(kilosort_folder, sorted_data_save_name)