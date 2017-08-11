function bin = calcRespBinAn(angles)
% Calc respBinAn from 12 set positions and A;V angles

positions = [-82.5, -67.5, -52.5, -37.5, -22.5, -7.5, ... (left)
   7.5, 22.5, 37.5, 52.5, 67.5, 82.5]; % Right

bin = zeros(2, length(positions));

A = angles(1);
V = angles(2);

[~, idx] = min(abs(positions-A));
bin(1, idx) = 1;

[~, idx] = min(abs(positions-V));
bin(2, idx) = 1;
