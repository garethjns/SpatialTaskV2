classdef SpatialAnalysis < InitialAnalysis
    
    properties
        GLMs % Struct with various GLM fits
        stats % Struct with dumps of graph data
        integrators % Struct with "integrators" by model
    end
    
    methods
        
        function obj = SpatialAnalysis()
        end
        
        function obj = accuracy(obj)
            
            % Calculate average accuracy for each subject (folded/unfolded,
            % rel/abs)
            for e = 1:obj.expN
                fieldName = ['s', num2str(e)];
                
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
            
            
            %% Cong vs rel ingong for folded
            
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
            obj.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit);
            
            % A stats
            [p, tbl, st] = ...
                anovan(summaryStatsA.mean_ACorrect, ...
                {summaryStatsA.Cong, ...
                summaryStatsA.aPos, ...
                summaryStatsA.Rate}, ...
                'model', 'interaction', ...
                'varname', {'cong', 'aPos', 'Rate'});
            % Compare on rate
            figure;
            multcompare(st, 'Dimension', 3);
            % Compare on cong
            figure;
            multcompare(st, 'Dimension', 1);
            
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
            figure;
            multcompare(st, 'Dimension', 3);
            % Compare on cong
            figure;
            multcompare(st, 'Dimension', 1);
            
            
            %% Plot unfolded, rel (no stats)
            tit = 'Response accuracy - unfold, rel, across subs';
            [summaryA, ~, posAx] = ...
                obj.gatherAcrossSubjectAccuracy(statsAcRel);
            [summaryV, ~, ~] = ...
                obj.gatherAcrossSubjectAccuracy(statsVcRel);
            obj.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit);
            
            
            %% Plot folded, rel (stats)
            
            tit = 'Response accuracy - fold, rel, across subs';
            [summaryA, ~, posAx] = ...
                obj.gatherAcrossSubjectAccuracy(statsAcFoldRel);
            [summaryV, ~, ~] = ...
                obj.gatherAcrossSubjectAccuracy(statsVcFoldRel);
            obj.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit);
            
            % A stats
            [p, tbl, st] = ...
                anovan(summaryStatsFoldedA.mean_ACorrect, ...
                {summaryStatsFoldedA.Cong, ...
                summaryStatsFoldedA.aPos, ...
                summaryStatsFoldedA.Rate}, ...
                'model', 'interaction', ...
                'varname', {'cong', 'aPos', 'Rate'});
            
            % Compare on cong
            figure;
            multcompare(st, 'Dimension', 1);
            % Compare on cong vs pos
            figure;
            multcompare(st, 'Dimension', [1, 2]);
            
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
            figure;
            multcompare(st, 'Dimension', 1);
            % Compare on cong vs pos
            figure;
            multcompare(st, 'Dimension', [1, 2]);
            
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
            obj.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit);
            
            
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
            % Ar_useV: V used for aud resp - semi-V inetgrator
            % Ar_useAV: AV used for aud resp - semi-V inetgrator
            % Ar_useVAV: V and AV used for aud resp - full-V integrator
            % Vr_useA: A Used for vis resp - semi-A inetgrator
            % Vr_useAV: AV used for vis resp - semi-A inetgrator
            % Vr_useAAV: A and AV used for vis resp - full-A inetgrator
            % AVr_useVAVAAV: Does everything (?)
            
            % Set significance threshold if not specified
            if ~exist('thresh', 'var')
                thresh = 0.05;
            end
            
            % Get the selected model to use
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
            
            fns = fieldnames(mod);
            nSubs = length(fns);
            
            % For each subject, mark A int, V int, AV inte
            vars = {(1:nSubs)', 'Subject', 'Subject number'; ...
                NaN(nSubs,1), 'pA_Ar', 'Uses A in A response'; ...
                NaN(nSubs,1), 'pV_Ar', 'Uses V in A response'; ...
                NaN(nSubs,1), 'pAV_Ar', 'Uses AV in A reponse'; ...
                NaN(nSubs,1), 'pA_Vr', 'Uses A in V response'; ...
                NaN(nSubs,1), 'pV_Vr', 'Uses V in V response'; ...
                NaN(nSubs,1), 'pAV_Vr', 'Uses AV in V reponse'; ...
                NaN(nSubs,1), 'A_Ar', 'Uses A in A response'; ...
                NaN(nSubs,1), 'V_Ar', 'Uses V in A response'; ...
                NaN(nSubs,1), 'AV_Ar', 'Uses AV in A reponse'; ...
                NaN(nSubs,1), 'A_Vr', 'Uses A in V response'; ...
                NaN(nSubs,1), 'V_Vr', 'Uses V in V response'; ...
                NaN(nSubs,1), 'AV_Vr', 'Uses AV in V reponse'; ...
                NaN(nSubs,1), 'Ar_useV', 'V used for aud resp - semi-V inetgrator'; ...
                NaN(nSubs,1), 'Ar_useAV', 'AV used for aud resp - semi-V inetgrator'; ...
                NaN(nSubs,1), 'Ar_useVAV', 'V and AV used for aud resp - full-V integrator'; ...
                NaN(nSubs,1), 'Vr_useA', 'A Used for vis resp - semi-A inetgrator'; ...
                NaN(nSubs,1), 'Vr_useAV', 'AV used for vis resp - semi-A inetgrator'; ...
                NaN(nSubs,1), 'Vr_useAAV', 'A and AV used for vis resp - full-A inetgrator'; ...
                NaN(nSubs,1), 'AVr_useVAVAAV', 'Does everything (?)'};
            
            t = table(vars{:,1}, ...
                'VariableNames', vars(:,2));
            t.Properties.VariableDescriptions = vars(:,3);
            
            for s = 1:nSubs
                
                sIdx = t.Subject==s;
                t.pA_Ar(sIdx) = ...
                    mod.(fns{s}).(['A', mfn]).Coefficients.pValue(2);
                t.pV_Ar(sIdx) = ...
                    mod.(fns{s}).(['A', mfn]).Coefficients.pValue(3);
                t.pAV_Ar(sIdx) = ...
                    mod.(fns{s}).(['A', mfn]).Coefficients.pValue(4);
                
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
            t.Ar_useVAV = t.V_Ar & t.AV_Ar;
            t.Vr_useAAV = t.A_Vr & t.AV_Vr;
            t.AVr_useVAVAAV = t.Ar_useVAV & t.Vr_useAAV;
            
            % Save table
            obj.integrators.(mn) = t;
            
        end
        
        function obj = congruence(obj, plot)
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
            
            if ~exist('plot', 'var')
                plot = true;
            end
            
            pec = 2;
            for e = 1:obj.expN
                fieldName = ['s', num2str(e)];
                
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
            for e = 1:obj.expN
                fieldName = ['s', num2str(e)];
                
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
            if plot
                tit = ['Avg: Proportion congruent responses,',...
                    'abs diff between A and V'];
                obj.plotCongProp(statsP3Av, tit);
                
                tit = ['Avg: Proportion congruent responses,', ...
                    'relative diff between A and V'];
                obj.plotCongProp(statsP4Av, tit);
            end
        end

        obj = plotAccuracy(obj, summaryStatsA, summaryStatsV )
        
    end
    
    
    methods (Static)
        
        
    end
    
end