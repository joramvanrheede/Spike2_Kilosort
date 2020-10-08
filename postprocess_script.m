%% Example script for running the postprocess_kilosort function.
%% /!\ IMPORTANT /!\ Only run this script AFTER curating the sorted data using Phy

% This should be the experiment folder name (within data_folder below)
% containing
session_ID        	= 'NB151 200127'; 

%% Defaults from here
save_folder         = 'C:\Spike_sorting\synched_data';
data_folder         = 'C:\Spike_sorting\curated_data';

%% No further input required from here

kilosort_folder     = [data_folder filesep session_ID];

% Filename to save the synched & sorted data
sorted_data_save_name       = [session_ID];

% The actual function for postprocessing kilosort data, distributing the
% unit spike times across the protocols and trials contained in
% experiment_sync_data.mat (generated during the preprocessing stage)
postprocess_kilosort(kilosort_folder, save_folder, sorted_data_save_name)
