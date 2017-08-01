function params = setParams(set)

% Standard harware params for current set up
params.Fs = 48000;
params.chanMap = [1:24; [1:3,1:12,4:12]; ...
    ones(1,3)+1, ones(1,12), ones(1,9)+1; ...
    ones(1,24)];

% Map using 0 between 2 speakers (15 deg sep)
posVec = [-82.5 -67.5, -52.5, ... V
    -82.5, -67.5, -52.5, -37.5, -22.5, -7.5, ... A (left)
    7.5, 22.5, 37.5, 52.5, 67.5, 82.5, ... A (right)
    -37.5, -22.5, -7.5, 7.5, 22.5, 37.5, 52.5, 67.5, 82.5]; % V
params.chanMap2 = [1:24; [1:3,1:12,4:12]; ...
    ones(1,3)+1, ones(1,12), ones(1,9)+1; ...
    posVec];

% chanMap2:
% (1,:) = Channel number
% (2,:) = Modality channel number
% (3,:) = Modality ID 
% (4,:) = Physical location

params.soundMax = 0.25;
params.LEDOffset = 0.54; % LED on at 0.55v
params.LEDMax = 1.1; % 0.6 + offset = 1.1V

switch set
    case 'QuickTone'
        params.duration = 1; % S
        params.freq = 2000; % Hz
        params.riseTime = 0.020; % 20 ms
        params.amp = 0.15; % V
        params.reps = 1;
        params.wait = 2;
        
    case 'MOTU'
        params.nChannels = 24;
        
    otherwise
end
