function h = plotCongProp(stats, tit)

% stats is a 3D matrix. Rows correspond to mean, std, and n. Cols
% correspond to absolute difference between A and V stim locations. 3rd
% dimension corresponse to spatial location visual stimuls was presented
% from.
% Want to plot a bar graph with grouped bars for each visual position and
% individual bars for each differece, showing average error

% Put each absolute position in different subplot
h = figure;

nPoss = size(stats,3);

for pf = 1:nPoss
    hAx = subplot(1,nPoss,pf);
    
    % Find the 0 incong index
    congIdx = stats(2,:,pf) == 0;
    
    % Create a NaN buffered version to avoid hold and second plot screwing
    % bar width
    congStats = NaN(size(stats));
    congStats(:,congIdx,:) = stats(:,congIdx,:);
    inCongStats = NaN(size(stats));
    inCongStats(:,~congIdx,:) = stats(:,~congIdx,:);
    % Makes no difference!
    
    % Plot cong bar in green
    hBar = bar(congStats(2,:,pf)', congStats(3,:,pf)');
    hBar.FaceColor = [0.5,0.4,0.6];
    hold on
    hBar2 = bar(inCongStats(2,:,pf)', inCongStats(3,:,pf)');
    % Buffering above makes no difference, fix manually
    hBar.BarWidth = 10;
    
    errorbar(stats(2,:,pf)', stats(3,:,pf)', ...
        stats(4,:,pf)'./sqrt(stats(6,:,pf)'), ....
        'LineStyle', 'none')
    
    % Set axis if data is available
    yl = [nanmin(stats(2,:,pf))-10, ...
        nanmax(stats(2,:,pf))*1.1];
    if all(~isnan(yl))
        ylim(yl)
    end
    xl = [nanmin(nanmin(stats(3,:,:)))*1.1, ...
        nanmax(nanmax(stats(3,:,:)))*1.1];
    if all(~isnan(xl))
        xlim(xl)
    end

   title(['+/-', num2str(stats(1,1,pf))])
   
   % Place axis labels on certain subplots
   switch pf
       case 1
           ylabel('Prop. "cong." resp, deg') 
       case 3
           xlabel('A V Incongruency, deg')
   end
   
   xLab = stats(2,~isnan(stats(2,:,pf)),pf)';
   hAx.XTick = xLab;
   hAx.XTickLabel = xLab;
   hAx.XTickLabelRotation = -45;
end

suptitle(tit)

% Save
hgx(['Graphs\', strrep(tit, ':', '')])