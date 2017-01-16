function [figs, params] = initGUI(params)
% Creates figures response, performance, stim
% Stim: Debug figure showing stims being presented
% Response: Area for touchscreen to respond in
% Performance: Live graph of performance
% Calibates positions of dots and figure co-ordinates
% params.screenCalib.x and y contain raw coordinaties
% params.screenCalib.X and Y contain alternative where 0 deg = North,
% angles are calculated in this system

% Get current monitor positions
monPos = get(0, 'MonitorPositions');


%% Response figure

% Create figure
figs.resp = figure;
% Remove menu bar and toobar
set(figs.resp, 'MenuBar', 'none');
set(figs.resp, 'ToolBar', 'none');

% Do calibration
% Ie. find on axes value of each poisitions
% NB: Image loaded into 0 -> width, 0 -> -height space


if params.screenCalib.do
    OK = 0;
    while ~OK
        clf
        
        % Load guide figure and set position
        imshow('Background_wg.png')
        set(figs.resp, ...
            'position', [monPos(3,1)+1, 1, ...
            monPos(3,3)-monPos(3,1), monPos(3,4)-monPos(3,2)]);
        
        x = NaN(12,1);
        y = NaN(12,1);
        disp(params.screenCalib.message)
        
        hold on
        for p = 1:12
            disp(['P', num2str(p)])
            [x(p), y(p)] = ginput(1);
            scatter(x,y)
        end
        plot(x, y)
        
        disp('x midpoint')
        xMidPoint = ginput(1);
        
        if strcmp(input('Looks ok? ', 's'), 'y')
            OK = 1;
        end
    end
    
else % No clibration
    % Load preset values accutate to a ~1/10th of a hydrogen atom:
    x = [128.810442678774;155.517593643587;203.125993189557; ...
        276.280363223610;365.691259931896;460.908059023837; ...
        561.930760499432;662.953461975028;747.719636776390; ...
        819.712826333712;869.643586833144;897.511918274688];
    y = [441.583427922815;349.850170261067;261.600454029512; ...
        190.768444948922;138.515323496027;111.808172531215; ...
        111.808172531215;137.354143019296;189.607264472191; ...
        260.439273552781;349.850170261067;441.583427922815];    
    
    xMidPoint = [515.483541430193,496.158910329171];
end

% Clear figure and load non-guide version
imshow('Background.png')
% Move to last monitor
set(figs.resp, ...
    'position', [monPos(params.nMons,1)+1, 1, ...
    monPos(params.nMons,3)-monPos(params.nMons,1), ...
    monPos(params.nMons,4)-monPos(params.nMons,2)]);

% Save calib information
params.screenCalib.x = round(x);
params.screenCalib.y = round(y);
params.screenCalib.xMidPoint = xMidPoint;
params.screenCalib.figPos = get(figs.resp, 'Position');

% Also convert to alternative coordinates (0 deg North)
[X, Y, angle] = convertSpace(x, y, figs.resp, xMidPoint);
% Save for later
params.screenCalib.angle = round(angle*100)/100;
params.screenCalib.X = round(X);
params.screenCalib.Y = round(Y);

% Verify
hold on
plot(params.screenCalib.x, params.screenCalib.y)
scatter(params.screenCalib.x, params.screenCalib.y, 'filled')

figs = updateRespMessage(figs, params, 'Not ready, see console');
if ~strcmp(input('Looks ok? ', 's'), 'y')
    keyboard
end

% Clear again and load non-guide version
clf
figs.respText = [];
imshow('Background.png')
set(figs.resp, ...
    'position', [monPos(params.nMons,1)+1, 1, ...
    monPos(params.nMons,3)-monPos(params.nMons,1), ...
    monPos(params.nMons,4)-monPos(params.nMons,2)]);
hold off


%% Mirrored response figure

figs.respMir = figure;
% Remove menu bar and toobar
set(figs.respMir, 'MenuBar', 'none');
set(figs.respMir, 'ToolBar', 'none');

imshow('Background_wg.png')
set(figs.respMir, ...
    'position', [monPos(1,1)+3, (monPos(1,4)/2)-50, ...
    monPos(params.nMons,3)-monPos(params.nMons,1), ...
    monPos(params.nMons,4)-monPos(params.nMons,2)]);

% Verify
hold on
plot(params.screenCalib.x, params.screenCalib.y)
scatter(params.screenCalib.x, params.screenCalib.y, 'filled')


%%  Perf figure

% Create figure
figs.perf = figure;
% Move to main screen (uses some aboslue values, change to relative later?)
set(figs.perf, ...
    'position', ...
    [monPos(1,1)+700, monPos(1,2)+400, monPos(1,3)/2, monPos(1,4)/2]);


%% Stim figure

% Create figure
figs.stim = figure;
% Move to main screen (uses some aboslue values, change to relative later?)
set(figs.stim, ...
    'position', ...
    [monPos(1,3)/2, 100, monPos(1,3)/3, monPos(1,4)/3]);


%% Select response figure

figure(figs.resp)
