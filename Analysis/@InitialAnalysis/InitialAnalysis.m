classdef InitialAnalysis
    % Functions from initial analysis including import with corrections,
    % older version of eye data import
    
    properties
        eye % Eye data paths
        exp % Experimental data paths
        expN % Number of experiements
        expDataAll % Exp data in one table
        expDataS % Exp data in fields divided by subject
        eyeDataS % Eye data in fields divided by subject
    end
    
    methods
        
        function obj = InitialAnalysis()
            
        end
        
        function obj = setPaths(obj, path)
            
            % Data\ is in directory above.
            dPath = [fileparts(path), '\Data\'];
            
            % Historical list of exps - add new to end. Will be reassigned numbers in
            % processing.
            % Paths can be changed here
            s = 1;
            ex.(['s', num2str(s)]) = ... 1
                [dPath, 'Nicole\07-Apr-2016 16_24_11\SpatialCapture_Nicole.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 2
                [dPath, 'Gareth\21-Apr-2016 15_56_01\SpatialCapture_Gareth.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 3
                [dPath, '2\26-Apr-2016 17_04_28\SpatialCapture_2.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 4
                [dPath, '4.2\08-Jul-2016 12_45_35\SpatialCapture_4.2.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 5
                [dPath, '5.2\08-Jul-2016 15_03_32\SpatialCapture_5.2.mat'];...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 6
                [dPath, '6.1\08-Jul-2016 16_19_28\SpatialCapture_6.1.mat'];...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 7
                [dPath, 'GarethEye\21-Feb-2017 15_53_30\SpatialCapture_GarethEye.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 8
                [dPath, 'ShriyaEye2\03-Mar-2017 14_55_20\SpatialCapture_ShriyaEye2.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 9
                [dPath, 'KatEye1\15-Mar-2017 12_32_08\SpatialCapture_KatEye1_backup.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 10
                [dPath, 'GarethEye3\22-Mar-2017 11_04_38\SpatialCapture_GarethEye3.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 11
                [dPath, '11XY\05-Apr-2017 09_57_28\SpatialCapture_11XY.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 12
                [dPath, '12NB\05-Apr-2017 14_53_36\SpatialCapture_12NB.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 13
                [dPath, '13SR\06-Apr-2017 15_20_21\SpatialCapture_13SR.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 14
                [dPath, '14JD\07-Apr-2017 10_11_53\SpatialCapture_14JD.mat']; ...
                s=s+1;
            ex.(['s', num2str(s)]) = ... 15
                [dPath, '15SI\07-Apr-2017 16_08_46\SpatialCapture_15SI.mat']; ...
                s=s+1;
            % Corresponding list of eyedata paths
            s = 1;
            ey.(['s', num2str(s)]) = ''; s=s+1; % 1
            ey.(['s', num2str(s)]) = ''; s=s+1; % 2
            ey.(['s', num2str(s)]) = ''; s=s+1; % 3
            ey.(['s', num2str(s)]) = ''; s=s+1; % 4
            ey.(['s', num2str(s)]) = ''; s=s+1; % 5
            ey.(['s', num2str(s)]) = ''; s=s+1; % 6
            ey.(['s', num2str(s)]) = ''; s=s+1; % 7, Recording, but time sync failed
            ey.(['s', num2str(s)]) = ... 8
                [dPath, 'ShriyaEye2\03-Mar-2017 14_55_20\ShriyaEye2.mat']; s=s+1;
            ey.(['s', num2str(s)]) = ... 9
                [dPath, 'KatEye1\15-Mar-2017 12_32_08\KatEye1.mat']; s=s+1;
            ey.(['s', num2str(s)]) = ... 10
                [dPath, 'GarethEye3\22-Mar-2017 11_04_38\GarethEye3.mat']; s=s+1;
            ey.(['s', num2str(s)]) = ''; s=s+1; % 11 processing
            ey.(['s', num2str(s)]) = ... 12
                [dPath, '12NB\05-Apr-2017 14_53_36\12NB.mat']; s=s+1;
            ey.(['s', num2str(s)]) = ... 13
                [dPath, '13SR\06-Apr-2017 15_20_21\13SR.mat']; s=s+1;
            ey.(['s', num2str(s)]) = ''; s=s+1; % 14 - space issues
            ey.(['s', num2str(s)]) = ... 15
                [dPath, '15SI\07-Apr-2017 16_08_46\15SI.mat']; s=s+1;
            
            obj.eye = ey;
            obj.exp = ex;
        end
        
        function obj = import(obj, debug)
            
            if ~exist('debug', 'var')
                debug = true;
            end
            
            eN = numel(fields(obj.exp));
            obj.expN = eN;
            
            allData = [];
            clear data
            for e = 1:eN
                % Get subject field
                fn = obj.exp.(['s', num2str(e)]);
                disp(['Loading ', fn])
                
                % Load psychophysics data
                a = load(fn);
                
                % Remove trials without responses
                % Using aStim field as it#s common to all versions and is populated on
                % response
                rmIdx = cellfun(@isempty, a.stimLog.aStim);
                a.stimLog = a.stimLog(~rmIdx,:);
                
                % Get number of available trials
                n = height(a.stimLog);
                disp(['Loaded ', num2str(n), ' trials'])
                
                % For all data, correct angle calculation from raw response
                newAngles = cellfun(@InitialAnalysis.calcAngle, ...
                    a.stimLog.RawResponse, ...
                    'UniformOutput', false);
                
                % And recalc diff angle
                da = cell2mat(a.stimLog.diffAngle);
                pos = mat2cell(a.stimLog.Position, ...
                    ones(height(a.stimLog),1), 2);
                newDiffAngles = cellfun(@InitialAnalysis.diffAngle, ...
                    pos, newAngles, ...
                    'UniformOutput', false);
                
                % And respBinAn
                newRespBinAn = cellfun(@InitialAnalysis.calcRespBinAn, ...
                    newAngles, ...
                    'UniformOutput', false);
                
                if debug % Debug plots
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
                
                plotOn = true;
                [a.stimLog, gaze] = ...
                    InitialAnalysis.addEyeData2(a.stimLog, ...
                    obj.eye.(['s', num2str(e)]), ...
                    a.params, ...
                    plotOn);
                title(['Subject ', num2str(e)]);
                xlabel('Time')
                ylabel('On target prop.')
                
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
            
            figure
            scatter(abs(allData.Position(:,1)), allData.AError)
            hold on
            scatter(abs(allData.Position(:,2)), allData.VError)
            legend({'Auditory', ' Visual'})
            xlabel('Position')
            ylabel('Error')
            
            % Back up imported data
            obj.expDataS = data;
            obj.expDataAll = allData;
            obj.eyeDataS = gazeData;
        end
        
        function obj = applyGazeThresh(obj)
            % Reset
            data = obj.expDataS;
            allData = obj.expDataAll;
            
            % Which onSurfProp to use?
            osp = 'onSurfProp';
            % Or
            % osp = 'onSurfPropCorrectedED'; - removed
            
            % Set thresh where there is eye data
            thresh1 = 0.75;
            % Set thresh where there isn't eye data -
            % true = include all,
            % false = discard all
            thresh2 = true;
            
            allOK = [];
            for e = 1:obj.expN
                fieldName = ['s', num2str(e)];
                
                [data.(fieldName).onSurf, rs1, rs2] = ...
                    InitialAnalysis.eyeIndex(data.(fieldName), osp, thresh1, thresh2);
                
                dataFilt.(fieldName) = ...
                    data.(fieldName)(data.(fieldName).onSurf,:);
                
                % Lazy
                allOK = [allOK; data.(fieldName).onSurf]; %#ok<AGROW>
                
                disp('----')
                disp(fieldName)
                disp(rs1)
                disp(rs2)
                disp('----')
            end
            
            allData.onSurf = allOK;
            
            % Continue with data passing thresh only
            obj.expDataS = dataFilt;
            obj.expDataAll = allData(allData.onSurf==1,:);
        end
    end
    
    methods (Static)
        [stimLog, gaze] = addEyeData2(stimLog, eyePath, params, plotOn)
        
        stimLog = addEyeData(stimLog, eyePath)
        
        bin = calcRespBinAn(angles)
        
        angle = calcAngle(xy)
        
        DA = diffAngle(pos, angles)
        
        [OK, rs1, rs2] = eyeIndex(data, osp, thresh1, thresh2)
        
        stats = fitGLM2(allData)
        
        stats = fitGLM3(allData)
        
        stats = fitGLM4(allData, normX, normY)
        
        stats = fitGLM5(allData)
        
        stats = fitGLMLinear(allData)
        
        [statsA, statsV] = gatherAccs(allData, fold, rel)
        
        [summary, data, posAx] = gatherAcrossSubjectAccuracy(stats)
        
        [st1, st2] = gatherAPCvsVL(stimLog, flag)
        
        stats = gatherCongProp(stimLog, flag, flag2)
        
        [dataA, dataV, pAx, dAx] = ...
            gatherDispHists(allData, rel, pInc)
        
        dataT = gatherGLMCoeffs(GLMStats, targets, note)
        
        [dataA, dataV] = gatherMidHist(allData)
        
        [statsA, statsV, uPos] = gatherPCHeatmaps(allData, fold)
        
        stats = gatherPosPlot1(stimLog, flag)
        
        gazeTrajectories(data, gazeData, tit, thresh, all, x)
        
        hgx(varargin)
        
        [tb, nR] = loadGaze2(fn, fields)
        
        [tb, nR] = loadGaze(fn, fields)
        
        handles = ng(template)
        
        plot180FFT(x, ts, tit)
        
        plotAccs(statsA, statsV, tit)
        
        [H1, H2] = ...
            plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit)
        
        [h1, h2] = plotAPCvsPL(data1, data2, str)
        
        plotBinnedRespHist(data, fold, tit)
        
        h = plotCongProp(stats, tit)
        
        plotDispHists(dataA, dataV, pAx, dAx, normX, normY, tit)
        
        plotGaze(NPs, idx, tit)
        
        h = plotHeatmaps(statsA, statsV, uPos, tit)
        
        plotMidHist(dataA, dataV, tit, absX, normX, normY)
        
        plotRespHist(data, fold, tit)
        
        h = plotSpatialData(stats, tit)
        
        h = plotSpatialDataOldMATLAB(stats, tit)
        
        replayComparison(gaze1, onSurf1, params1, gaze2, onSurf2, params2)
        
        h = replayGaze(gaze, onSurfIdx, targetFunc, targetIns, lag, speed)
        
        replotRaw(data, tit)
        
    end
    
end