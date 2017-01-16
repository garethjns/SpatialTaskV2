function [tb, n] = loadGaze(fn)

a = load(fn);
struct = a.struct;

tb = table(struct.TS', [struct.NP0', struct.NP1'], struct.onSurf');
tb.Properties.VariableNames = {'TS', 'NP', 'onSurf'};

n = height(tb);