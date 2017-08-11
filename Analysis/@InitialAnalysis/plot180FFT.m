function plot180FFT(x, ts, tit)

if ~exist('tit', 'var')
    tit = '';
end

Y = fft(ts);
L = round(max(x)-min(x));
Fs = length(ts)/L;
T = 1/Fs;
t = (0:L-1)*T;

P2 = abs(Y/L);
P1 = P2(1:round(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);

f = t(1:length(P1));
plot(f, P1) 
xlabel('Response bin size, deg')
ylabel('|P1(f)|')
title(tit)
