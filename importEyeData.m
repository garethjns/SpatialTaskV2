% Exploratory analysis of eye data
% Guides processing in addEyeData function

clear
close all


%% Import Eye data

% fn = 'EyeTracker\SurfaceTest3.p.mat';
% fn = 'Data\8\02-Feb-2017 10_39_19\8.p.mat';
% fn = 'Data\GarethEye\21-Feb-2017 15_53_30\GarethEye.mat';
% fn = 'Data\ShriyaEye2\03-Mar-2017 14_55_20\ShriyaEye2.mat';
fn = 'Data\KatEye1\15-Mar-2017 12_32_08\KatEye1.mat';

% fn = 'Data\8\8.p.mat';
[gaze, nG] = loadGaze2(fn, {'TS', 'NP0', 'NP1', 'onSurf', 'mType'});


%% Load trial data

gazePropThresh = 0.5;

% fn = 'Data\8\02-Feb-2017 10_39_19\SpatialCapture_8.mat';
% fn = 'Data\GarethEye\21-Feb-2017 15_53_30\SpatialCapture_GarethEye.mat';
% fn = 'Data\ShriyaEye2\03-Mar-2017 14_55_20\SpatialCapture_ShriyaEye2.mat';
fn = 'Data\KatEye1\15-Mar-2017 12_32_08\SpatialCapture_KatEye1.mat';

% fn = 'Data\8\8.p.mat';
a = load(fn);
stimLog = a.stimLog(~isnan(a.stimLog.PosBin(:,1)),:);

nT = height(stimLog);

% Convert time 
stimLog.sTime = datetime(stimLog.startClock);
stimLog.eTime = datetime(stimLog.endClock);


%% Fix offset
% If data is available
% Get the MATLAB time and convert it to posix.
% Calculate the offset between the two
% Stimlog contains .timeStamp containing times of trials in MATLAB time
% gaze contains TS in posixtime (and TS2 in readable format)
% Add a column to gaze with the offset corrected, and converted to MATLAB
% time

if isfield(a, 'params') && isfield(a.params, 'pyTime') && isfield(a.params, 'matTime')
    
    % Convert MATLAB time to posix
    mTime = posixtime(datetime(a.params.matTime, 'ConvertFrom', 'datenum'));
    % Undo this to check it's no losing accuracy
    mTime2 = datenum(datetime(mTime, 'ConvertFrom', 'posixtime'));
    if a.params.matTime~=mTime2
       keyboard
    end
    % Py time is already posix
    pyTime = a.params.pyTime;
    
    % Calculate offset between py and matlab
    offset = mTime - pyTime;
    % Negative = py ahead. 

else
   offset = 0; 
end
    
% Save a new column with pyPosix time + offset
gaze.TS3 = gaze.TS + offset;
% Check this with readable column similar to TS2
% Note that datetime shouldn't lose accuracy
% datenum(TS4) shoud have same percision as TS3
gaze.TS4 = datetime(gaze.TS3, 'ConvertFrom', 'posixtime');
% ie:
% Should be 100%.... almost is
sum(gaze.TS3 ==  datenum(posixtime(gaze.TS4))) / height(gaze)


%% Preprocess gaze data

% Remove empty rows
nanIdx =  all(isnan([gaze.NP0, gaze.NP1, gaze.onSurf]),2);
gaze = gaze(~nanIdx,:);

% % Apply threshold
% gazeThresh = 1;
% idx = gaze.onSurf>=gazeThresh;
% gaze.onSurf(idx) = true;
% gaze.onSurf(~idx) = false;

% Convert time
gaze.TS2 = datetime(gaze.TS, 'ConvertFrom', 'posixtime');


%% Plot outcome

close all

figure
surfIdx = strcmp(gaze.mType, 'Surf');
plot(gaze.TS(surfIdx), gaze.onSurf(surfIdx))

plotGaze([gaze.NP0, gaze.NP1], gaze.onSurf, 'RawGaze')


%% Process gaze data
% Centre space, reduce noise, correct for drift during experiment. Expand
% surface?

% Steps:
% Find surface region in gaze
% Copy gaze to gazeCorrected
% Limit extreme values of NP 
% Plot (sp 1 of 3)
% Find and correct for drift. This zeros space. 
% Limit new extreme values 
% Plot (sp 2 and 3 of 3)
% Shift surface to centre of space
% Expand square surface by some factor
% Recalculate onSurf
% Calcualte "surface" from eculidan distance from [0,0](gazeCorrected.onSurfED) 
% Plot gazeCorrected.onSurf
% Plot gazeCorrected.onSurfED

% Parameters
lim = 4; % Extreme value limit
sExp = 1.5; % Surface expansion factor

gazeCorrected = gaze;

