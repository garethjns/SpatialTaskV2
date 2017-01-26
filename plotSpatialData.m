function h = plotSpatialData(stats, tit)

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
    bar(stats(2,:,pf)', stats(3,:,pf)')
    hold on
%     errorbar(stats(2,:,pf)', stats(3,:,pf)', ...
%         stats(4,:,pf)'./sqrt(stats(5,:,pf)'), ....
%         'LineStyle', 'none')
    axis([min(stats(2,:,pf))*1.1, max(stats(2,:,pf))*1.1, ...
       min(min(stats(3,:,:)))*1.1, max(max(stats(3,:,:)))*1.1])
   title(['+/-', num2str(stats(1,1,pf))])
   
   % Place axis labels on certain subplots
   switch pf
       case 1
           ylabel('Response error, deg') 
       case 3
           xlabel('Incongruency, deg')
   end
   
   xLab = stats(2,~isnan(stats(2,:,pf)),pf)';
   hAx.XTick = xLab;
   hAx.XTickLabel = xLab;
   hAx.XTickLabelRotation = -45;
end

suptitle(tit)

% Save
hgx(['Graphs\', strrep(tit, ':', '')])