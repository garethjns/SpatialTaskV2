function plotGaze(NPs, idx, tit)

idx = idx==true;

figure
title(tit)
scatter(NPs(idx,1), NPs(idx,2))
hold on
scatter(NPs(~idx,1), NPs(~idx,2))
axis([-5,5,-5,5])
xlabel('Norm pos. 0')
ylabel('Norm pos. 1')