%% Set params and run

clear
close all


%% Params

clc

params = setParams('MOTU');
% Also sets chanmap

% Address for python TCP server
params.TCPAddr = '128.40.249.99';
params.TCPPort = 52012;

% Screen specific params
params.screenCalib.do = 0;
params.screenCalib.message = ...
    'Click each position clockwise, then x midpoint';
% Set number of monitors - response figures will be placed on last
params.nMons = 2;

% Subject parameters
params.Subject = 'Test';
params.nBlocks = 8;

% EyeTracking parameters
params.exchangeTime = 1; % If on, sync with Python computer

% params.Rates = [5, 15];
params.Rates = [5, 15];
params.Sides = [1, 2]; % 1 = left, 2 = right

% General type parameters
params.Positions = [-82.5, -67.5, -52.5, -37.5, -22.5, -7.5, ... (left)
   7.5, 22.5, 37.5, 52.5, 67.5, 82.5]; % Right
params.Types = [1, 2]; % 1 = cong, 2 = incon 
params.InconLimitMax = 60; % Maximum incongruency to include
params.InconLimitMin = 15; % Minimum incongruency to include
params.PositionMax = 75; % Absolute maximum position extremity 

% PTParams
params.PTSkip = 0;
params.PTThresh = 0.7;
params.PTnBlocks = 2;

% Specific stimulus parameters
params.gap1 = 60;
params.gap2 = 200;
params.rideNoise = 1;
params.eventLength = 20;
params.cutOff = 1200;
params.duration = 1100; 
params.startBuff = 40;
params.endBuff = 200;
params.vNoiseMag = -700;
params.aNoiseMag = -700;
params.aEventMag = 0.009;
params.SoundMax = 0.011;
params.LEDOffset = 0.5; % LED on at 0.55v
params.LEDMax = 1.1-params.LEDOffset; % 0.6 + offset = 1.1V
params.vEventMag = 0.9-params.LEDOffset;

params.nBreaks = 4;
params.breakTimeForcedWait = 5;


%% Run

if ~exist('isRunning', 'var')
    isRunning = 0;
end

% Temp
isRunning = 0;

if ~isRunning
    close all
    isRunning = 1;
    
    % isRunning returned to 0 on success 
    [isRunning, stimLog, params, stimOrder, PTLogs] = spatialCapture(params);
end

%% Save
% spatialCapture saves, but seperate save here for safety?