% onSurf extent [xMin, xMax, yMin, yMax]
onSurfEx = [min(gaze.NP0(gaze.onSurf==true)), ...
max(gaze.NP0(gaze.onSurf==true)), ...
min(gaze.NP1(gaze.onSurf==true)), ...
max(gaze.NP1(gaze.onSurf==true))];

% First, cap extreme values
gazeCorrected.NP0(gazeCorrected.NP0>lim) = lim;
gazeCorrected.NP0(gazeCorrected.NP0<-lim) = -lim;
gazeCorrected.NP1(gazeCorrected.NP1>lim) = lim;
gazeCorrected.NP1(gazeCorrected.NP1<-lim) = -lim;

subplot(3,1,1)
plot([gazeCorrected.NP0, gazeCorrected.NP1])
ylim([-5,5])
title('Limited gaze')

% Find drift in eye data
% Does mean eye position drift with time?
mAvRange = 2000; % pts
drift.NP0 = tsmovavg(gazeCorrected.NP0, 's', mAvRange, 1);
drift.NP1 = tsmovavg(gazeCorrected.NP1, 's', mAvRange, 1); 

% Corret drift in NP0
gazeCorrected.NP0(mAvRange+1:end) = ...
    gaze.NP0(mAvRange+1:end) ...
    - drift.NP0(mAvRange+1:end); % Avoid adding NaNs
% Corret drift in NP1
gazeCorrected.NP1(mAvRange+1:end) = ...
    gaze.NP1(mAvRange+1:end) ...
    - drift.NP1(mAvRange+1:end); % Avoid adding NaNs

% Again, limit extreme values
gazeCorrected.NP0(gazeCorrected.NP0>lim) = lim;
gazeCorrected.NP0(gazeCorrected.NP0<-lim) = -lim;
gazeCorrected.NP1(gazeCorrected.NP1>lim) = lim;
gazeCorrected.NP1(gazeCorrected.NP1<-lim) = -lim;

% Finish current figure
subplot(3,1,2)
plot([drift.NP0, drift.NP1])
ylim([-5,5])
title('Gaze drift')

subplot(3,1,3)
plot([gazeCorrected.NP0, gazeCorrected.NP1])
ylim([-5,5])
title('Corrected gaze')

% Space has now been centered around [0,0] (hopefully)
% Shift surface from eg. [0,1,0,1] to [-0.5,0.5,-0.5,0.5]
onSurfEx(1:2) = onSurfEx(1:2) - mean(onSurfEx(1:2));
onSurfEx(3:4) = onSurfEx(3:4) - mean(onSurfEx(3:4));
% Also expand by some tolerance value
onSurfEx = onSurfEx*sExp;

% Reclassify onSurf
gazeCorrected.onSurf = ...
    gazeCorrected.NP0>onSurfEx(1) ...
    & gazeCorrected.NP0<onSurfEx(2) ...
    & gazeCorrected.NP1>onSurfEx(3) ...
    & gazeCorrected.NP1<onSurfEx(4);

% Try eculidian distance
gazeCorrected.ED = ...
    sqrt(gazeCorrected.NP0.^2 + gazeCorrected.NP1.^2);
EDLim = max(onSurfEx*sExp);
gazeCorrected.onSurfED = gazeCorrected.ED<EDLim;

% Plot onSurf comparison
plotGaze([gazeCorrected.NP0, gazeCorrected.NP1], ...
    gazeCorrected.onSurf, 'gazeCorrected')

% Plot onSurf comparison (ED)
plotGaze([gazeCorrected.NP0, gazeCorrected.NP1], ...
    gazeCorrected.onSurfED, 'gazeCorrected - ED')


%% Replay gaze comaprison

if 1
    close all
    
    params1.target = 'rect';
    params1.size = onSurfEx*sExp;
    params1.lag = 6;
    params1.speed = 2;
    
    params2.target = 'circle';
    params2.size = EDLim;
    
    replayComparison(gaze, gaze.onSurf, params1, ...
        gazeCorrected, gazeCorrected.onSurfED, params2)
end


%% Plot trials and raw gaze

