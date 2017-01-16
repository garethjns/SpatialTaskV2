function [AO, aStim, vStim] = ...
    prepStim(stimOrderRow, params, AO, figs)
% Generates next stim, places in buffer and returns structures used to
% generate them
% Structuring this different to previous code
% Genrate both stim, save just aStim and vStim rather than vector for both
% filled with NaNs and representing space
% Then place the .sounds in to correct buffer position using chanMap

% Prepare output matrix
output = zeros(params.nChannels, ceil(params.Fs*params.cutOff/1000));

% Generate seed for event noise
% Pick a noise event ID here, instead of in Church 2
% (To match them for A 'noise' events
eID = randi(10000);

% Generate temporally synchrounous stim
% A parameters
% Common
cfg.dispWarn = 0;
cfg.rideNoise = params.rideNoise;
cfg.duration = stimOrderRow.Duration;
cfg.gap1 = params.gap1;
cfg.gap2 = params.gap2;
cfg.eventLength = params.eventLength;
cfg.cutOff = params.cutOff;
cfg.startBuff = params.startBuff;
cfg.endBuff = params.endBuff;
cfg.nEvents = stimOrderRow.nEvents;
cfg.Fs = params.Fs;

% Specific
cfg.type = 'Aud';
cfg.seedEvent = eID;
cfg.eventMag = params.aEventMag;
cfg.noiseType = 'multipleBlocks';
cfg.noiseMag = params.aNoiseMag;
cfg.cull = params.SoundMax;
cfg.eventType = 'noise';

% A generate
aStim = Church2Spatial(cfg);

clear cfg

% V parameters
% Get seed from aStim
cfg.seed=aStim.seed;

% Common
cfg.dispWarn = 0;
cfg.rideNoise = params.rideNoise;
cfg.duration = stimOrderRow.Duration;
cfg.gap1 = params.gap1;
cfg.gap2 = params.gap2;
cfg.eventLength = params.eventLength;
cfg.cutOff = params.cutOff;
cfg.startBuff = params.startBuff;
cfg.endBuff = params.endBuff;
cfg.nEvents = stimOrderRow.nEvents;
cfg.Fs = params.Fs;

% Specific
cfg.type = 'Vis';
cfg.eventMag = params.vEventMag;
cfg.eventType = 'flat';
cfg.noiseType = 'multipleBlocks';
cfg.noiseMag = params.vNoiseMag;
cfg.cull = params.LEDMax;

% V generate
vStim = Church2Spatial(cfg);

% Save into output vectors
outputSound(1,1:length(aStim.sound)) = ...
    aStim.sound;
outputLED(1,1:length(vStim.sound)) = ...
    vStim.sound;

% Place into output matrix using chanMap2
chanMap = params.chanMap2;

aLoc = stimOrderRow.Position(1);
vLoc = stimOrderRow.Position(2);

aIdx = (chanMap(3,:) == 1 ...
    & chanMap(4,:) == aLoc)';
vIdx = (chanMap(3,:) == 2 ...
    & chanMap(4,:) == vLoc)';

% This will fail if output is shorter than cutOff (it shouldn't be)
output(aIdx,:) = outputSound;
output(vIdx,:) = outputLED+params.LEDOffset;

% Plot stimPlot
figure(figs.stim)
clf
subplot(2,1,1),
imagesc(output(chanMap(3,:)==2,:));
colorbar;
ylabel('Channel')
xlabel('Time')
title('LED stim')
subplot(2,1,2),
imagesc(output(chanMap(3,:)==1,:));
colorbar;
ylabel('Channel')
xlabel('Time')
title('Sound stim')
drawnow

% Put in buffer
PsychPortAudio('FillBuffer', AO.ao, output);

% Return stim structures (without.sound)
vStim = rmfield(vStim,'sound');
aStim = rmfield(aStim,'sound');

% Select resp figure now so this doesn't need to be done between stim end
% and response
figure(figs.resp)

disp(stimOrderRow)