function plotSingleSubjectSummary(obj, s, accFold, ...
    accRel, congRel, midErrorRel)
% Plot the accuray, congruence judgement, midHist for one
% subject
% Doesn't do stats, error bars are within-subject
% Use .accuracy etc with restricted subsets to do
% across-subject stats.

% Set subject fieldname
sub = ['s', num2str(s)];


%% Accuracy plot
% Options
if ~exist('accRel', 'var') || isempty(accRel)
    accRel = true;
end
if ~exist('accFold', 'var') || isempty(accFold)
    accFold = true;
end

% Plot
if accFold && accRel
    tit = ['S', num2str(s), ...
        ': Response accuracy - Rel'];
    statsA = obj.stats.accuracy.AcFoldRel.data.(sub);
    statsV = obj.stats.accuracy.VcFoldRel.data.(sub);
    obj.plotAccs(statsA, statsV, tit)
elseif accFold && ~accRel
    tit = ['S', num2str(s), ...
        ': Response accuracy - Abs'];
    statsA = obj.stats.accuracy.AcFoldAbs.data.(sub);
    statsV = obj.stats.accuracy.VcFoldAbs.data.(sub);
    obj.plotAccs(statsA, statsV, tit)
elseif ~accFold && accRel
    tit = ['S', num2str(s), ...
        ': Response accuracy - Rel'];
    statsA = obj.stats.accuracy.AcRel.data.(sub);
    statsV = obj.stats.accuracy.VcRel.data.(sub);
    obj.plotAccs(statsA, statsV, tit)
elseif ~accFold && ~accRel
    tit = ['S', num2str(s), ...
        ': Response accuracy - Abs'];
    statsA = obj.stats.accuracy.AcAbs.data.(sub);
    statsV = obj.stats.accuracy.VcAbs.data.(sub);
    obj.plotAccs(statsA, statsV, tit)
end


%% Congruence judgement plot

if ~exist('congRel', 'var') || isempty(congRel)
    congRel = true;
end

if congRel
    st = obj.stats.congruence.rel.(sub);
    tit = ['S', num2str(s), ...
        ': Proportion congruent responses,' ...
        'relative diff between V and A'];
else
    st = obj.stats.congruence.abs.(sub);
    tit = ['S', num2str(s), ...
        ': Proportion congruent responses,' ...
        'abs diff between V and A'];
end


%% MidError plot

if ~exist('midErrorRel', 'var') || isempty(midErrorRel)
    midErrorRel = true;
end

obj.plotCongProp(st, tit);
A = obj.stats.midError.(sub).A;
V = obj.stats.midError.(sub).V;

if midErrorRel
    abs = false;
else
    abs = true;
end

abs = false;
tit = 'All subjects, xNorm, yNorm';
obj.plotMidHist(A, V, tit, abs);
SpatialAnalysis.ng('1024NE');

abs = true;
tit = 'All subjects, xNorm, yNorm';
obj.plotMidHist(A, V, tit, abs);
SpatialAnalysis.ng('1024NE');
