function obj = import(obj, eyePlot, debug, print)
% Import data set by .setPaths
% Do subject/task version specific preprocessing - standardise columns,
% add eye data, etc.
% Do basic preprocessing - add Correct column etc.

%% Parse inputs and set defualts
% Needs updating to work properly!

if ~exist('debug', 'var')
    debug = true;
end
if ~exist('eyePlot', 'var')
    eyePlot = true;
end
if ~exist('print', 'var')
    print = true;
end


%% Import

eN = numel(fields(obj.exp));
obj.expN = eN;

allData = [];
clear data
for e = 1:eN
    % Get subject field
    fn = obj.exp.(['s', num2str(e)]);
    if print; disp(['Loading ', fn]); end
    
    % Load psychophysics data
    a = load(fn);
    
    % Remove trials without responses
    % Using aStim field as it#s common to all versions and is populated on
    % response
    rmIdx = cellfun(@isempty, a.stimLog.aStim);
    a.stimLog = a.stimLog(~rmIdx,:);
    
    % Get number of available trials
    n = height(a.stimLog);
    if print; disp(['Loaded ', num2str(n), ' trials']); end
    
    % For all data, correct angle calculation from raw response
    newAngles = cellfun(@SpatialAnalysis.calcAngle, ...
        a.stimLog.RawResponse, ...
        'UniformOutput', false);
    
    % And recalc diff angle
    da = cell2mat(a.stimLog.diffAngle);
    pos = mat2cell(a.stimLog.Position, ...
        ones(height(a.stimLog),1), 2);
    newDiffAngles = cellfun(@SpatialAnalysis.diffAngle, ...
        pos, newAngles, ...
        'UniformOutput', false);
    
    % And respBinAn
    newRespBinAn = cellfun(@SpatialAnalysis.calcRespBinAn, ...
        newAngles, ...
        'UniformOutput', false);
    
    if debug % Debug plots
        
        % Plot comparison of diff and old angles
        figure 
        nda = cell2mat(newDiffAngles);
        scatter(da(1:2:end), nda(1:2:end))
        hold on
        scatter(da(2:2:end), nda(2:2:end))
        legend({'Aud', 'Vis'})
        xlabel('Old angle')
        ylabel('New angle')
        title(['Subject: ', num2str(e), ...
            'Comparison of diff angles'])
        % This looks like this because the diffAngles have different error
        % added at different locations
        % The ksdensity therefore has multiple peaks:
        % eg. 15 (resp) error + pos 7.5 error
        % 15 (resp) error + pos 22.5 error, etc ....
        figure
        subplot(2,1,1)
        ksdensity(da(1:2:end), 'bandwidth', 1)
        hold on
        ksdensity(nda(1:2:end), 'bandwidth', 1)
        legend({'Aud new', 'Aud old'})
        subplot(2,1,2)
        ksdensity(da(2:2:end), 'bandwidth', 1)
        hold on
        ksdensity(nda(2:2:end), 'bandwidth', 1)
        legend({'Vis new', 'Vis old'})
        xlabel('Response error')
        suptitle(['Subject: ', num2str(e), ...
            'Distribution of resp errors across all positions'])
        % That's better - reponse error is binned (mostly) at -15, 0, 15,
        % and doesn't vary with response location (which it shouldn't,
        % assuming subjects are using points on response screen to
        % self-bin, which they do - see raw response plots in
        % initalAnalysis)
        
        % Plot overall distribution of responses across space
        avNew = cell2mat(newAngles);
        av = cell2mat(a.stimLog.Angle);
        
        aNew = avNew(1:2:end);
        vNew = avNew(2:2:end);
        aOld = av(1:2:end);
        vOld = av(2:2:end);
        
        figure
        subplot(2,1,1)
        [yAOld, xAOld] = ksdensity(aOld, 'bandwidth', 2);
        plot(xAOld, yAOld)
        hold on
        [yANew, xANew] = ksdensity(aNew, 'bandwidth', 2);
        plot(xANew, yANew)
        title('Auditory responses')
        legend({'Uncorrected', 'Corrected'})
        subplot(2,1,2)
        [yVOld, xVOld] = ksdensity(vOld, 'bandwidth', 2);
        plot(xVOld, yVOld)
        hold on
        [yVNew, xVNew] = ksdensity(vNew, 'bandwidth', 2);
        plot(xVNew, yVNew)
        title('Visual responses')
        suptitle(['Subject: ', num2str(e), ...
            ' Corrected angle plot'])
        % This now looks as expected - response peaks line up with
        % indicated response locations, whereas previous there was error
        % scaled by absolte location
        
        % Plot FFT - periodicity of response binning should be 15 degs, as
        % per locations on response figure.
        figure
        subplot(2,1,1)
        InitialAnalysis.plot180FFT(xAOld, yAOld)
        hold on
        InitialAnalysis.plot180FFT(xANew, yANew, ...
            'Auditory responses')
        subplot(2,1,2)
        InitialAnalysis.plot180FFT(xVOld, yVOld)
        hold on
        InitialAnalysis.plot180FFT(xVNew, yVNew, ...
            'Visual responses')
        suptitle(['Subject: ', num2str(e), ...
            ' Response angle regularity'])
        % And it is - whereas before it was <15 (representing the error
        % from the miscalucation averaged over absolute space).
        
    end
    
    % Sabe new values
    a.stimLog.diffAngle = newDiffAngles;
    a.stimLog.respBinAn = newRespBinAn;
    a.stimLog.Angle = newAngles;
    
    % TO DO:
    % Check respBinED
    % Seems to be same as respBinAn before angle correction??
    % Check calculation in task code
    % It's not generally used anyway
    % But in case, for now, set to be same as respBinAn
    a.stimLog.respBinED = newRespBinAn;
    
    % Process data according to version subject was run on
    % (swithces not mutually exclusive)
    % V1: S1 and S2
    switch fn
        case {obj.exp.s1, obj.exp.s2}
            % These two lack two columns present in later exps,
            % add dummies PossBinLog and PossBin
            
            poss = [-82.5, unique(a.stimLog.Position)', 82.5];
            
            a.stimLog.PosBinLog = cell(n,1);
            a.stimLog.PosBin = NaN(n,2);
            
            for t = 1:n
                a.stimLog.PosBinLog{t} = ...
                    [a.stimLog.Position(t,1) == poss; ...
                    a.stimLog.Position(t,2) == poss];
                
                a.stimLog.PosBin(t,:) = ...
                    [find(a.stimLog.PosBinLog{t}(1,:));...
                    find(a.stimLog.PosBinLog{t}(2,:))];
            end
    end
    
    % V2: S1-6
    switch fn
        case {obj.exp.s1, obj.exp.s2, obj.exp.s3, ...
                obj.exp.s4, obj.exp.s5, obj.exp.s6}
            % These need dummy timing columns
            n = height(a.stimLog);
            a.stimLog.timeStamp = NaN(n, 2);
            a.stimLog.startClock = ...
                repmat([1900, 1, 1, 1, 1, 1],n,1);
            a.stimLog.endClock = ...
                repmat([1900, 1, 1, 1, 1, 1],n,1);
    end
    
    % V3: - add eyedata if available
    % If not, adds placeholders
    % Available S7 onwards, but run for all
    switch fn
        case {obj.exp.s1, obj.exp.s2, obj.exp.s3, ...
                obj.exp.s4, obj.exp.s5, obj.exp.s6, obj.exp.s7}
            % Not using eye data
            % Give addEyeData2 some dummy params
            a.params = [];
            
        otherwise % Fututre exps (8 onwards)
            % From here, timesync info is available in params.
            % Need to load this.
            % Not using eye data from before this.
            % stimlog should contains gaze, not correctedGaze
            % any more.
            
            % No additional processing here at the moment
            % - handled in addEyeData2
    end
    
    % Add eye data
    [a.stimLog, gaze] = ...
        InitialAnalysis.addEyeData2(a.stimLog, ...
        obj.eye.(['s', num2str(e)]), ...
        a.params, ...
        eyePlot, ...
        print);
    if eyePlot
        title(['Subject ', num2str(e)]);
        xlabel('Time')
        ylabel('On target prop.')
    end
    
    % All subjects
    % Add a "correct" and "error" columns
    for r = 1:n
        a.stimLog.ACorrect(r,1) = ...
            all(a.stimLog.respBinAN{r,1}(1,:) ...
            ==  a.stimLog.PosBinLog{r,1}(1,:));
        a.stimLog.VCorrect(r,1) = ...
            all(a.stimLog.respBinAN{r,1}(2,:) ...
            ==  a.stimLog.PosBinLog{r,1}(2,:));
        
        a.stimLog.AError(r,1) = ...
            (find(a.stimLog.respBinAN{r,1}(1,:)) ...
            - find(a.stimLog.PosBinLog{r,1}(1,:))) * 15;
        a.stimLog.VError(r,1) = ...
            (find(a.stimLog.respBinAN{r,1}(2,:)) ...
            - find(a.stimLog.PosBinLog{r,1}(2,:))) * 15;
    end
    
    % Add subject number
    a.stimLog.Subject = repmat(e, n, 1);
    
    % Save subject data in structre and append to allData table
    data.(['s', num2str(e)]) = a.stimLog;
    gazeData.(['s', num2str(e)]) = gaze;
    allData = [allData; a.stimLog]; %#ok<AGROW>
    
    clear a gaze
end

% Back up imported data
obj.expDataS = data;
obj.expDataAll = allData;
obj.eyeDataS = gazeData;
