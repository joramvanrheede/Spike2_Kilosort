%  create a channel map file

Nchannels = 32;
connected = true(Nchannels, 1);
chanMap   = [41, 34, 44, 42, 40, 43, 45, 35; ...
             37, 47, 36, 38, 33, 46, 32, 39; ...
             16, 26, 18, 27, 17, 30, 29, 31; ...
             21, 22, 24, 20, 23, 28, 25, 19] - 15;
            
chanMap0ind = chanMap - 1;

% x-coordinates in microns (0 = most medial)
xcoords   = [0, 0, 0, 0, 0, 0, 0, 0; ...
             200, 200, 200, 200, 200, 200, 200, 200; ...
             400, 400, 400, 400, 400, 400, 400, 400; ...
             600, 600, 600, 600, 600, 600, 600, 600];

% y-coordinates in microns (0 = most superficial)
ycoords   = [0:100:700; ...
             0:100:700; ...
             0:100:700; ...
             0:100:700];

kcoords   = [1, 1, 1, 1, 1, 1, 1, 1; ...
             2, 2, 2, 2, 2, 2, 2, 2; ...
             3, 3, 3, 3, 3, 3, 3, 3; ...
             4, 4, 4, 4, 4, 4, 4, 4]; % grouping of channels (i.e. tetrode groups)

fs = 20000; % sampling frequency
save([cd filesep 'chanMap.mat'], ...
    'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')

%%
% 
% Nchannels = 32;
% connected = true(Nchannels, 1);
% chanMap   = 1:Nchannels;
% chanMap0ind = chanMap - 1;
% 
% xcoords   = repmat([1 2 3 4]', 1, Nchannels/4);
% xcoords   = xcoords(:);
% ycoords   = repmat(1:Nchannels/4, 4, 1);
% ycoords   = ycoords(:);
% kcoords   = ones(Nchannels,1); % grouping of channels (i.e. tetrode groups)
% 
% fs = 30000; % sampling frequency
% 
% save([cd filesep 'chanMap.mat'], ...
%     'chanMap','connected', 'xcoords', 'ycoords', 'kcoords', 'chanMap0ind', 'fs')
% %%
