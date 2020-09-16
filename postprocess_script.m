%% Example script for running the postprocess_kilosort function

session_ID        	= 'NB151 200127'; % This should be the experiment folder name

data_folder         = 'C:\Spike_sorting\preprocessed_data';

%% 
kilosort_folder     = [data_folder filesep session_ID];

% Filename to save the synched & sorted data
sorted_data_save_name       = [session_ID '_sorted.mat'];

postprocess_kilosort(kilosort_folder, sorted_data_save_name)
