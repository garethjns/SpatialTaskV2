function plotMidHist(dataA)

figure
suplot(2,1,1)
plotKS(dataA)

subplot(2,1,2)
plotKS(dataV)

end

function plotKS(data)

for d = 1:size(data,2)
    
    kdsdensity(data(:,d))
end

end
