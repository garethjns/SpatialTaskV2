classdef SpatialAnalysis < InitialAnalysis
    
    properties
        GLMs % Struct with various GLM fits
        stats % Struct with dumps of graph data
        statsSubsets % Struct withs stats done on subsets
        integrators % Struct with "integrators" by model
    end
    
    methods
        
        function obj = SpatialAnalysis()
        end
        
        function [obj, h] = accuracy(obj, plt, subs)
            % Calculate across-subject accuracy for specified subjects (or
            % all)
            % Note, for now, writes to and returns object - subsequent runs
            % replace stats for previous subset if overwriting calling
            % object.
            % Plot input should either be empty or contain logicals for
            % each plt - eg. [true, true, false, true]
            
            if isempty(plt)
                plt = [true, true, true, true];
            end
            h = gobjects(6, length(plt));
            
            % Default use all subjects
            if ~exist('subs', 'var')
                subs = unique(obj.expDataAll.Subject);
            end
            nSubs = numel(subs);
            
            % Calculate average accuracy for each subject (folded/unfolded,
            % rel/abs)
            for e = 1:nSubs
                
                s = subs(e);
                fieldName = ['s', num2str(s)];
                
                rel = false;
                fold = false;
                [statsAcAbs.(fieldName), ...
                    statsVcAbs.(fieldName)] = ...
                    obj.gatherAccs(obj.expDataS.(fieldName), fold, rel);
                
                rel = false;
                fold = true;
                [statsAcFoldAbs.(fieldName), ...
                    statsVcFoldAbs.(fieldName)] = ...
                    obj.gatherAccs(obj.expDataS.(fieldName), fold, rel);
                
                rel = true;
                fold = false;
                [statsAcRel.(fieldName), ...
                    statsVcRel.(fieldName)] = ...
                    obj.gatherAccs(obj.expDataS.(fieldName), fold, rel);
                
                rel = true;
                fold = true;
                [statsAcFoldRel.(fieldName), ...
                    statsVcFoldRel.(fieldName)] = ...
                    obj.gatherAccs(obj.expDataS.(fieldName), fold, rel);
            end
            
            % Save
            obj.stats.accuracy.AcAbs.data = statsAcAbs;
            obj.stats.accuracy.VcAbs.data = statsVcAbs;
            obj.stats.accuracy.AcFoldAbs.data = statsAcFoldAbs;
            obj.stats.accuracy.VcFoldAbs.data = statsVcFoldAbs;
            obj.stats.accuracy.AcRel.data = statsAcRel;
            obj.stats.accuracy.VcRel.data = statsVcRel;
            obj.stats.accuracy.AcFoldRel.data = statsAcFoldRel;
            obj.stats.accuracy.VcFoldRel.data = statsVcFoldRel;
            
            % Get data for stats
            % Cong vs abs incong for unfolded
            % Cong vs rel ingong for folded
            
            %% Cong vs abs incong for unfolded
            
            % Get vars and create temp table
            vars = {obj.expDataAll.ACorrect, 'ACorrect'; ...
                obj.expDataAll.Position(:,1), 'aPos'; ...
                obj.expDataAll.nEvents, 'Rate'; ...
                obj.expDataAll.Diff == 0, 'Cong';
                obj.expDataAll.Subject, 'Sub'};
            t = table(vars{:,1}, 'VariableNames', vars(:,2));
            % Run group stats
            summaryStatsA = grpstats(t, {'Sub', 'Cong', 'aPos', 'Rate'});
            
            % Do same for visual response
            vars = {obj.expDataAll.VCorrect, 'VCorrect'; ...
                obj.expDataAll.Position(:,2), 'vPos'; ...
                obj.expDataAll.nEvents, 'Rate'; ...
                obj.expDataAll.Diff == 0, 'Cong';
                obj.expDataAll.Subject, 'Sub'};
            t = table(vars{:,1}, 'VariableNames', vars(:,2));
            summaryStatsV = grpstats(t, {'Sub', 'Cong', 'vPos', 'Rate'});
            
            
            %% Cong vs rel incong for folded
            
            % Recalc diff first
            diffAV = 0-(abs(obj.expDataAll.Position(:,1)) - ...
                abs(obj.expDataAll.Position(:,2)));
            % Then trinary congruence
            cong = diffAV;
            cong(cong<0) = -1;
            cong(cong==0) = 0;
            cong(cong>0) = 1;
            
            % Limit positions to exclude those with only one direction of
            % disparity (on A position)
            idx = (abs(obj.expDataAll.Position(:,1))>7.5) ...
                & (abs(obj.expDataAll.Position(:,1))<67.5);
            
            % Then create temp table using limited set
            % And using relative triany congruence
            vars = {obj.expDataAll.ACorrect(idx,1), 'ACorrect'; ...
                obj.expDataAll.Position(idx,1), 'aPos'; ...
                obj.expDataAll.nEvents(idx,1), 'Rate'; ...
                cong(idx,1), 'Cong';
                obj.expDataAll.Subject(idx,1), 'Sub'};
            t = table(vars{:,1}, 'VariableNames', vars(:,2));
            
            summaryStatsFoldedA = ...
                grpstats(t, {'Sub', 'Cong', 'aPos', 'Rate'});
            
            % Same for visual response
            % Diff is the other way round
            diffVA = 0-(abs(obj.expDataAll.Position(:,2)) - ...
                abs(obj.expDataAll.Position(:,1)));
            % So is congruence
            cong = diffVA;
            cong(cong<0) = -1;
            cong(cong==0) = 0;
            cong(cong>0) = 1;
            
            % Index set around visual location
            idx = (abs(obj.expDataAll.Position(:,2))>7.5) ...
                & (abs(obj.expDataAll.Position(:,2))<67.5);
            
            vars = {obj.expDataAll.VCorrect(idx,1), 'VCorrect'; ...
                obj.expDataAll.Position(idx,2), 'vPos'; ...
                obj.expDataAll.nEvents(idx,1), 'Rate'; ...
                cong(idx,1), 'Cong';
                obj.expDataAll.Subject(idx,1), 'Sub'};
            t = table(vars{:,1}, 'VariableNames', vars(:,2));
            
            summaryStatsFoldedV = ...
                grpstats(t, {'Sub', 'Cong', 'vPos', 'Rate'});
            
            %% Plot unfolded, abs (with stats)
            
            tit = 'Response accuracy - unfold, abs, across subs';
            [summaryA, ~, posAx] = ...
                obj.gatherAcrossSubjectAccuracy(statsAcAbs);
            [summaryV, ~, ~] = ...
                obj.gatherAcrossSubjectAccuracy(statsVcAbs);
            if plt(1)
                h(1:2,1) = obj.plotAcrossSubjectAccuracy(summaryA, ...
                    summaryV, posAx, tit);
            end
            % A stats
            [p, tbl, st] = ...
                anovan(summaryStatsA.mean_ACorrect, ...
                {summaryStatsA.Cong, ...
                summaryStatsA.aPos, ...
                summaryStatsA.Rate}, ...
                'model', 'interaction', ...
                'varname', {'cong', 'aPos', 'Rate'});
            % Compare on rate
            if plt(1)
                h(3,1) = figure;
                multcompare(st, 'Dimension', 3);
                % Compare on cong
                h(4,1) = figure;
                multcompare(st, 'Dimension', 1);
            end
            % Save
            obj.stats.accuracy.AcAbs.ANOVA.stats = st;
            obj.stats.accuracy.AcAbs.ANOVA.p = p;
            obj.stats.accuracy.AcAbs.ANOVA.tbl = tbl;
            
            % V stats
            [p, tbl, st] = ...
                anovan(summaryStatsV.mean_VCorrect, ...
                {summaryStatsV.Cong, ...
                summaryStatsV.vPos, ...
                summaryStatsV.Rate}, ...
                'model', 'interaction', ...
                'varname', {'cong', 'vPos', 'Rate'});
            
            % Save
            obj.stats.accuracy.VcAbs.ANOVA.stats = st;
            obj.stats.accuracy.VcAbs.ANOVA.p = p;
            obj.stats.accuracy.VcAbs.ANOVA.tbl = tbl;
            
            % Compare on rate
            if plt(1)
                h(5,1) = figure;
                multcompare(st, 'Dimension', 3);
                % Compare on cong
                h(6,1) = figure;
                multcompare(st, 'Dimension', 1);
            end
            
            %% Plot unfolded, rel (no stats)
            tit = 'Response accuracy - unfold, rel, across subs';
            [summaryA, ~, posAx] = ...
                obj.gatherAcrossSubjectAccuracy(statsAcRel);
            [summaryV, ~, ~] = ...
                obj.gatherAcrossSubjectAccuracy(statsVcRel);
            if plt(2)
                h(1:2,2) = obj.plotAcrossSubjectAccuracy(summaryA, ...
                    summaryV, posAx, tit);
            end
            
            %% Plot folded, rel (stats)
            
            tit = 'Response accuracy - fold, rel, across subs';
            [summaryA, ~, posAx] = ...
                obj.gatherAcrossSubjectAccuracy(statsAcFoldRel);
            [summaryV, ~, ~] = ...
                obj.gatherAcrossSubjectAccuracy(statsVcFoldRel);
            if plt(3)
                h(1:2,3) = obj.plotAcrossSubjectAccuracy(summaryA, ...
                    summaryV, posAx, tit);
            end
            
            % A stats
            [p, tbl, st] = ...
                anovan(summaryStatsFoldedA.mean_ACorrect, ...
                {summaryStatsFoldedA.Cong, ...
                summaryStatsFoldedA.aPos, ...
                summaryStatsFoldedA.Rate}, ...
                'model', 'interaction', ...
                'varname', {'cong', 'aPos', 'Rate'});
            
            % Compare on cong
            if plt(3)
                h(3,3) = figure;
                multcompare(st, 'Dimension', 1);
                % Compare on cong vs pos
                h(4,3) = figure;
                multcompare(st, 'Dimension', [1, 2]);
            end
            
            % Save
            obj.stats.accuracy.AcFoldRel.ANOVA.stats = st;
            obj.stats.accuracy.AcFoldRel.ANOVA.p = p;
            obj.stats.accuracy.AcFoldRel.ANOVA.tbl = tbl;
            
            % V stats
            [p, tbl, st] = ...
                anovan(summaryStatsFoldedV.mean_VCorrect, ...
                {summaryStatsFoldedV.Cong, ...
                summaryStatsFoldedV.vPos, ...
                summaryStatsFoldedV.Rate}, ...
                'model', 'interaction', ...
                'varname', {'cong', 'vPos', 'Rate'});
            
            % Compare on cong
            if plt(3)
                h(5,3) = figure;
                multcompare(st, 'Dimension', 1);
                % Compare on cong vs pos
                h(6,3) = figure;
                multcompare(st, 'Dimension', [1, 2]);
            end
            
            % Save
            obj.stats.accuracy.VcFoldRel.ANOVA.stats = st;
            obj.stats.accuracy.VcFoldRel.ANOVA.p = p;
            obj.stats.accuracy.VcFoldRel.ANOVA.tbl = tbl;
            
            
            %% Plot folded, abs (no stats)
            tit = 'Response accuracy - fold, abs, across subs';
            [summaryA, ~, posAx] = ...
                obj.gatherAcrossSubjectAccuracy(statsAcFoldAbs);
            [summaryV, ~, ~] = ...
                obj.gatherAcrossSubjectAccuracy(statsVcFoldAbs);
            if plt(4)
                h(1:2,4) = obj.plotAcrossSubjectAccuracy(summaryA, ...
                    summaryV, posAx, tit);
            end
            
        end
        
        function [obj, h] = GLMNonLinearResp(obj)
            % AResp = a+ b*ALoc + c*Vloc + + d*ALoc*VLoc
            
            normX = false;
            normY = false;
            
            % For each subject
            h = figure;
            for e = 1:obj.expN
                fieldName = ['s', num2str(e)];
                
                % Get the data/stats for the plot:
                st = obj.fitGLM4(obj.expDataS.(fieldName), ...
                    normX, normY);
                
                GLMStats.(fieldName) = st;
                
                % Auditory
                % Add to plot
                aAx = subplot(1,2,1); hold on
                x = [1, 2, 3];
                mCol = [0.8, 0.2, 0.2];
                % Get coefs
                y = [st.AResp.Coefficients.Estimate(2), ...
                    st.AResp.Coefficients.Estimate(3), ...
                    st.AResp.Coefficients.Estimate(4)*100];
                % Get pValues
                p = [st.AResp.Coefficients.pValue(2), ...
                    st.AResp.Coefficients.pValue(3), ...
                    st.AResp.Coefficients.pValue(4)];
                % Plot all on line, coloured by visual significance
                if p(2)>0.05
                    lCol = [0.6, 0.6, 0.6];
                else
                    lCol = [0.3, 0.3, 0.8];
                end
                plot(x, y, 'LineStyle', '--', 'Color', lCol);
                % Scatter oon significant values
                scatter(x(p<0.05), y(p<0.05), ...
                    'MarkerFaceColor', mCol, ...
                    'MarkerEdgeColor', mCol);
                % Scatter on insignificant values
                scatter(x(p>0.05), y(p>0.05), ...
                    'MarkerEdgeColor', mCol);
                
                % Visual
                vAx = subplot(1,2,2); hold on
                y = [st.VResp.Coefficients.Estimate(2), ...
                    st.VResp.Coefficients.Estimate(3), ...
                    st.VResp.Coefficients.Estimate(4)*100];
                % Get pValues
                p = [st.VResp.Coefficients.pValue(2), ...
                    st.VResp.Coefficients.pValue(3), ...
                    st.VResp.Coefficients.pValue(4)];
                % Plot all on line, coloured by aud significance
                if p(1)>0.05
                    lCol = [0.6, 0.6, 0.6];
                else
                    lCol = [0.3, 0.3, 0.8];
                end
                plot(x, y, 'LineStyle', '--', 'Color', lCol);
                % Scatter oon significant values
                scatter(x(p<0.05), y(p<0.05), ...
                    'MarkerFaceColor', mCol, ...
                    'MarkerEdgeColor', mCol);
                % Scatter on insignificant values
                scatter(x(p>0.05), y(p>0.05), ...
                    'MarkerEdgeColor', mCol);
            end
            
            % Finish figure
            subplot(1,2,1)
            xlim([0, 4])
            % ylim([-0.5, 1])
            aAx.XTick = [1, 2, 3];
            aAx.XTickLabels = ...
                st.AResp.Coefficients.Properties.RowNames(2:4);
            aAx.XTickLabelRotation = 45;
            % aAx.YScale = 'log';
            ylabel('Magnitude')
            title('AResp = ALoc + Vloc + ALoc*VLoc')
            
            subplot(1,2,2)
            xlim([0, 4])
            % ylim([-0.5, 1])
            vAx.XTick = [1, 2, 3];
            vAx.XTickLabels = ...
                st.VResp.Coefficients.Properties.RowNames(2:4);
            vAx.XTickLabelRotation = 45;
            % vAx.YScale = 'log';
            title('VResp = ALoc + Vloc + ALoc*VLoc')
            
            obj.GLMs.NonLinearResp = GLMStats;
        end
        
        function [obj, h] = GLMNonLinearCor(obj)
            % AResp = a+ b*ALoc + c*Vloc + + d*ALoc*VLoc
            
            % For each subject
            h = figure;
            for e = 1:obj.expN
                fieldName = ['s', num2str(e)];
                
                % Get the data/stats for the plot:
                st = obj.fitGLM2(obj.expDataS.(fieldName));
                
                GLMStats.(fieldName) = st;
                
                % Auditory
                % Add to plot
                aAx = subplot(1,2,1); hold on
                x = [1, 2, 3];
                mCol = [0.8, 0.2, 0.2];
                % Get coefs
                y = [st.ACorr.Coefficients.Estimate(2), ...
                    st.ACorr.Coefficients.Estimate(3), ...
                    st.ACorr.Coefficients.Estimate(4)*100];
                % Get pValues
                p = [st.ACorr.Coefficients.pValue(2), ...
                    st.ACorr.Coefficients.pValue(3), ...
                    st.ACorr.Coefficients.pValue(4)];
                % Plot all on line, coloured by visual significance
                if p(2)>0.05
                    lCol = [0.6, 0.6, 0.6];
                else
                    lCol = [0.3, 0.3, 0.8];
                end
                plot(x, y, 'LineStyle', '--', 'Color', lCol);
                % Scatter oon significant values
                scatter(x(p<0.05), y(p<0.05), ...
                    'MarkerFaceColor', mCol, ...
                    'MarkerEdgeColor', mCol);
                % Scatter on insignificant values
                scatter(x(p>0.05), y(p>0.05), ...
                    'MarkerEdgeColor', mCol);
                
                % Visual
                vAx = subplot(1,2,2); hold on
                y = [st.VCorr.Coefficients.Estimate(2), ...
                    st.VCorr.Coefficients.Estimate(3), ...
                    st.VCorr.Coefficients.Estimate(4)*100];
                % Get pValues
                p = [st.VCorr.Coefficients.pValue(2), ...
                    st.VCorr.Coefficients.pValue(3), ...
                    st.VCorr.Coefficients.pValue(4)];
                % Plot all on line, coloured by aud significance
                if p(1)>0.05
                    lCol = [0.6, 0.6, 0.6];
                else
                    lCol = [0.3, 0.3, 0.8];
                end
                plot(x, y, 'LineStyle', '--', 'Color', lCol);
                % Scatter oon significant values
                scatter(x(p<0.05), y(p<0.05), ...
                    'MarkerFaceColor', mCol, ...
                    'MarkerEdgeColor', mCol);
                % Scatter on insignificant values
                scatter(x(p>0.05), y(p>0.05), ...
                    'MarkerEdgeColor', mCol);
            end
            
            % Finish figure
            subplot(1,2,1)
            xlim([0, 4])
            % ylim([-0.2, 0.3])
            aAx.XTick = [1, 2, 3];
            aAx.XTickLabels = ...
                st.ACorr.Coefficients.Properties.RowNames(2:4);
            aAx.XTickLabelRotation = 45;
            ylabel('Magnitude')
            title('ACorr = ALoc + Vloc + ALoc*VLoc')
            
            subplot(1,2,2)
            xlim([0, 4])
            % ylim([-0.2, 0.3])
            vAx.XTick = [1, 2, 3];
            vAx.XTickLabels = ...
                st.VCorr.Coefficients.Properties.RowNames(2:4);
            vAx.XTickLabelRotation = 45;
            title('VCorr = ALoc + Vloc + ALoc*VLoc')
            
            obj.GLMs.NonLinearCorr = GLMStats;
        end
        
        function obj = findIntegrators(obj, mn, thresh)
            % Look through available subject fits and tabulate pValues (and
            % logical based on thresh):
            % A_Ar: Uses A in A response (not really needed)
            % V_Ar: Uses V in A response
            % AV_Ar: Uses AV in A reponse
            % A_Vr: Uses A in V response
            % V_Vr: Uses V in V response (not really needed)
            % AV_Vr: Uses AV in V reponse
            %
            % Then create following logicals:
            % Ar_useV: V used for aud resp - semi
            % Ar_useAV: AV used for aud resp - semi
            % Ar_useVAV: V or AV used in aud resp - full
            % Vr_useA: A Used for vis resp - semi
            % Vr_useAV: AV used for vis resp - sem
            % Vr_useAAV: A or AV used for vis resp - full
            % AVr_useVAVAAV: (A or AV used in V) and (V or AV used in A resp) 
            
            % Set significance threshold if not specified
            if ~exist('thresh', 'var')
                thresh = 0.05;
            end
            
            % Get the selected model to use
            [mn, mfn, mod] = obj.setMod(mn);
            
            fns = fieldnames(mod);
            nSubs = length(fns);
            
            % For each subject, mark A int, V int, AV inte
            vars = {(1:nSubs)', 'Subject', 'Subject number'; ...
                NaN(nSubs,1), 'cA_Ar', 'Val: A stim to A resp'; ...
                NaN(nSubs,1), 'cV_Ar', 'Val: V stim to A resp'; ...
                NaN(nSubs,1), 'cAV_Ar', 'Val: AV inter to A resp'; ...
                NaN(nSubs,1), 'cA_Vr', 'Val: A stim to V resp'; ...
                NaN(nSubs,1), 'cV_Vr', 'Val: V stim to V resp'; ...
                NaN(nSubs,1), 'cAV_Vr', 'Val: AV inter to A resp'; ...
                NaN(nSubs,1), 'pA_Ar', 'Sig: A stim to A resp'; ...
                NaN(nSubs,1), 'pV_Ar', 'Sig: V stim to A resp'; ...
                NaN(nSubs,1), 'pAV_Ar', 'Sig: AV inter to A resp'; ...
                NaN(nSubs,1), 'pA_Vr', 'Sig: A stim to V resp'; ...
                NaN(nSubs,1), 'pV_Vr', 'Sig: V stim to V resp'; ...
                NaN(nSubs,1), 'pAV_Vr', 'Sig: AV inter to V resp'; ...
                NaN(nSubs,1), 'rA_A_Ar', 'Ratio:  cA_Ar  to cA_Ar (==)'; ...
                NaN(nSubs,1), 'rV_A_Ar', 'Ratio: cV_Ar  to cA_Ar'; ...
                NaN(nSubs,1), 'rAV_A_Ar', 'Ratio: cVA_Ar to cA_Ar'; ...
                NaN(nSubs,1), 'rA_V_Vr', 'Ratio:  cA_Vr  to cV_Vr'; ...
                NaN(nSubs,1), 'rV_V_Vr', 'Ratio:  cV_Vr  to cV_Vr (==)'; ...
                NaN(nSubs,1), 'rAV_V_Vr', 'Ratio: cAV_Vr to cV_Vr'; ...
                NaN(nSubs,1), 'A_Ar', 'Uses A in A response'; ...
                NaN(nSubs,1), 'V_Ar', 'Uses V in A response'; ...
                NaN(nSubs,1), 'AV_Ar', 'Uses AV in A reponse'; ...
                NaN(nSubs,1), 'A_Vr', 'Uses A in V response'; ...
                NaN(nSubs,1), 'V_Vr', 'Uses V in V response'; ...
                NaN(nSubs,1), 'AV_Vr', 'Uses AV in V reponse'; ...
                NaN(nSubs,1), 'Ar_useV', 'V used for aud resp'; ...
                NaN(nSubs,1), 'Ar_useAV', 'AV used for aud resp'; ...
                NaN(nSubs,1), 'Ar_useVAV', 'V or AV used for aud resp'; ...
                NaN(nSubs,1), 'Vr_useA', 'A Used for vis resp '; ...
                NaN(nSubs,1), 'Vr_useAV', 'AV used for vis respr'; ...
                NaN(nSubs,1), 'Vr_useAAV', 'A or AV used for vis resp'; ...
                NaN(nSubs,1), 'AVr_useVAVAAV', 'Vr_useAAV & Ar_useVAV'};
            
            t = table(vars{:,1}, ...
                'VariableNames', vars(:,2));
            t.Properties.VariableDescriptions = vars(:,3);
            
            for s = 1:nSubs
                
                sIdx = t.Subject==s;
                t.cA_Ar(sIdx) = ...
                    mod.(fns{s}).(['A', mfn]).Coefficients.Estimate(2);
                t.cV_Ar(sIdx) = ...
                    mod.(fns{s}).(['A', mfn]).Coefficients.Estimate(3);
                t.cAV_Ar(sIdx) = ...
                    mod.(fns{s}).(['A', mfn]).Coefficients.Estimate(4);
                t.pA_Ar(sIdx) = ...
                    mod.(fns{s}).(['A', mfn]).Coefficients.pValue(2);
                t.pV_Ar(sIdx) = ...
                    mod.(fns{s}).(['A', mfn]).Coefficients.pValue(3);
                t.pAV_Ar(sIdx) = ...
                    mod.(fns{s}).(['A', mfn]).Coefficients.pValue(4);
                
                t.cA_Vr(sIdx) = ...
                    mod.(fns{s}).(['V', mfn]).Coefficients.Estimate(2);
                t.cV_Vr(sIdx) = ...
                    mod.(fns{s}).(['V', mfn]).Coefficients.Estimate(3);
                t.cAV_Vr(sIdx) = ...
                    mod.(fns{s}).(['V', mfn]).Coefficients.Estimate(4);
                t.pA_Vr(sIdx) = ...
                    mod.(fns{s}).(['V', mfn]).Coefficients.pValue(2);
                t.pV_Vr(sIdx) = ...
                    mod.(fns{s}).(['V', mfn]).Coefficients.pValue(3);
                t.pAV_Vr(sIdx) = ...
                    mod.(fns{s}).(['V', mfn]).Coefficients.pValue(4);
                
            end
            
            % Simple logicals
            t.A_Ar = t.pA_Ar < thresh;
            t.V_Ar = t.pV_Ar < thresh;
            t.AV_Ar = t.pAV_Ar < thresh;
            t.A_Vr = t.pA_Vr < thresh;
            t.V_Vr = t.pV_Vr < thresh;
            t.AV_Vr = t.pAV_Vr < thresh;
            
            % Simple integrator definitions
            t.Ar_useV = t.V_Ar;
            t.Vr_useA = t.A_Vr;
            t.Ar_useAV = t.AV_Ar;
            t.Vr_useAV = t.AV_Vr;
            
            % More complex integrator definitions
            t.Ar_useVAV = t.V_Ar | t.AV_Ar; % 
            t.Vr_useAAV = t.A_Vr | t.AV_Vr;
            t.AVr_useVAVAAV = t.Ar_useVAV & t.Vr_useAAV;
            
            % Calculate ratios
            t.rA_A_Ar = t.cA_Ar   ./ t.cA_Ar;
            t.rV_A_Ar = t.cV_Ar   ./ t.cA_Ar;
            t.rAV_A_Ar = t.cAV_Ar ./ t.cA_Ar;
            t.rA_V_Vr = t.cA_Vr   ./ t.cV_Vr;
            t.rV_V_Vr = t.cV_Vr   ./ t.cV_Vr;
            t.rAV_V_Vr = t.cAV_Vr ./ t.cV_Vr;
            
            % Save table
            obj.integrators.(mn) = t;
            
        end
        
        function [obj, h] = congruence(obj, plt, subs)
            % Parameters are fixed here:
            % rel:
            % Relative (2) or absolute (1) disparity where everything is
            % anchored to V location. -15 means A 15 degrees back
            % towards midline.
            % Both done.
            %
            % pec:
            % Second input to gaterCongProp. Controls wheher to use
            % actual or marked location of visual stim as comparison
            % for congruence judgement.
            % 1 = Use actual location: Compares A response against
            % actual V location, even if V response was elsewhere. Can
            % indicate congruenet judgement if responses in different
            % locations.
            % 2 = Use response location. Ie. Congruent judgement if
            % subject response A==V, even if actual location of A or V
            % was elsewhere. Ignores localistaion errors.
            % Just using pec = 2.
            %
            % Output to obj.stats.congruence.[abs, rel]
            
            if isempty(plt)
                plt = [true, true];
            end
            h = gobjects(1, length(plt));
                        
            if ~exist('subs', 'var')
                subs = 1:obj.expN;
            end
            nSubs = numel(subs);
            
            pec = 2;
            for e = 1:nSubs
                s = subs(e);
                fieldName = ['s', num2str(s)];
                
                rel = 2;
                obj.stats.congruence.rel.(fieldName) = ...
                    obj.gatherCongProp(obj.expDataS.(fieldName), rel, pec);
                
                rel = 1;
                obj.stats.congruence.abs.(fieldName) = ...
                    obj.gatherCongProp(obj.expDataS.(fieldName), rel, pec);
            end
            
            % Calculate across subject averages and plot
            % Take averages (code from initialAnalysis)
            statsP3Av_tmp = NaN(6, 6, 5, obj.expN);
            statsP4Av_tmp = NaN(6, 10, 5, obj.expN);
            statsP3Av = NaN(6, 6, 5);
            statsP4Av = NaN(6, 10, 5);
            for e = 1:nSubs
                s = subs(e);
                fieldName = ['s', num2str(s)];
                
                if ~isempty(obj.stats.congruence.abs.(fieldName))
                    statsP3Av_tmp(:,:,:,e) = ...
                        obj.stats.congruence.abs.(fieldName);
                    statsP4Av_tmp(:,:,:,e) = ...
                        obj.stats.congruence.rel.(fieldName);
                end
            end
            % Dims: (stat, diffs at this pos, pos(of other stim), (sub))
            % st(1,1) = pos;
            % st(2,1) = dif;
            % st(3,1) = congProp;
            % st(4,1) = std(congLog);
            % st(5,1) = sum(congLog);
            % st(6,1) = numel(data);
            
            % Copy pos from one subject
            statsP3Av(1,:,:) = statsP3Av_tmp(1,:,:,1);
            statsP4Av(1,:,:) = statsP4Av_tmp(1,:,:,1);
            % Copy diffs from one subject
            statsP3Av(2,:,:) = statsP3Av_tmp(2,:,:,2);
            statsP4Av(2,:,:) = statsP4Av_tmp(2,:,:,2);
            % Take mean congProp across subjects
            statsP3Av(3,:,:) = nanmean(statsP3Av_tmp(3,:,:,:), 4);
            statsP4Av(3,:,:) = nanmean(statsP4Av_tmp(3,:,:,:), 4);
            % Recalculate std
            statsP3Av(4,:,:) = nanstd(statsP3Av_tmp(3,:,:,:), 0, 4);
            statsP4Av(4,:,:) = nanstd(statsP4Av_tmp(3,:,:,:), 0, 4);
            % Sum across sum of congLog
            statsP3Av(5,:,:) = sum(statsP3Av_tmp(5,:,:,:), 4);
            statsP4Av(5,:,:) = sum(statsP4Av_tmp(5,:,:,:), 4);
            % Replace n with exp.expN
            statsP3Av(6,:,:) = obj.expN;
            statsP4Av(6,:,:) = obj.expN;
            
            % Save
            obj.stats.congruence.absAV = statsP3Av;
            obj.stats.congruence.relAV = statsP4Av;
            
            % Plot
            if plt(1)
                tit = ['Avg: Proportion congruent responses,',...
                    'abs diff between A and V'];
                h(1) = obj.plotCongProp(statsP3Av, tit);
                
            end
            if plt(2)
                tit = ['Avg: Proportion congruent responses,', ...
                    'relative diff between A and V'];
                h(2) = obj.plotCongProp(statsP4Av, tit);
            end
        end
        
        function dispIntergrators(obj, mn)
            % Plot table of integrations for model mn
            % Plot imagesc of logicals
            % Box plot ratios for each group

            % Get the selected model (name) to use
            [mn, ~, ~] = obj.setMod(mn);
            
            % Get table (rather than model)
            t = obj.integrators.(mn);
            
            % Set columns to use
            colsAr = {'Ar_useV', 'Ar_useAV', 'Ar_useVAV'};
            colsVr = {'Vr_useA', 'Vr_useAV', 'Vr_useAAV'};
            colsAVr = {'AVr_useVAVAAV'};
            
            % Print
            disp(t(:, ['Subject', colsAr, colsVr, colsAVr]))
            
            %% Imacesc logicals
            
            figure
            ax = subplot(1,7,1:3);
            imagesc(t{:,colsAr})
            ax.YTick = 1:15;
            ax.XTick = 1:3;
            ax.XMinorTick = 'on';
            ax.XRuler.MinorTickValues = 0.5:2.5;
            ax.YRuler.MinorTickValues = 0.5:14.5;
            ax.XTickLabel = colsAr;
            ax.XTickLabelRotation = 45;
            ylabel('Subject')
            title('Aud resp.')
            
            ax = subplot(1,7,4:6);
            imagesc(t{:,colsVr})
            ax.YTick = 1:15;
            ax.XTick = 1:3;
            ax.XMinorTick = 'on';
            ax.XRuler.MinorTickValues = 0.5:2.5;
            ax.YRuler.MinorTickValues = 0.5:14.5;
            ax.XTickLabelRotation = 45;
            title('Vis resp.')
            
            ax = subplot(1,7,7);
            imagesc(t{:,colsAVr})
            ax.YTick = 1:15;
            ax.XTick = 1;
            ax.XMinorTick = 'on';
            ax.XRuler.MinorTickValues = 0.5:2.5;
            ax.YRuler.MinorTickValues = 0.5:14.5;
            ax.XTickLabel = colsAVr;
            ax.XTickLabelRotation = 45;
            title('AV resp.')
            
            SpatialAnalysis.ng('GridMinor');
            
            
            %% Ratio boxplots
            
            % Aud resp
            figure
            subplot(1,2,1)
            boxplot(t.rV_A_Ar, t.Ar_useVAV)
            hold on
            scatter(ones(sum(~t.Ar_useVAV),1), t.rV_A_Ar(~t.Ar_useVAV), ...
                'MarkerEdgeColor', [0.8, 0.2, 0.2])
            scatter(ones(sum(t.Ar_useVAV),1)+1, t.rV_A_Ar(t.Ar_useVAV), ...
                'MarkerEdgeColor', [0.8, 0.2, 0.2], ...
                'MarkerFaceColor', [0.8, 0.2, 0.2])
            
            title('Ratio: cV to cA')
            subplot(1,2,2)
            boxplot(t.rAV_A_Ar, t.Ar_useVAV)
            hold on
            scatter(ones(sum(~t.Ar_useVAV),1), t.rAV_A_Ar(~t.Ar_useVAV), ...
                'MarkerEdgeColor', [0.8, 0.2, 0.2])
            scatter(ones(sum(t.Ar_useVAV),1)+1, t.rAV_A_Ar(t.Ar_useVAV), ...
                'MarkerEdgeColor', [0.8, 0.2, 0.2], ...
                'MarkerFaceColor', [0.8, 0.2, 0.2])
            title('Ratio: cAV to cA')
            suptitle('Auditory response')
            xlabel('Significant other-modality')
            
            % Vis resp
            figure
            subplot(1,2,1)
            boxplot(t.rA_V_Vr, t.Vr_useAAV)
            hold on
            scatter(ones(sum(~t.Vr_useAAV),1), t.rA_V_Vr(~t.Vr_useAAV), ...
                'MarkerEdgeColor', [0.8, 0.2, 0.2])
            scatter(ones(sum(t.Vr_useAAV),1)+1, t.rA_V_Vr(t.Vr_useAAV), ...
                'MarkerEdgeColor', [0.8, 0.2, 0.2], ...
                'MarkerFaceColor', [0.8, 0.2, 0.2])
            title('Ratio: cA to cV')
            subplot(1,2,2)
            boxplot(t.rAV_V_Vr, t.Vr_useAAV)
            hold on
            hold on
            scatter(ones(sum(~t.Vr_useAAV),1), t.rAV_V_Vr(~t.Vr_useAAV), ...
                'MarkerEdgeColor', [0.8, 0.2, 0.2])
            scatter(ones(sum(t.Vr_useAAV),1)+1, t.rAV_V_Vr(t.Vr_useAAV), ...
                'MarkerEdgeColor', [0.8, 0.2, 0.2], ...
                'MarkerFaceColor', [0.8, 0.2, 0.2])
            title('Ratio: cAV to cV')
            suptitle('Visual response')
            xlabel('Significant other-modality')
            
            
        end
        
        function [mn, mfn, mod] = setMod(obj, mn)
            switch mn
                case {'NLC', 'NonLinearCorr'}
                    mn = 'NonLinearCorr';
                    mfn = 'Corr';
                    mod = obj.GLMs.NonLinearCorr;
                case {'NLR', 'NonLinearResp'}
                    mn = 'NonLinearResp';
                    mfn = 'Resp';
                    mod = obj.GLMs.NonLinearResp;
                otherwise
                    disp('Invalid model.')
                    return
            end
            
        end
        
        function plotSingleSubjectSummary(obj, s, accFold, ...
                accRel, congRel, midErrorRel)
            % Plot the accuray, congruence judgement, midHist for one
            % subject
            % Doesn't do stats, error bars are within-subject
            % Use .accuracy etc with restricted subsets to do
            % across-subject stats.
            
            % Set subject fieldname
            sub = ['s', num2str(s)];
            
            
            %% Accuracy plot
            % Options
            if ~exist('accRel', 'var') || isempty(accRel)
                accRel = true;
            end
            if ~exist('accFold', 'var') || isempty(accFold)
                accFold = true;
            end
            
            % Plot
            if accFold && accRel
                tit = ['S', num2str(s), ...
                    ': Response accuracy - Rel'];
                statsA = obj.stats.accuracy.AcFoldRel.data.(sub);
                statsV = obj.stats.accuracy.VcFoldRel.data.(sub);
                obj.plotAccs(statsA, statsV, tit)
            elseif accFold && ~accRel
                tit = ['S', num2str(s), ...
                    ': Response accuracy - Abs'];
                statsA = obj.stats.accuracy.AcFoldAbs.data.(sub);
                statsV = obj.stats.accuracy.VcFoldAbs.data.(sub);
                obj.plotAccs(statsA, statsV, tit)
            elseif ~accFold && accRel
                tit = ['S', num2str(s), ...
                    ': Response accuracy - Rel'];
                statsA = obj.stats.accuracy.AcRel.data.(sub);
                statsV = obj.stats.accuracy.VcRel.data.(sub);
                obj.plotAccs(statsA, statsV, tit)
            elseif ~accFold && ~accRel
                tit = ['S', num2str(s), ...
                    ': Response accuracy - Abs'];
                statsA = obj.stats.accuracy.AcAbs.data.(sub);
                statsV = obj.stats.accuracy.VcAbs.data.(sub);
                obj.plotAccs(statsA, statsV, tit)
            end

            
            %% Congruence judgement plot
            
            if ~exist('congRel', 'var') || isempty(congRel)
                congRel = true;
            end
            
            if congRel
                st = obj.stats.congruence.rel.(sub);
                tit = ['S', num2str(s), ...
                ': Proportion congruent responses,' ... 
                 'relative diff between V and A'];
            else
                st = obj.stats.congruence.abs.(sub);
                tit = ['S', num2str(s), ...
                ': Proportion congruent responses,' ... 
                 'abs diff between V and A'];
            end
            
            
            %% MidError plot
            
            if ~exist('midErrorRel', 'var') || isempty(midErrorRel)
                midErrorRel = true;
            end
            
            obj.plotCongProp(st, tit);
            A = obj.stats.midError.(sub).A;
            V = obj.stats.midError.(sub).V;
            
            if midErrorRel
                abs = false;
            else
                abs = true;
            end
            
            abs = false;
            tit = 'All subjects, xNorm, yNorm';
            obj.plotMidHist(A, V, tit, abs);
            SpatialAnalysis.ng('1024NE');
            
            abs = true;
            tit = 'All subjects, xNorm, yNorm';
            obj.plotMidHist(A, V, tit, abs);
            SpatialAnalysis.ng('1024NE');
            
            
        end
        
        function [obj, h] = midError(obj, plt, subs)
            % Plt is [(rel, yNorm), rel, abs].
            % Runs per sub and saves stats.
            % Runs on all data (using all subs or subset) and calculates
            % error from this (rather than doing across-subject average).
            
            if isempty(plt)
                plt = [true, true, true];
            end
            h = gobjects(1, length(plt));
            
            if ~exist('subs', 'var')
                subs = unique(obj.expDataAll.Subject);
            end
            nSubs = numel(subs);
            
            for e = 1:nSubs
                
                s = subs(e);
                fieldName = ['s', num2str(s)];
                
                % Get data
                
                [A, V] = ...
                    obj.gatherMidHist(obj.expDataS.(fieldName));
                
                obj.stats.midError.(fieldName).A = A;
                obj.stats.midError.(fieldName).V = V;
            end
            
            % All data
            % Set index of subjects to use
            subIdx = ismember(obj.expDataAll.Subject, subs);
            % Calculate error hist directly on this data
            [A, V] = obj.gatherMidHist(obj.expDataAll(subIdx,:));
            
            % Even if run on subset, save to "All" field. Leave calling
            % function to handle object (eg. see plotGroupSummary())
            obj.stats.midError.All.A = A;
            obj.stats.midError.All.V = V;
            
            if plt(1)
                abs = false;
                tit = 'All subjects, xNorm, yNorm';
                h(1) = obj.plotMidHist(A, V, tit, abs);
                SpatialAnalysis.ng('1024NE');
            end
            if plt(2)
                abs = false;
                tit = 'All subjects, xNorm';
                h(2) = obj.plotMidHist(A, V, tit, abs, true, false);
                SpatialAnalysis.ng('1024NE');
            end
            if plt(3)
                abs = true;
                tit = 'All subjects, xNorm, abs';
                h(3) = obj.plotMidHist(A, V, tit, abs, true, false);
                SpatialAnalysis.ng('1024NE');
            end
        end

        function obj = plotGroupSummary(obj, group, type, name)
            % Handle redoing .accuray, .congruence, .midError on both
            % subsets of subjects - eg. integrators vs non-integrators
            % Take tempoary objects from above methods and save to
            % mainobject in sensible place
            % Group should be logical of obj.expN x 1
            % Type specifies method to apply - may be a lot of graphs so
            % this will allow tidier publishing in calling script.
            
            if ~exist('type', 'var')
                type = 'Acc';
            end
            if ~exist('name', 'var')
                name = 'genericSubSet';
            end
            
            switch lower(type)
                case {'accuracy', 'acc'}
                    statsMethod = @obj.accuracy;
                    statsField = 'accuracy';
                    plt = [true, false, true, false];
                case {'congruence', 'cong'}
                    statsMethod = @obj.congruence;
                    statsField = 'congruence';
                    plt = [true, false];
                case {'miderror', 'me'}
                    statsMethod = @obj.midError;
                    statsField = 'midError';
                    plt = [true, false, false];
            end
            
            % Split groups
            subs = unique(obj.expDataAll.Subject);
            subs1 = subs(group);
            subs2 = subs(~group);
            
            % Apply method
            if sum(subs1)>0
                [g1Obj, g1h] = statsMethod(plt, subs1);
            else
                disp('Group 1 is empty')
            end
            
            if sum(subs2)>0
                [g2Obj, g2h] = statsMethod(plt, subs2);
            else
                disp('Group 2 is empty')
            end
            
            % Extract stats from tempoary objects and save
            obj.statsSubsets.(type).(name).group1 = ...
                g1Obj.stats.(statsField);
            obj.statsSubsets.(type).(name).group2 = ...
                g2Obj.stats.(statsField);
            obj.statsSubsets.(type).(name).group = group;
            
            % Attempt to relabel plots with group
            % for g = 1:numel(g1h)
                % h = g1h(g);
                % c = allchild(h);
                % for t = 1:numel(c)
                    % disp(class(c(t)))
                %     switch class(c(t))
                %         case 'matlab.graphics.axis.Axes'
                %            % Fuck it
                %    end
                % end
           % end
            
        end

        obj = plotAccuracy(obj, summaryStatsA, summaryStatsV )
        
    end
    
    
    methods (Static)
        
    end
    
end
