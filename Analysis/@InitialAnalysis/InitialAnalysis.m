classdef InitialAnalysis < ggraph
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
        
        function obj = applyGazeThresh(obj, print)
            
            if ~exist('print', 'var')
                print = true;
            end
            
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
                    InitialAnalysis.eyeIndex(data.(fieldName), ...
                    osp, thresh1, thresh2);
                
                dataFilt.(fieldName) = ...
                    data.(fieldName)(data.(fieldName).onSurf,:);
                
                % Lazy
                allOK = [allOK; data.(fieldName).onSurf]; %#ok<AGROW>
                
                if print
                    disp('----')
                    disp(fieldName)
                    disp(rs1)
                    disp(rs2)
                    disp('----')
                end
            end
            
            allData.onSurf = allOK;
            
            % Continue with data passing thresh only
            obj.expDataS = dataFilt;
            obj.expDataAll = allData(allData.onSurf==1,:);
        end
    end
    
    methods (Static)
        [stimLog, gaze] = ...
            addEyeData2(stimLog, eyePath, params, plotOn, print)
        
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
        
        [tb, nR] = loadGaze2(fn, fields)
        
        [tb, nR] = loadGaze(fn, fields)
        
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
        
        h = plotMidHist(dataA, dataV, tit, absX, normX, normY)
        
        plotRespHist(data, fold, tit)
        
        h = plotSpatialData(stats, tit)
        
        h = plotSpatialDataOldMATLAB(stats, tit)
        
        replayComparison(gaze1, onSurf1, params1, gaze2, onSurf2, params2)
        
        h = replayGaze(gaze, onSurfIdx, targetFunc, targetIns, lag, speed)
        
        replotRaw(data, tit)
        
    end
    
end