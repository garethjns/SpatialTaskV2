function AO = initMOTU(params)
% Start PsychSound
InitializePsychSound;

% Close all devices
PsychPortAudio('Close');

% Check base workspace for AO - probably redundant now
% Try and get AO from workspace
try
    AO = evalin('base', 'AO');
catch
    AO = [];
end

% Close PortAudio if open
if exist('AO', 'var') && isfield(AO,'ao')
    PsychPortAudio('Close', AO.ao)
end

% Find MOTU
devs=PsychPortAudio('GetDevices');
d=1;

found=0;
disp('Watiting to connect to MOTU...')
while found==0
    disp(['Checking device ', num2str(d), '...'])
    if strcmp(devs(d).DeviceName, 'MOTU PCI ASIO')==1
        found=1;
        AO.device=d-1;
    else
        if d < 100
            d=d+1;
        else
            d = 1;
        end
    end
end

% Open MOTU and get status
AO.ao = PsychPortAudio('Open', AO.device, [], 1, ...
    params.Fs, params.nChannels);
AO.status = PsychPortAudio('GetStatus', AO.ao);

disp('MOTU ready');


clear d found