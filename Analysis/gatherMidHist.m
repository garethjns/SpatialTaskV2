function [dataA, dataV] = gatherMidHist(allData)
% Get data from middle plot
% Plot histogram of response error for AV
% Eg, for response A
% Plot "less reliable" V (where V moves out) and "more reliable" V (where V
% moves in)
% Output reponse for A and V where:
% Rows = n
% Cols = diffs ie. [-30, -15, 0, 15, 30] 

% Recalc diffs
% Code from gatherCongProp
vp = abs(allData.Position(:,2));
% Get all the absolute auditory positions
ap = abs(allData.Position(:,1));

% Recaulcaute the between these (not the abs difference)
VADiffs = abs(vp) - abs(ap);
% Then flip the sign, so negative is aud back towards midline
VADiffs = 0 - VADiffs;
% ie.
% Given V location, aLoc = VLoc + VADiff

% Recalculate AV Diffs
AVDiffs = abs(ap) - abs(vp);
% And invert so negative vis back towards midline
AVDiffs = 0 - AVDiffs;
% ie.
% Given A location, ALoc = VLoc + AVDiff
% [ap(1:5),vp(1:5)]
% [AVDiffs(1:5), VADiffs(1:5)]

% And just keep the unique ones
% diffs = unique([AVDiffs, AVDiffs]);
diffs = [-30, -15, 0, 15, 30];
nDiff = numel(diffs);
dataA = NaN(round(height(allData)/8), nDiff); 
dataV = NaN(round(height(allData)/8), nDiff);

pIdxA = abs(allData.Position(:,1)) == 37.5;
pIdxV = abs(allData.Position(:,2)) == 37.5;

for d = 1:nDiff
   
    % A resp
    dIdxAV = AVDiffs == diffs(d);
    % Get data subsets using dIdx and pIdx
    subsetA = allData(pIdxA & dIdxAV,:);
    
    % Recalculate diffAngle so -means back towards midline
    % Need to fold around position, which are in absolute space
    % Difference between resp and response:
    %  pos - resp      |   abs(pos) - abs(resp):
    % -40 - -30 = -70  |  0-(abs(-40) - abs(-30)) = -10
    % -40 - -50 = -90  |  0-(abs(-40) - abs(-50)) = 10
    % 40 - 30 = 10     |  0-(abs(40) - abs(30)) = 10
    % 40 - 50 = -10    |  0-(abs(40) - abs(50)) = -10
    % So do:
    % abs(resp) - abs(pos)
    % Get angle responses. This is {:}[2x1].
    % Convert to mat - appends all together
    matA = cell2mat(subsetA.Angle);
    % Drop the visual responses
    matA = matA(1:2:end);
    % And calculate the diffAngle
    diffAngle = abs(matA) - abs(subsetA.Position(:,1));
    % Note that this is DIFFERENT from the .diffAngle column.
    % .diffAngle is simply pos - resp, so sign flips depending on side.
    
    % Add to matrix
    dataA(1:length(diffAngle),d) = diffAngle;
    
    
    % Same for visual V Resp
    dIdxVA =  VADiffs == diffs(d);
    subsetV = allData(pIdxV & dIdxVA,:);
    matV = cell2mat(subsetV.Angle);
    matV = matV(2:2:end);
    diffAngle = abs(matV) - abs(subsetV.Position(:,2));
    dataV(1:length(diffAngle),d) = diffAngle;
    
end

dataA = dataA(~all(isnan(dataA),2),:);
dataV = dataV(~all(isnan(dataV),2),:);

% Audotory response
% Aud from middle position
% 
% pIdxVPoor = AVDiffs==15;
% pIdxAV = AVDiffs==0;
% pIdxVGood = AVDiffs==-15;
%

% subsetPoor = allData(pIdxAud & pIdxVPoor,:);
% subsetAV = allData(pIdxAud & pIdxAV,:);
% subsetGood = allData(pIdxAud & pIdxVGood,:);
%

% matPoor = cell2mat(subsetPoor.diffAngle);
% matAV = cell2mat(subsetAV.diffAngle);
% matGood = cell2mat(subsetGood.diffAngle);
%
%dataA = [matPoor, matAV, matGood];