function [tb, nR] = loadGaze(fn, fields)

a = load(fn);
struct = a.struct;
clear a

nF = numel(fields);
nR = size(struct.(fields{1}),2);

mat = NaN(nR, nF);

% Convert to mat
for f = 1:numel(fields)
   mat(:,f) = struct.(fields{f})'; 
end

% Convert to table 
% tb = table(struct.TS', [struct.NP0', struct.NP1'], struct.onSurf');
% tb.Properties.VariableNames = {'TS', 'NP', 'onSurf'};
% tb = table(struct.TS', struct.onSurf');
% tb.Properties.VariableNames = {'TS', 'onSurf'};

tb = array2table(mat);
tb.Properties.VariableNames = fields; 
