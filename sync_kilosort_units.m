function [sorted_ephys_data] = sync_kilosort_units(kilosort_dir, data_file_name, trial_events_file, kilosort_sample_rate)
% function [sorted_ephys_data] = sync_kilosort_units(kilosort_dir, data_file_name, trial_events_file, kilosort_sample_rate)
% 
% Takes output from Kilosort and pre-made sync_data structure from
% 'preprocess_smr_files', and distributes the sorted spikes for each cluster 
% to the relevant recordings aligned to trials.
% 
% INPUTS:
% 
% KILOSORT_DIR: The directory with the Kilosort output as well as the Kilosort 
% binary data file
% 
% DATA_FILE_NAME: The binary data file name (XXX.dat)
% 
% TRIAL_EVENTS_FILE: Name of saved sync_data file from preprocess_smr_files
% 
% KILOSORT_SAMPLE_RATE: The rate at which Kilosort believes the data were sampled
% (There may be a discrepancy with the actual sample rate which is corrected 
% in this function).
% 
% OUTPUT: 
% 
% SORTED_EPHYS_DATA: This is a data structure based on the sync_data variable
% from TRIAL_EVENTS_FILE, but with added field 'SPIKES' containing the sorted
% spikes for each cluster, organised as n_units * n_trials * n_spikes (and
% padded with NaNs to account for unequal numbers of spikes between units and 
% trials.
% 
% Also added are 'unit_depths' - the depths of the sorted units, and 'unit_waveforms',
% the waveforms of the spikes.
% 
% Joram van Rheede 2020
% 


%% Load Kilosorted data using CortexLab/spikes functions (see cortexlab GitHub page)

sp                      = loadKSdir(kilosort_dir); % CortexLab/spikes function to read in Kilosorted, phy-curated data quickly

% Unpack some of the loadKSdir data
spike_times     = sp.st;    % Spike times for all spikes, N spikes * 1 vector
cluster_ids     = sp.clu;   % cluster ID (number) for each spike time, N spikes * 1 vector
cluster_numbers = sp.cids;  % IDs of all clusters (1 * N clusters vector of ascending integers, starting at 0, with potential gaps for merged clusters)
cluster_groups  = sp.cgs;   % Group corresponding to each cluster_number, 1 * N clusters vector --> 1 = MUA, 2 = 'Good' unit

% OBSOLETE:
% % CortexLab/spikes function to get more info about the clusters using the loadKSdir data
% % We need spikeDepths, a N spikes * 1 vector, to determine the depth of the clusters
% [spikeAmps, spikeDepths, templateDepths, tempAmps, tempsUnW, templateDuration, waveforms] = templatePositionsAmplitudes(sp.temps, sp.winv, sp.ycoords, sp.spikeTemplates, sp.tempScalingAmps);
% 

%% The following code is taken / adapted from CortexLab/spikes function templatePositionsAmplitudes;
% modified to get horizontal (x) positions of units / templates as well; taken out of original function to remove dependency on Cortexlab/spikes

% unwhiten all the templates
tempsUnW = zeros(size(sp.temps));
for t = 1:size(sp.temps,1)
    tempsUnW(t,:,:) = squeeze(sp.temps(t,:,:))*sp.winv;
end

% The amplitude on each channel is the positive peak minus the negative
tempChanAmps = squeeze(max(tempsUnW,[],2))-squeeze(min(tempsUnW,[],2));

% The template amplitude is the amplitude of its largest channel (but see
% below for true tempAmps)
tempAmpsUnscaled = max(tempChanAmps,[],2);

% need to zero-out the potentially-many low values on distant channels ...
threshVals = tempAmpsUnscaled*0.3; % Why 0.3?
tempChanAmps(bsxfun(@lt, tempChanAmps, threshVals)) = 0;

% ... in order to compute the depth as a center of mass
templateDepths  = sum(bsxfun(@times,tempChanAmps,sp.ycoords'),2)./sum(tempChanAmps,2);
templateXpos    = sum(bsxfun(@times,tempChanAmps,sp.xcoords'),2)./sum(tempChanAmps,2);

% Each spike's depth is the depth of its template
spikeDepths = templateDepths(sp.spikeTemplates+1);
spikeXpos   = templateXpos(sp.spikeTemplates+1);

%% Extract mean spike waveforms here

gwfparams.dataDir           = kilosort_dir;         % KiloSort/Phy output folder
gwfparams.fileName          = data_file_name;     	% .dat file containing the raw 
gwfparams.dataType          = 'int16';              % Data type of .dat file (this should be BP filtered)
gwfparams.nCh               = 32;               	% Number of channels that were streamed to disk in .dat file
gwfparams.wfWin             = [-60 61];         	% Number of samples before and after spiketime to include in waveform
gwfparams.nWf               = 500;               	% Number of waveforms per unit to pull out
gwfparams.spikeTimes        = ceil(sp.st * kilosort_sample_rate); %ceil(sp.st(sp.clu==0)*30000); % Vector of cluster spike times (in samples) same length as .spikeClusters
gwfparams.spikeClusters     = sp.clu;               % sp.clu(sp.clu==0);

waveform_data               = getWaveForms(gwfparams);

mean_unit_waveforms         = waveform_data.waveFormsMean;

%% Select 

% Get depth of cluster by identifying the unique cluster / depth pairs
cluster_depths  = unique([cluster_ids, spikeDepths],'rows');
cluster_xpos    = unique([cluster_ids, spikeXpos],'rows');

% boolean for selecting units
is_unit         = cluster_groups == 2;

% get cluster numbers and depths for confirmed 'Good' units only
unit_clusters   = cluster_numbers(is_unit);
unit_depths     = cluster_depths(is_unit,2);
unit_xpos       = cluster_xpos(is_unit,2);

unit_waveforms  = mean_unit_waveforms(is_unit,:,:);

unit_coords                 = [unit_xpos, unit_depths]; % put x-y coordinates together so they can be sorted by xpos then ypos

% Sort by depth, from superficial to deep (this will be the order in which units are added to the sorted_ephys_data struct)
[sort_coords, coord_order]  = sortrows(unit_coords);

% Sort unit waveforms according to the depth order
unit_waveforms              = unit_waveforms(coord_order,:,:); 

% Make boolean to select only spikes that came from confirmed 'Good' units
is_unit_spike   = ismember(cluster_ids,unit_clusters);

% Select only spikes and corresponding cluster IDs from good units
spike_times     = spike_times(is_unit_spike);
cluster_ids     = cluster_ids(is_unit_spike);

% See which clusters are left
uniq_clusters   = unique(cluster_ids);
n_clusters      = length(uniq_clusters);

%% Load files for stimulus sync
load(trial_events_file); % loads 'sync_data' variable

% Copy to new struct that will be populated with spike data as the output of this function
sorted_ephys_data   = sync_data;

% Kilosort takes in an integer valued sample rate so adjust for the slight difference
rec_start_times         = [sync_data.rec_start_time]';
kilosort_time_factor    = sync_data(1).sample_rate / kilosort_sample_rate;

kilosort_start_times    = rec_start_times * kilosort_time_factor;

%% Assign Kilosorted spike times to trials and conditions in sorted_ephys_data

for a = 1:length(sorted_ephys_data)
    disp(['Loading recording nr ' num2str(a) ' of ' num2str(length(sorted_ephys_data))])
    
    kilosort_rec_start_time     = kilosort_start_times(a);
    
    for c = 1:length(sorted_ephys_data(a).trial_starts)
        for d = 1:n_clusters
            this_cluster        = uniq_clusters(coord_order(d));
            q_cluster           = cluster_ids == this_cluster;
            
            % Make relative to Kilosort concatenated data time, not openephys recording time stamp
            trial_start         = sorted_ephys_data(a).trial_starts(c) * kilosort_time_factor + kilosort_rec_start_time;
            trial_end           = sorted_ephys_data(a).trial_ends(c) * kilosort_time_factor + kilosort_rec_start_time;
            
            q_trial             = spike_times >= trial_start & spike_times < trial_end;
            
            % get relevant spike times and make them relative to trial onset
            unit_trial_spikes   = spike_times(q_cluster & q_trial) - trial_start;
            
            % Assign spikes for cluster to this condition
            sorted_ephys_data(a).spikes(d,c,1:length(unit_trial_spikes))  = unit_trial_spikes / kilosort_time_factor;
            
        end
    end
    
    % set empty values to NaN instead of 0
    sorted_ephys_data(a).spikes(sorted_ephys_data(a).spikes == 0) = NaN;
    
    % Add unit position information
    sorted_ephys_data(a).unit_depths        = sort_coords(:,2);
    sorted_ephys_data(a).unit_xpos          = sort_coords(:,1);
    
    % Add waveform information too
    sorted_ephys_data(a).unit_waveforms     = unit_waveforms;
end




