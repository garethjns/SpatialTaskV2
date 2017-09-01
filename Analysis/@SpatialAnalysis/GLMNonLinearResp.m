function [obj, h] = GLMNonLinearResp(obj)
% A/V Resp = a+ b*ALoc + c*Vloc + d*ALoc*VLoc
% Fits Resp model (fitGLM4) and plots. More up to date that
% .GLMNonLinearCor().

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
% Add hidden lines
lh(1) = plot([-10, -5], [-10, -5], ...
    'LineStyle', '--', 'Color', [0.6, 0.6, 0.6]);
lh(2) = plot([-10, -5], [-10, -5], ...
    'LineStyle', '--', 'Color', [0.3, 0.3, 0.8]);
% Add legend using these
legend(lh, {'"Non integrator"', '"Integrator"'})
xlim([0, 4])
ylim([-0.3, 1.1])
% Label ticks with coefficient name
aAx.XTick = [1, 2, 3];
aAx.XTickLabels = ...
    st.AResp.Coefficients.Properties.RowNames(2:4);
aAx.XTickLabelRotation = 45;
% aAx.YScale = 'log';
ylabel('Magnitude')
title('AResp = ALoc + Vloc + ALoc*VLoc')

subplot(1,2,2)
% Add hidden lines
lh(1) = plot([-10, -5], [-10, -5], ...
    'LineStyle', '--', 'Color', [0.6, 0.6, 0.6]);
lh(2) = plot([-10, -5], [-10, -5], ...
    'LineStyle', '--', 'Color', [0.3, 0.3, 0.8]);
% Add legend using these
legend(lh, {'"Non integrator"', '"Integrator"'})
xlim([0, 4])
ylim([-0.3, 1.1])
vAx.XTick = [1, 2, 3];
vAx.XTickLabels = ...
    st.VResp.Coefficients.Properties.RowNames(2:4);
vAx.XTickLabelRotation = 45;
% vAx.YScale = 'log';
title('VResp = ALoc + Vloc + ALoc*VLoc')

obj.GLMs.NonLinearResp = GLMStats;
