% Test each speaker/LED using Churchland stimuli or tones

%% Initialise MOTU
rng('shuffle');
rng('shuffle');

params.startTime = datestr(now);
dirs.startTime = params.startTime;

mParams = setParams('MOTU');
AO = initMOTU(mParams);

%% Cycle speakers

csParams = setParams('QuickTone');
csParams.reps = 30;
csParams.chans = 1:12;
csParams.indicateLED = 1;

[t, tone] = createTone(csParams);
plot(t, tone)

outputCycleSpeakers(AO, csParams, tone);

%% Cycle speakers - mirrored

% Set params
csParams = setParams('QuickTone');
csParams.reps = 1;
csParams.chans = 1:12;
csParams.indicateLED = 1;

% Generate tone
[t, tone] = createTone(csParams);
plot(t, tone)

% Play
outputMirroredPair(AO, csParams, tone)
