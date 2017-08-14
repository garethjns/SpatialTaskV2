classdef SpatialAnalysis < InitialAnalysis
    
    properties
        GLMs % Struct with various GLM fits 
        stats % Struct with dumps of graph data
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
            
            %% Cong vs abs incong for unfolded:
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

            
            %% Cong vs rel ingong for folded:
            
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
            obj.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit)
            
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
            obj.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit)
            
            
            %% Plot folded, rel (stats)
            
            tit = 'Response accuracy - fold, rel, across subs';
            [summaryA, ~, posAx] = ...
                obj.gatherAcrossSubjectAccuracy(statsAcFoldRel);
            [summaryV, ~, ~] = ...
                obj.gatherAcrossSubjectAccuracy(statsVcFoldRel);
            obj.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit)
            
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
            obj.plotAcrossSubjectAccuracy(summaryA, summaryV, posAx, tit)

            
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
                
                GLMStats.NonLinearResp.(fieldName) = st;
                
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
                
                GLMStats.NonLinearCor.(fieldName) = st;
                
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
        
        obj = plotAccuracy(obj, summaryStatsA, summaryStatsV )
        
    end
    
    
    methods (Static)
        
        
    end
    
end