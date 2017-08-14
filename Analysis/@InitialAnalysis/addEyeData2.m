function [stimLog, gaze] = ...
    addEyeData2(stimLog, eyePath, params, plotOn, print)
% Add eye tracker data to stimLog.
% Handles empty eye data subjects
% Inheriting from importEyeDataScript, using loadGaze2, which handles surf
% and gaze subscriptions
% Adds gaze data to stimLog after syncing timing
% No longer adds correctedGaze - shouldn't be needed.
%
% Parameters hardcoded here for now
% To do:
% Add plot flag, subject name to graph titles

if ~exist('print', 'var')
    print = true;
end

%% Import data

nT = height(stimLog);

if ~isempty(eyePath)
    if print; disp('Adding eye data...'); end
    [gaze, ~] = InitialAnalysis.loadGaze2(eyePath, ...
        {'TS', 'NP0', 'NP1', 'onSurf', 'mType'});
    
    % Remove empty rows
    % NB: This also removes all data from the gaze subscription as it
    % doesn't contain onSurf. But shouldn't need this anyway.
    gaze = gaze(~isnan(gaze.onSurf),:);
    process = true;
else
    if print; disp('No eye data...'); end
    % No gaze data, turn off processing
    % Placeholders added below
    process = false;
    gaze = [];
end


%% If eye data available, process
% Assuming timing sync data is available
% Check removed - return error if not

% Convert time in stimLog
stimLog.sTime = datetime(stimLog.startClock);
stimLog.eTime = datetime(stimLog.endClock);

if process
    % Get the MATLAB time and convert it to posix.
    % Calculate the offset between the two
    % Stimlog contains .timeStamp containing times of trials in MATLAB time
    % gaze contains TS in posixtime (and TS2 in readable format)
    % Add a column to gaze with the offset corrected, and converted to MATLAB
    % time
    
    % Convert MATLAB time to posix
    mTime = posixtime(datetime(params.matTime, 'ConvertFrom', 'datenum'));
    % Undo this to check it's no losing accuracy
    mTime2 = datenum(datetime(mTime, 'ConvertFrom', 'posixtime'));
    if params.matTime~=mTime2
        keyboard
    end
    % Py time is already posix
    pyTime = params.pyTime;
    
    % Calculate offset between py and matlab
    offset = mTime - pyTime;
    % Negative = py ahead.
    
    % Save a new column with pyPosix time + offset
    gaze.TS3 = gaze.TS + offset;
    % Check this with readable column similar to TS2
    % Note that datetime shouldn't lose accuracy
    % datenum(TS4) shoud have same percision as TS3
    gaze.TS4 = datetime(gaze.TS3, 'ConvertFrom', 'posixtime');
    % ie:
    % Should be 100%.... almost is - rounding errors??
    disp(['Timing rounding check: ', ...
        num2str(sum(gaze.TS3==datenum(posixtime(gaze.TS4))) ...
        / height(gaze)), '% identical (posix==datetime)'])
    
end


%% Add gaze data to stimLog
% gaze now contains:
% .TS original Python timestamp
% .NP0, .NP1 norm pos from either gaze or surface subscription
% .onSurf surface "logical" from surface subscription. Average of packets
% recieved at same timestamp.
% .mType subscription type - just Surf here as any NaNs-in-onSurf rows
% dropped (ie. all rows from 'gaze' subscription)
% .TS3 corrected time in posix
% .TS4 corrected time in datetime object - human readable and should
% maintain percision

% Adding these cols to stimLog
% If not processing, just left as NaN placeholders
stimLog.onSurf = NaN(nT,1);
stimLog.nGazeSamples = NaN(nT,1);
stimLog.onSurfProp = NaN(nT,1);
stimLog.nGazeSamplesAfterThisTrial = NaN(nT,1);
stimLog.onSurfPropAfterThisTrial = NaN(nT,1);

if process
    
    % First turn .onSurf in to a proper logical
    gaze.onSurf(gaze.onSurf<0.5) = 0;
    gaze.onSurf(gaze.onSurf>=0.5) = 1;
    
    if plotOn
        figure
        hold on
    end
    
    
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
        
        if plotOn
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
    end
end

