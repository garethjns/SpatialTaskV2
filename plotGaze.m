function plotGaze(NPs, idx, tit)

idx = idx==true;

figure
title(tit)
scatter(NPs(idx,1), NPs(idx,2))
hold on
scatter(NPs(~idx,1), NPs(~idx,2))
axis([-20,20,-20,20])
xlabel('Norm pos. 0')
ylabel('Norm pos. 1')