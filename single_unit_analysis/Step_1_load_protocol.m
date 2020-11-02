% Use this script to load data for a given protocol across multiple sessions
% This script will load data for all sessions contained in a target folder

% The folder that has the data folders for all sessions to be used in this
% analysis
target_folder   = '\\MARS\Sharott_Lab\users\naomi\recording data_processed';

% Target protocol (identified by keypress code, or enter 'baseline')
target_protocol = 'p'; 

% If there are multiples of a protocol, load the 'first' or 'last'
% occurrence?
fetch_mode      = 'first';

% This function will now retrieve the target protocol from all sessions:
protocol_data   = fetch_protocol(target_folder, target_protocol, fetch_mode);

% Now 'protocol_data' lives as a variable in your workspace, move on to
% step 2