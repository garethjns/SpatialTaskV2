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
