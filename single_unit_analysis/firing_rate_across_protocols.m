
target_folder   = '\\MARS\Sharott_Lab\users\naomi\recording data_processed';
target_protocol = 'p';

% Window for assessing baseline in seconds
baseline_win    = [0 5];

% Window for assessing 'target' in seconds
target_win      = [5 10];


%%

% Get target protocol from all sessions:
protocol_data   = fetch_protocol(target_folder, target_protocol)


