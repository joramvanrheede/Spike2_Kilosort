function protocol_data = fetch_protocol(target_folder, protocol_code, fetch_mode)
% function protocol_data = fetch_protocol(target_folder, protocol_code, fetch mode)
% 
% Looks through all session folders in TARGET_FOLDER and load the protocol 
% indicated by PROTOCOL_CODE.
% 
% If multiple of the same protocols were run, FETCH_MODE determines which
% of the protocols is retrieved; 'first' is the default and will retrieve
% the protocol run first. Other option is 'last' (so there is an assumption
% that the same protocol isn't run more than twice in the same session).
% 
% OUTPUT:
%
% PROTOCOL_DATA: A 1 x N struct where N is the number of protocols
% retrieved, which equals the number of sessions in which the protocol was
% run at least once. Only one protocol will be loaded per session; the
% 'first' or 'last' one.
% 
% TARGET_FOLDER: Folder containing the session folders with the protocol
% data files.
% 
% PROTOCOL_CODE: Key code for the protocol of choice, or 'baseline' for a
% baseline recording.
% 
% FETCH_MODE: 'first' or 'last' - determines behaviour if there are
% multiple matches for a protocol code. Default is 'first' - will load only
% the first occurrence of the protocol in the file list. 'last' will load
% the last occurrence instead.
% 

% Hardcoded variable here: Maximal depth on the cortical shank
max_shank_depth = 700;

if nargin < 3
    fetch_mode = 'first';
end

% Get all session folders from the target folder
session_folders     = folder_from_folder(target_folder);

%%
protocol_data       = [];
counter             = 0;
for a = 1:length(session_folders)
    
    session_path        = fullfile(target_folder, session_folders{a});
    
    % get all .mat files from folder
    session_files       = dir(fullfile(session_path, '*.mat'));
    protocol_file_names = {session_files.name}';
    
    match_file_names    = {};
    match_counter       = 0;
    for b = 1:length(protocol_file_names)
        
        protocol_file_names{b};
        code_start_ind  = regexp(protocol_file_names{b},'[a-z]*\.mat');
        code_end_ind    = regexp(protocol_file_names{b},'\.mat') - 1;
        this_code       = protocol_file_names{b}(code_start_ind:code_end_ind);
        
        if strcmpi(this_code, protocol_code)
            match_counter       = match_counter + 1;
            match_file_names{match_counter}     = fullfile(session_path,protocol_file_names{b});
        end
           
    end
    
    if match_counter > 0
        % increment protocol counter
        counter     = counter + 1;
        
        % load protocol data (first or last one of the experiment)
        switch fetch_mode
            case 'first'
                protocol_file   = match_file_names{1};
            case 'last'
                protocol_file   = match_file_names{end};
        end
        
        disp(['Loading ' protocol_file])
        load(protocol_file)
        
        %% Extract cortical depth from filename
        [~, file_nm]     = fileparts(protocol_file);
        
        cx_depth_index     	= regexp(file_nm,'_C\d')+2;
        cx_depth_end        = regexp(file_nm,'_T') -1;
        cx_depth_string     = file_nm(cx_depth_index:cx_depth_end);
        cx_depth            = str2num(cx_depth_string);
        
        % For these probes, max_shank_depth = 700 microns
        cx_depth_adjustment = cx_depth - max_shank_depth;
        
        protocol_ID         = file_nm;
        
        ephys_data.cortex_probe_depth         	= cx_depth;
        ephys_data.cortex_adjusted_unit_depth   = ephys_data.cortex_unit_depths + cx_depth_adjustment;
        ephys_data.protocol_ID                  = protocol_ID;
        ephys_data.session_ID                   = session_folders{a};
        
        if isempty(protocol_data)
            protocol_data           = ephys_data;
        else
            protocol_data(counter)  = ephys_data;
        end
    else
        disp(['Protocol ' protocol_code ' not found in session ' session_folders{a}])
    end
    
end
