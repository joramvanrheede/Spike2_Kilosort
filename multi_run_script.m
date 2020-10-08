
preprocessed_data_folder = 'C:\Spike_sorting\processed_data';

folder_contents         = dir(preprocessed_data_folder);
folder_contents         = folder_contents([folder_contents.isdir]);

error_msgs      = [];
error_folders   = [];
for a = 1:length(folder_contents)
    this_folder = folder_contents(a).name;
    if strcmp(this_folder,'.')
        continue
    elseif strcmp(this_folder,'..')
        continue
    end
    
    try
        run([preprocessed_data_folder filesep this_folder filesep 'full_sort_script_local.m'])
    catch
        error_msgs{a}       = ['error processing ' this_folder];
        error_folders{a}    = this_folder;
    end
    
end