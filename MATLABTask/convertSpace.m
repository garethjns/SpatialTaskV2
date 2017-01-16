function [X, Y, angle] = convertSpace(x, y, fig, xMidPoint)
% Converts space to 0 deg North and calcualtes angles in this system
% relative to the figure (and checks this matches calibration)
% x and y can be vectors

figDims = get(fig, 'Position');

% xMidPoint should match figDims(4)/2
if abs(figDims(3)/2 - xMidPoint(1)) > 20
    disp('Check midpoint')
end

% Conversion required:
% Y from 0,0 = top left -> 0,0 = bottom left
Y = figDims(4) - y;
% X from 0 = left to 0 = middle
X = x - xMidPoint(1);

% Calculate angle
angle = rad2deg(atan(Y./X));

% Also rotate coridinate system to 0 = North (midline)
angle(angle<0) = -90-angle(angle<0);
angle(angle>0) = 90-angle(angle>0);
