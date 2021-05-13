

save_folder         = 'C:\Spike_sorting\synched_data';
data_folder         = 'C:\Spike_sorting\curated_data';

%% No further input required from here


% Filename to save the synched & sorted data

session_folders             = dir(data_folder);
session_folders             = session_folders([session_folders.isdir]);
sessions                    = {session_folders.name};
q_remove                    = ismember(sessions, {'.', '..'});
sessions                    = sessions(~q_remove);

for a = 1:length(sessions)
    
    this_session                = sessions{a};
    
    session_kilosort_folder     = [data_folder filesep this_session];
    session_save_folder         = [save_folder filesep this_session];
    
    if ~isfolder(session_save_folder)
        mkdir(session_save_folder)
    end
    
    % The actual function for postprocessing kilosort data, distributing the
    % unit spike times across the protocols and trials contained in
    % experiment_sync_data.mat (generated during the preprocessing stage)
    postprocess_kilosort_cortex_only(session_kilosort_folder, session_save_folder, this_session)
end