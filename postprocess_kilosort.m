% POSTPROCESS_KILOSORT:
% Run this script after you have run preprocess_smr_files and after you have 
% run Kilosort to link the sorted spikes to protocols and align them to trials.

%% User set variables:

% Filename to save the synched & sorted data
sorted_data_save_name       = '/Users/Joram/Data/Sharott/Synched/synched_sorted_data.mat';

% Kilosort folder for the cortical data, and binary data file name (.dat)
cortex_kilosort_folder      = '/Users/Joram/Data/Sharott/Kilosort_binary/Cortex';
cortex_file_name            = 'cortex_binary.dat';

% Kilosort folder for the thalamic data, and binary data file name (.dat)
thalamus_kilosort_folder  	= '/Users/Joram/Data/Sharott/Kilosort_binary/Thalamus';
thalamus_file_name         	= 'thalamus_binary.dat';

% File name of sync_data saved file from preprocess_smr_files
sync_file_name              = '/Users/Joram/Data/Sharott/Kilosort_binary/experiment_sync_data.mat';

% Using an integer approximate sample rate for Kilosort but need to offset 
% this by actual sample rate from smr file to get the timing right:
kilosort_sample_rate        = 20000; % 20000 - unlikely to change

%% Code execution from here:

% Use sync_kilosort_units to sync cortical and thalamic sorted units
disp('Loading cortical units & waveforms...')
cortical_kilosort_data      = sync_kilosort_units(cortex_kilosort_folder, cortex_file_name, sync_file_name, kilosort_sample_rate);
disp('Loading thalamic units & waveforms...')
thalamic_kilosort_data      = sync_kilosort_units(thalamus_kilosort_folder, thalamus_file_name, sync_file_name, kilosort_sample_rate);

% Use one of the outputs as the basis for the merged output
synched_sorted_data      	= cortical_kilosort_data;

% Remove specific fields as they need replacing with 'thalamus_' and 'cortex_' prefix
synched_sorted_data       	= rmfield(synched_sorted_data,{'spikes', 'unit_depths', 'unit_waveforms'});

% distribute cortical data to appropriately named fields in shared / merged data structure
[synched_sorted_data(:).cortex_spikes]              = deal(cortical_kilosort_data.spikes);
[synched_sorted_data(:).cortex_unit_depths]         = deal(cortical_kilosort_data.unit_depths);
[synched_sorted_data(:).cortex_unit_xpos]           = deal(cortical_kilosort_data.unit_xpos);
[synched_sorted_data(:).cortex_unit_waveforms]      = deal(cortical_kilosort_data.unit_waveforms);

% distribute thalamic data to appropriately named fields in shared / merged data structure
[synched_sorted_data(:).thalamus_spikes]         	= deal(thalamic_kilosort_data.spikes);
[synched_sorted_data(:).thalamus_unit_depths]    	= deal(thalamic_kilosort_data.unit_depths);
[synched_sorted_data(:).thalamus_unit_xpos]         = deal(thalamic_kilosort_data.unit_xpos);
[synched_sorted_data(:).thalamus_unit_waveforms] 	= deal(thalamic_kilosort_data.unit_waveforms);

for a = 1:length(synched_sorted_data)
    synched_sorted_data(a).cortex_binned_spikes     = bin_spikes(synched_sorted_data(a).cortex_spikes,bin_size,synched_sorted_data(a).trial_length);
    synched_sorted_data(a).thalamus_binned_spikes 	= bin_spikes(synched_sorted_data(a).thalamus_spikes,bin_size,synched_sorted_data(a).trial_length);
end

% Save synched sorted data
disp('Saving synched & sorted data...')
save(sorted_data_save_name, 'synched_sorted_data')
