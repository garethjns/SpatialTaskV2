function angle = calcAngle(xy)
% Calculate angle from raw response using set image dimensions.

x = xy(:,1);
y = xy(:,2);

yHeight = 600; % px
centreHeight = 110; % px
xWidth = 1023; % px

% Convert top left = (0,0) to bottom left = (0,0)
y = yHeight-y;

% Convert bottom left = (0,0) to centre = (0,0)
x = x-xWidth/2;
y = y-centreHeight;

% Caluclate angle from midline = 0 deg in deg
angle = rad2deg(atan(x./y));
