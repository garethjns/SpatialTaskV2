function DA = diffAngle(pos, angles)
% Function to calculate diff angle for pos = A,V, angle = A;V
% Output in shape A;V

DA = pos'-angles;
