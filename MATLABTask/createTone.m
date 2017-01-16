% Generate tone
% Either (freq, amp, dur, Fs, rise)
% Or params structure

function [t, tone] = createTone(varargin)

if length(varargin) == 1 % Assume params structure supplied
    if isfield(varargin{1}, 'freq')
        freq = varargin{1}.freq;
    else
        freq = 2351;
    end
    if isfield(varargin{1}, 'amp')
        amp = varargin{1}.amp;
    else
        amp = 0.1;
    end
    if isfield(varargin{1}, 'duration')
        dur = varargin{1}.duration;
    else
        dur = 1;
    end
    if isfield(varargin{1}, 'Fs')
        Fs = varargin{1}.Fs;
    else
        Fs = 48000;
    end
    if isfield(varargin{1}, 'riseTime')
        rise = varargin{1}.riseTime;
    else
        rise = 0.02;
    end
    
else % Assume individual parameters specified
    % (freq, amp, dur, Fs, rise)
    freq = varargin{1};
    amp = varargin{2};
    
    dur = varargin{3};
    Fs = varargin{4};
    rise = varargin{5};
end

% Generate time vector
T = 1/Fs;
L = dur*Fs;
t = (0:L-1)*T;

% Generate tone
tone = amp * sin(2*pi*freq*t);

% Add rise and fall
rise = ceil(rise*Fs);
tone(1:rise) = tone(1:rise).*cos(linspace(-pi/2,0,rise));
tone(end-(rise-1):end) = ...
    tone(end-(rise-1):end).*cos(linspace(0,pi/2,rise));