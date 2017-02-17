function stimLog = writeStimLog(stimLog, params, figs, n, AResp, VResp, ...
    ART, VRT, aStim, vStim, startTime, endTime, startClock, endClock)
% Save response in to stimLog, return stimLog with response added
% Calculate angle. etc as well

% Add rawResponse (actual value from axis) and response time
stimLog.RawResponse{n,1} = [AResp; VResp];
stimLog.RT{n,1} = [ART; VRT];

% Save stim structures presented, .sound already removed
stimLog.aStim{n,1} = aStim;
stimLog.vStim{n,1} = vStim;

% Convert cords and get angle
[AX, AY, ADeg] = convertSpace(AResp(1), AResp(2), figs.resp, ...
    params.screenCalib.xMidPoint);
[VX, VY, VDeg] = convertSpace(VResp(1), VResp(2), figs.resp, ...
    params.screenCalib.xMidPoint);

% Save this "relative" response
stimLog.RelResponse{n,1} = [AX, AY; VX, VY];

stimLog.Angle{n,1} = [ADeg; VDeg];

% Calcualte diff angle positions
stimLog.diffAngle{n,1} = [stimLog.Position(n,1) - ADeg;...
    stimLog.Position(n,2) - VDeg];

% Now bin responses into physical conditions (running 1->12, clockwise)
% Using Euclidean distance:
edA = ...
    sqrt((AX - params.screenCalib.X).^2 + (AY - params.screenCalib.Y).^2);
[~, mIdxAEd] = min(edA);
edV = ...
    sqrt((VX - params.screenCalib.X).^2 + (VY - params.screenCalib.Y).^2);
[~, mIdxVEd] = min(edV);

binsEd = zeros(2, max(params.chanMap2(2,:))); % Should be 12;
binsEd(1, mIdxAEd) = 1;
binsEd(2, mIdxVEd) = 1;

stimLog.respBinED{n,1} = binsEd;

% Using angle:
anA = ADeg - params.screenCalib.angle;
[~, mIdxAAn] = min(abs(anA));
anV = VDeg - params.screenCalib.angle;
[~, mIdxVAn] = min(abs(anV));

binsAn = zeros(2, max(params.chanMap2(2,:))); % Should be 12;
binsAn(1, mIdxAAn) = 1;
binsAn(2, mIdxVAn) = 1;

stimLog.respBinAN{n,1} = binsAn;

% Also bin the actual postition for convenicence later
stimBinA = params.Positions == stimLog.Position(n,1);
stimBinV = params.Positions == stimLog.Position(n,2);

stimLog.PosBin(n,:) = [find(stimBinA), ...
    find(stimBinV)];
stimLog.PosBinLog{n} = [stimBinA; stimBinV];

% Add time
stimLog.timeStamp(n,:) = [startTime, endTime]; % GetSecs
stimLog.startClock(n,:) = startClock; % MATLAB time
stimLog.endClock(n,:) = endClock;


%% Show added row and angle in command window
disp(stimLog(n,:))
disp(['Angles: A: ', num2str(ADeg), ', V: ', num2str(VDeg)]);
disp(['Bins (AN): A: ', num2str(mIdxAAn), ', V: ', num2str(mIdxVAn)]);
disp(['Bins (Ed): A: ', num2str(mIdxAEd), ', V: ', num2str(mIdxVEd)]);