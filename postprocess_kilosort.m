function postprocess_kilosort(kilosort_folder, sorted_data_save_name)
% function postprocess_kilosort(kilosort_folder, sorted_data_save_name)
% Run this function after you have run preprocess_smr_files and after you have 
% run Kilosort to link the sorted spikes to protocols and align them to trials.

% A bunch of hardcoded defaults:

% Add kilosort folder path to sorted_data_save_name
sorted_data_save_name       = [kilosort_folder filesep sorted_data_save_name];

% Kilosort folder for the cortical data, and binary data file name (.dat)
cortex_kilosort_folder      = [kilosort_folder filesep 'cortex'];
cortex_file_name            = 'cortex_binary.dat';

% Kilosort folder for the thalamic data, and binary data file name (.dat)
thalamus_kilosort_folder  	= [kilosort_folder filesep 'thalamus'];
thalamus_file_name         	= 'thalamus_binary.dat';

% File name of sync_data saved file from preprocess_smr_files
sync_file_name              = [kilosort_folder filesep 'experiment_sync_data.mat'];

% Using an integer approximate sample rate for Kilosort but need to offset 
% this by actual sample rate from smr file to get the timing right:
kilosort_sample_rate        = 20000; % 20000 - unlikely to change

% Bin size for binning the spike responses
bin_size                    = 0.01;

%% Code execution from here:

% Use sync_kilosort_units to sync cortical and thalamic sorted units
disp('Loading cortical units & waveforms...')
cortical_kilosort_data      = sync_kilosort_units(cortex_kilosort_folder, cortex_file_name, sync_file_name, kilosort_sample_rate);
disp('Loading thalamic units & waveforms...')
thalamic_kilosort_data      = sync_kilosort_units(thalamus_kilosort_folder, thalamus_file_name, sync_file_name, kilosort_sample_rate);

% Use one of the outputs as the basis for the merged output
sorted_data      	= cortical_kilosort_data;

% Remove specific fields as they need replacing with 'thalamus_' and 'cortex_' prefix
sorted_data       	= rmfield(sorted_data,{'spikes', 'unit_depths', 'unit_waveforms'});

% distribute cortical data to appropriately named fields in shared / merged data structure
[sorted_data(:).cortex_spikes]              = deal(cortical_kilosort_data.spikes);
[sorted_data(:).cortex_unit_depths]         = deal(cortical_kilosort_data.unit_depths);
[sorted_data(:).cortex_unit_xpos]           = deal(cortical_kilosort_data.unit_xpos);
[sorted_data(:).cortex_unit_waveforms]      = deal(cortical_kilosort_data.unit_waveforms);

% distribute thalamic data to appropriately named fields in shared / merged data structure
[sorted_data(:).thalamus_spikes]         	= deal(thalamic_kilosort_data.spikes);
[sorted_data(:).thalamus_unit_depths]    	= deal(thalamic_kilosort_data.unit_depths);
[sorted_data(:).thalamus_unit_xpos]         = deal(thalamic_kilosort_data.unit_xpos);
[sorted_data(:).thalamus_unit_waveforms] 	= deal(thalamic_kilosort_data.unit_waveforms);

for a = 1:length(sorted_data)
    sorted_data(a).cortex_binned_spikes     = bin_spikes(sorted_data(a).cortex_spikes,bin_size,sorted_data(a).trial_length);
    sorted_data(a).thalamus_binned_spikes 	= bin_spikes(sorted_data(a).thalamus_spikes,bin_size,sorted_data(a).trial_length);
end

% Save synched sorted data
disp('Saving synched & sorted data...')
save(sorted_data_save_name, 'sorted_data')
