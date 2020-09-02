function success = write_binary(file_name,chan_data,mode)
% function success = write_binary(filename,chan_data,mode)
% 
% Write CHAN_DATA to binary file FILE_NAME, either appending to existing file
% (MODE = 'append') or by creating / overwriting the file (MODE = 'write').
% 
%
% INPUTS:
% 
% FILENAME: Full file name of file to write
% 
% CHAN_DATA: an N_CHANNELS * N_SAMPLES matrix of data to be written
% 
% MODE: 'w'/'write' or 'a'/'append' 
% 
% OUTPUTS:
% 
% SUCCESS: Whether or not writing to file was successful
% 
% Joram van Rheede, 2020

% Use 'mode' to set write / append permission when opening file
switch mode
    case 'write'
        fopen_mode = 'w';
    case 'w'
        fopen_mode = 'w';
    case 'append'
        fopen_mode = 'a';
    case 'a'
        fopen_mode = 'a';
end

% Open file in specified mode
fid = fopen(file_name,fopen_mode);

% Write data to file as int16
write_count = fwrite(fid,chan_data,'int16');

% Close file
fclose(fid);

% Was full write successful?
if write_count == numel(chan_data)
    success = 1;
else
    success = 0;
end

