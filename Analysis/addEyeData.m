function stimLog = addEyeData(stimLog, eyePath)
% Add eye tracker data to stimLog.
% Handles empty eye data subjects
% Inheriting from importEyeDataScript. Add basic eye data and corrected eye
% data to slimLog
% Parameters hardcoded here for now
% To do:
% Add plot flag, subject name to graph titles


%% Import data

nT = height(stimLog);

if ~isempty(eyePath)
    [gaze, nG] = loadGaze(eyePath, {'TS', 'NP0', 'NP1', 'onSurf'});
    
    % Remove empty rows
    gaze = gaze(~isnan(gaze.onSurf),:);
    process = true;
else
    % No gaze data, create placeholders, turn off processing
    gaze.TS = NaN(nT, 1);
    gaze.onSurf = NaN(nT, 1);
    gaze.onSurfPropCorrectedED = NaN(nT, 1);
    gaze.onSurfED = NaN(nT, 1);
    gazeCorrected = gaze;
    process = false;
end


%% Convert time
gaze.TS2 = datetime(gaze.TS, 'ConvertFrom', 'posixtime');
stimLog.sTime = datetime(stimLog.startClock);
stimLog.eTime = datetime(stimLog.endClock);


%% Add gaze data to stimLog with minimal processing
% ie. Just merge times, don't create an "on surf" logical here

% These loops are slow and pointless to run when just adding placeholder
% data!

% Add gaze data to stimLog
% stimLog.onSurf = NaN(nT,1);
stimLog.nGazeSamples = NaN(nT,1);
stimLog.onSurfProp = NaN(nT,1);

for r = 1:nT
    ts = stimLog.sTime(r);
    te = stimLog.eTime(r);
    
    tIdx = gaze.TS2>=ts & gaze.TS2<=te;
    
    gs = gaze.onSurf(tIdx);
    
    stimLog.nGazeSamples(r) = numel(gs);
    stimLog.onSurfProp(r) = mean(gs);
    
    % plot([ts,te], [gazePropThresh, gazePropThresh])
end


%% Correct gaze data

if process
    % Parameters
    lim = 4; % Extreme value limit
    sExp = 1.5; % Surface expansion factor
    mAvRange = 2000; % pts
    
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
    
end

%% Add corrected gaze data to stimLog
% Add gaze data to stimLog
% Don't include onSurf logical yet
% Don't re-add nGazeSameples

% These loops are slow and pointless to run when just adding placeholder
% data!

stimLog.onSurfPropCorrectedED = NaN(nT,1);

for r = 1:nT
    ts = stimLog.sTime(r);
    te = stimLog.eTime(r);
    
    tIdx = gaze.TS2>=ts & gaze.TS2<=te;
    
    gs = gazeCorrected.onSurfED(tIdx);
    
    stimLog.onSurfPropCorrectedED(r) = mean(gs);
    
    % plot([ts,te], [gazePropThresh, gazePropThresh])
end

