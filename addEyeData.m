function stimLog = addEyeData(stimLog, eyePath)
% Add eye tracker data to stimLog.

%% Import data

nT = height(stimLog);

if ~isempty(eyePath)
    [gaze, nG] = loadGaze(eyePath, {'TS', 'onSurf'});
    
    % Remove empty rows
    gaze = gaze(~isnan(gaze.onSurf),:);
    
else
     gaze.TS = NaN(nT, 1);
     gaze.onSurf = NaN(nT, 1);
end


%% Add gaze data to stimLog with minimal processing
% ie. Just merge times, don't create an "on surf" logical here

% Convert time
gaze.TS2 = datetime(gaze.TS, 'ConvertFrom', 'posixtime');
stimLog.sTime = datetime(stimLog.startClock);
stimLog.eTime = datetime(stimLog.endClock);

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

