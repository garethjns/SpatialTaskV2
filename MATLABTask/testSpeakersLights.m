clear AO
params = setParams('MOTU');
AO = initHW(params);

[~, tone] = createTone(2000);
params.reps = 10;
params.wait = 2;
params.chans = 1:12;
params.duration = 1;
params.indicateLED = 1;
outputCycleSpeakers(AO, params, tone)