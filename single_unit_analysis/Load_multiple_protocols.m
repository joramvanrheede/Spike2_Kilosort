
% fetch 3 protocol types

% Use this script to load data for a given protocol across multiple sessions
% This script will load data for all sessions contained in a target folder

% The folder that has the data folders for all sessions to be used in this
% analysis
target_folder       = '\\MARS\Sharott_Lab\users\naomi\recording data_processed\opsins';

% Keypress codes for the relevant protocols
ChR2_protocol_key       = 'p';
ArchT_protocol_key      = 'q';
ChR2_ArchT_protocol_key = 'r';

% If there are multiples of a protocol, load the 'first' or 'last'
% occurrence?
fetch_mode              = 'first';

% This function will now retrieve the target protocol from all sessions:
ChR2_only_data          = fetch_protocol(target_folder, ChR2_protocol_key, fetch_mode);
ArchT_only_data         = fetch_protocol(target_folder, ArchT_protocol_key, fetch_mode);
ChR2_ArchT_data         = fetch_protocol(target_folder, ChR2_ArchT_protocol_key, fetch_mode);

% Now 'protocol_data' lives as a variable in your workspace, move on to
% step 2


