function h = plotSpatialDataOldMATLAB(stats, tit)

% stats is a 3D matrix. Rows correspond to mean, std, and n. Cols
% correspond to absolute difference between A and V stim locations. 3rd
% dimension corresponse to spatial location visual stimuls was presented
% from.
% Want to plot a bar graph with grouped bars for each visual position and
% individual bars for each differece, showing average error

% Put each absolute position in different subplot
% h = figure;

nPoss = size(stats,3);

for pf = 1:nPoss
    hAx = subplot(1,nPoss,pf);
    bar(stats(2,:,pf)', stats(3,:,pf)')
    hold on
%     errorbar(stats(2,:,pf)', stats(3,:,pf)', ...
%         stats(4,:,pf)'./sqrt(stats(5,:,pf)'), ....
%         'LineStyle', 'none')
    axis([nanmin(stats(2,:,pf))*1.1, nanmax(stats(2,:,pf))*1.1+0.1, ...
       nanmin(nanmin(stats(3,:,:)))*1.1, nanmax(nanmax(stats(3,:,:)))*1.1+0.1])
   title(['+/-', num2str(stats(1,1,pf))])
   
   % Place axis labels on certain subplots
   switch pf
       case 1
           ylabel('Response error, deg') 
       case 3
           xlabel('Incongruency, deg')
   end
   
   xLab = stats(2,~isnan(stats(2,:,pf)),pf)';
   set(hAx, 'XTick', xLab)
   set(hAx, 'XTickLabel', xLab)
   % hAx.XTick = xLab;
   % hAx.XTickLabel = xLab;
end

suptitle(tit)
