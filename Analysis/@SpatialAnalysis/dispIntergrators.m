function h = dispIntergrators(obj, mn, plt)
% Plot table of integrations for model mn
% Plot imagesc of logicals
% Box plot ratios for each group

if ~exist('plt', 'var')
    plt = [true, true, true];
end

% Prepare handles output
h = gobjects(1,3);

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


%% Imagesc logicals

if plt(1)
    
    h(1) = figure;
    % Auditory
    ax = subplot(1,7,1:3);
    % Plot heatmap
    imagesc(t{:,colsAr})
    hold on
    % Add manual gridlines
    addGrids(obj, true, true)
    % Set ticks and labels
    ax.YTick = 1:15;
    ax.XTick = 1:3;
    ax.XMinorTick = 'on';
    ax.XRuler.MinorTickValues = 0.5:2.5;
    ax.YRuler.MinorTickValues = 0.5:14.5;
    ax.XTickLabel = colsAr;
    ax.XTickLabelRotation = 45;
    ylabel('Subject')
    title('Aud resp.')
    
    % Visual
    ax = subplot(1,7,4:6);
    imagesc(t{:,colsVr})
    hold on
    addGrids(obj, true, true)
    ax.YTick = [];
    ax.XTick = 1:3;
    ax.XMinorTick = 'on';
    ax.XRuler.MinorTickValues = 0.5:2.5;
    ax.YRuler.MinorTickValues = 0.5:14.5;
    ax.XTickLabel = colsVr;
    ax.XTickLabelRotation = 45;
    title('Vis resp.')
    
    % AV
    ax = subplot(1,7,7);
    imagesc(t{:,colsAVr})
    hold on
    addGrids(obj, true, false)
    ax.YTick = [];
    ax.XTick = 1;
    ax.XMinorTick = 'on';
    ax.XRuler.MinorTickValues = 0.5:2.5;
    ax.YRuler.MinorTickValues = 0.5:14.5;
    ax.XTickLabel = colsAVr;
    ax.XTickLabelRotation = 25;
    title('AV resp.')
    
    hc = colorbar;
    hc.Ticks = [0, 1];
  
end


%% Ratio boxplots

% Aud resp
if plt(2)
    h(2) = figure;
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
end

% Vis resp
if plt(3)
    h(3) = figure;
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


%% Helpers

function addGrids(obj, h, v)

if v % Add vert
    plot([1.5, 1.5], [-1, obj.expN+1], ...
        'LineStyle', '--', 'LineWidth', 2, 'color', 'k')
    plot([2.5, 2.5], [-1, obj.expN+1], ...
        'LineStyle', '--', 'LineWidth', 2, 'color', 'k')
end

if h % Add horz
    for s = 1:obj.expN
        plot([-0.5, 3.5], [s-0.5, s-0.5], 'LineWidth', 2, 'color', 'k')
    end
    plot([-0.5, 3.5], [obj.expN+0.5, obj.expN+0.5], ...
        'LineWidth', 2, 'color', 'k')
end