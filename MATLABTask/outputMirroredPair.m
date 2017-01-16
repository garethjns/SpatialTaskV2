function outputMirroredPair(AO, params, tone)

WaitSecs(params.wait);

chans = 1:round(max(params.chans)/2);
L = params.duration*params.Fs;

for r = 1:params.reps
    disp(['Rep: ', num2str(r), '/', num2str(params.reps)])
    for c = chans
        output = zeros(24, L);
        
        op = max(params.chans)-(c-1);
        
        disp(['Playing ', num2str(c), ...
            ' | ', num2str(op)])
        
        % Generate paired sound output
        outputSound = zeros(12, L);
        outputSound(c, :) = tone;
        outputSound(op, :) = tone;
        % Clip
        if any(outputSound>params.soundMax)
            disp('Warning: Clipping sound')
        end
        outputSound(outputSound>params.soundMax) = params.soundMax;
        
        % Generate indicate LED, if on
        outputLED = zeros(12, L);
        if params.indicateLED
            outputLED(c,:) = 0.3 + params.LEDOffset;
            outputLED(op,:) = 0.3 + params.LEDOffset;
            % Clip
            if any(outputLED>params.LEDMax)
                disp('Warning: Clipping LED')
            end
        end
        outputLED(outputLED>params.LEDMax) = params.LEDMax;
        
        % Map to main output
        output(params.chanMap(3,:)==2,:) = outputLED;
        output(params.chanMap(3,:)==1,:) = outputSound;
        
        % Play
        PsychPortAudio('FillBuffer', AO.ao, output);
        PsychPortAudio('Start', AO.ao);
        WaitSecs(params.duration + 1);
        
    end
end