figure
hold on
% Add gaze data to stimLog
stimLog.onSurf = NaN(nT,1);
stimLog.nGazeSamples = NaN(nT,1);
stimLog.onSurfProp = NaN(nT,1);
stimLog.nGazeSamplesAfterThisTrial = NaN(nT,1);
stimLog.onSurfPropAfterThisTrial = NaN(nT,1);
% For each trial
% Get gaze prop during trial, and gaze prop after trial
for r = 1:nT
    
    % disp(num2str(r))
    
    ts = stimLog.sTime(r);
    te = stimLog.eTime(r);
    if r == nT
        tsNext = stimLog.sTime(r)+0.0000001;
    else
        tsNext = stimLog.sTime(r+1);
    end
    
    tIdx = gaze.TS4>=ts & gaze.TS4<=te;
    tNextIdx = gaze.TS4>te & gaze.TS4<tsNext;
    
    % gs = gazeCorrected.onSurfED(tIdx);
    gs = gaze.onSurf(tIdx);
    gsGap = gaze.onSurf(tNextIdx);
    
    stimLog.nGazeSamples(r) = numel(gs);
    stimLog.onSurfProp(r) = nanmean(gs);
    stimLog.nGazeSamplesAfterThisTrial(r) = numel(gsGap);
    stimLog.onSurfPropAfterThisTrial(r) = nanmean(gsGap);
    
    % plot([ts,te], [1.001, 1.001], 'LineWidth', 3)
    % plot([ts,te], [stimLog.onSurfProp(r), stimLog.onSurfProp(r)], 'LineWidth', 3, 'Color',  'k')
    % plot([te,te], [stimLog.onSurfPropAfterThisTrial(r), stimLog.onSurfPropAfterThisTrial(r)], 'LineWidth', 1, 'Color',  'b')
    % plot([te,tsNext], [stimLog.onSurfPropAfterThisTrial(r), stimLog.onSurfPropAfterThisTrial(r)], 'LineWidth', 3, 'Color',  'r')
    % drawnow
    
    % Trial indicator
    plot([ts,te], ...
        [1.001, 1.001], ...
        'LineWidth', 3)
    % During trial eye prop
    plot([ts,te], ...
        [stimLog.onSurfProp(r), ...
        stimLog.onSurfProp(r)], ...
        'LineWidth', 3, 'Color',  'k')
    % Prop-direction indicator line
    if stimLog.onSurfProp(r) > stimLog.onSurfPropAfterThisTrial(r)
        col = 'b';
        % If everything is working and subject is behaving,
        % expecting higher on target prop during trials, and less
        % when subject looks down to respond.
    else
        % Yellow if surface proportion is higher off trial than it
        % was during trial - will indicate spatial or temporal
        % drift, or subject errors.
        col = 'y';
    end
    plot([te,te], ...
        [stimLog.onSurfProp(r), ...
        stimLog.onSurfPropAfterThisTrial(r)], ...
        'LineWidth', 1, 'Color',  col)
    % Outside trial eye prop
    plot([te,tsNext], ...
        [stimLog.onSurfPropAfterThisTrial(r), ...
        stimLog.onSurfPropAfterThisTrial(r)], ...
        'LineWidth', 3, 'Color',  'r')
end

% plot(stimLog.sTime, stimLog.onSurfProp)
% plot(stimLog.sTime, stimLog.onSurfProp>=gazePropThresh)

%% Plot trials and corrected gaze

figure
hold on
% Add gaze data to stimLog
stimLog.gazeCorrectedOnSurf = NaN(nT,1);
stimLog.nGazeCorrectedSamples = NaN(nT,1);
stimLog.gazeCorrectedOnSurfProp = NaN(nT,1);
stimLog.nGazeCorrectedSamplesAfterThisTrial = NaN(nT,1);
stimLog.gazeCorrectedOnSurfPropAfterThisTrial = NaN(nT,1);
% For each trial
% Get gaze prop during trial, and gaze prop after trial
for r = 1:nT
    
    % disp(num2str(r))
    
    ts = stimLog.sTime(r);
    te = stimLog.eTime(r);
    if r == nT
        tsNext = stimLog.sTime(r)+0.0000001;
    else
        tsNext = stimLog.sTime(r+1);
    end
    
    tIdx = gazeCorrected.TS4>=ts & gazeCorrected.TS4<=te;
    tNextIdx = gazeCorrected.TS4>te & gazeCorrected.TS4<tsNext;
    
    % gs = gazeCorrected.onSurfED(tIdx);
    gs = gazeCorrected.onSurf(tIdx);
    gsGap = gazeCorrected.onSurf(tNextIdx);
    
    stimLog.nGazeCorrectedSamples(r) = numel(gs);
    stimLog.gazeCorrectedOnSurfProp(r) = mean(gs);
    stimLog.nGazeCorrectedSamplesAfterThisTrial(r) = numel(gsGap);
    stimLog.gazeCorrectedOnSurfPropAfterThisTrial(r) = mean(gsGap);
    
    plot([ts,te], [1.001, 1.001], 'LineWidth', 3)
    plot([ts,te], [stimLog.gazeCorrectedOnSurfProp(r), stimLog.gazeCorrectedOnSurfProp(r)], 'LineWidth', 3, 'Color',  'k')
    plot([te,tsNext], [stimLog.gazeCorrectedOnSurfPropAfterThisTrial(r), stimLog.gazeCorrectedOnSurfPropAfterThisTrial(r)], 'LineWidth', 3, 'Color',  'r')
    % drawnow
end

% plot(stimLog.sTime, stimLog.onSurfProp)
% plot(stimLog.sTime, stimLog.onSurfProp>=gazePropThresh)
