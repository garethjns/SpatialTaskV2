clear
close all


%% Import data
fn = 'EyeTracker\SurfaceTest3.p.mat';
[gaze, nG] = loadGaze(fn);


%% Preprocess gaze data

% Remove empty rows
gaze = gaze(~isnan(gaze.onSurf),:);

% % Apply threshold
% gazeThresh = 1;
% idx = gaze.onSurf>=gazeThresh;
% gaze.onSurf(idx) = true;
% gaze.onSurf(~idx) = false;

% Convert time
gaze.TS2 = datetime(gaze.TS, 'ConvertFrom', 'posixtime');


%% Plot outcome

figure
plot(gaze.TS, gaze.onSurf)

figure
scatter(gaze.NP(gaze.onSurf==true,1), gaze.NP(gaze.onSurf==true,2))
hold on
scatter(gaze.NP(gaze.onSurf==false,1), gaze.NP(gaze.onSurf==false,2))


%% Load trial data
gazePropThresh = 0.1;

fn = 'incomplete.mat';
a = load(fn);
stimLog = a.stimLog(~isnan(a.stimLog.PosBin(:,1)),:);
nT = height(stimLog);

% Convert time 
stimLog.sTime = datetime(stimLog.startClock);
stimLog.eTime = datetime(stimLog.endClock);

figure
hold on
% Add gaze data to stimLog
stimLog.onSurf = NaN(nT,1);
stimLog.nGazeSamples = NaN(nT,1);
stimLog.onSurfProp = NaN(nT,1);
for r = 1:nT
   ts = stimLog.sTime(r);
   te = stimLog.eTime(r);
   
   tIdx = gaze.TS2>=ts & gaze.TS2<=te;
   
   gs = gaze.onSurf(tIdx);
   
   stimLog.nGazeSamples(r) = numel(gs);
   stimLog.onSurfProp(r) = mean(gs);
   
   plot([ts,te], [gazePropThresh, gazePropThresh])
end

plot(stimLog.sTime, stimLog.onSurfProp)
hold on
plot(stimLog.sTime, stimLog.onSurfProp>=gazePropThresh )