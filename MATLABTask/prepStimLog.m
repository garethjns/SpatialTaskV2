function stimLog = prepStimLog(params, stimOrder)
% Prepares stim log
% Add columns to save here

% Copy stimOrder
stimLog = stimOrder;
nd = length(stimOrder.Properties.VariableDescriptions);

% Add extra columns and decriptions
stimLog.PosBin = NaN(params.n, 2); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = ...
    'Bin label for stimulus position, for convenience';
stimLog.PosBinLog = cell(params.n, 1); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = ...
    'Bin logical for stimulus position, for convenience and comparison with respBins';

stimLog.RawResponse = cell(params.n, 1); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = ...
    '[Ax, Ay; Vx, Vy] rel to top left';
stimLog.RelResponse = cell(params.n, 1); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = ...
    '[AX, AY; VX, VY] rel to bottom middle';

stimLog.Angle = cell(params.n, 1); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = ...
    'Angle of response, relative to 0deg = North, degs';

stimLog.diffAngle = cell(params.n, 1); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = ...
    'Difference between response and auditory position, degs';

stimLog.RT = cell(params.n, 1); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = 'Response time, ms';

stimLog.aStim = cell(params.n, 1); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = 'aStim';

stimLog.vStim = cell(params.n, 1); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = 'vStim';

stimLog.respBinED = cell(params.n, 1); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = ...
    'Response binned by physical location (Euclidean distance, [A1:12;V])';

stimLog.respBinAN = cell(params.n, 1); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = ...
    'Response binned by physical location (angle, [A1:12;V])';

stimLog.timeStamp = NaN(params.n, 2); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = '{startTime, endTime} in MATLAB time';

stimLog.startClock = NaN(params.n, 6); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = 'startTime as MATLAB clock';

stimLog.endClock = NaN(params.n, 6); nd = nd+1;
stimLog.Properties.VariableDescriptions{nd} = 'endTime as MATLAB clock';

