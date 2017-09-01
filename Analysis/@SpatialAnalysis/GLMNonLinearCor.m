function [obj, h] = GLMNonLinearCor(obj)
% ACorr = a+ b*ALoc + c*Vloc + d*ALoc*VLoc
% Fits ACorr model (fitGLM2) and plots. Plotting code is not up to date -
% see .GLMNonLinearResp(). If this function is used again, would be worth
% generalising with .GLMNonLinearResp().

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
