


data_dir        = 'C:\Spike_sorting\preprocessed_data\NB151 200127';

%%
cortex_data_dir         = [data_dir filesep 'cortex'];
thalamus_data_dir       = [data_dir filesep 'thalamus'];

cortex_config_file      = 'C:\Spike_sorting\GitHub\Spike2_Kilosort\cortex_config\cortex_config_KS2.m';
thalamus_config_file   	= 'C:\Spike_sorting\GitHub\Spike2_Kilosort\thalamus_config\thalamus_config_KS2.m';

cortex_chan_map_file    = 'C:\Spike_sorting\GitHub\Spike2_Kilosort\cortex_config\CortexMap.mat';
thalamus_chan_map_file	= 'C:\Spike_sorting\GitHub\Spike2_Kilosort\thalamus_config\ThalamusMap.mat';

temp_loc                = 'C:\Spike_sorting\temp';

%% Run kilosort on cortical and thalamic data
start_time      = clock;
disp('Starting Kilosort2 spike sorting of cortical data...')
run_kilosort(cortex_data_dir, cortex_config_file, cortex_chan_map_file, temp_loc)
cortex_time 	= etime(clock, start_time);
disp(['Finished Kilosort2 spike sorting of cortical data in ' num2str(cortex_time) ' seconds'])

thalamus_start_time = clock;
disp('Starting Kilosort2 spike sorting of thalamic data...')
run_kilosort(thalamus_data_dir, thalamus_config_file, thalamus_chan_map_file, temp_loc)
thalamus_time   = etime(clock, thalamus_start_time);
disp(['Finished Kilosort2 spike sorting of thalamic data in ' num2str(cortex_time) ' seconds'])

total_time      = etime(clock, start_time);
disp(['Total time for Kilosort2 spike sorting of cortical and thalamic data: ' num2str(total_time) ' seconds'])

