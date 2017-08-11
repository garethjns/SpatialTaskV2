%% 2 way anova 
% APos (unfolded)
% Congruence (0 or 1)

% Dependent variable
y = allData.ACorrect; % Auditory response

% Independent variables
X1 = allData.Position(:,1); % Auditory position
X2 = allData.Diff == 0; % Congruence (binary)
X3 = allData.nEvents;

% Fit
[p, tbl, stats] = anovan(y, {X1, X2, X3}, ...
    'model', 'interaction', ...
    'varname', {'aPos', 'cong', 'rate'});
  
figure
[c, m, h, gnames] = multcompare(stats, 'Dimension', [1, 2]);


%% Subject averages first

t =  table(y, X1, X2, X3, allData.Subject, ...
    'VariableNames', {'aCorr', 'aPos', 'Cong', 'rate', 'Sub'});

summaryStats = grpstats(t, {'Sub', 'Cong', 'aPos', 'rate'});

[p, tbl, stats] = anovan(summaryStats.mean_aCorr, ...
    {summaryStats.Cong, summaryStats.aPos, summaryStats.rate}, ...
    'model', 'interaction', ...
    'varname', {'cong', 'aPos', 'rate'});
  
figure
[c, m, h, gnames] = multcompare(stats, 'Dimension', [1,3]);


%% Repeated measures version
% 
% t =  table(y, X1, X2, allData.Subject, ...
%     'VariableNames', {'aCorr', 'aPos', 'Cong', 'Sub'});
% 
% % With-subject variable
% rms = dataset([0,1], 'VarNames', {'aCorr'});
% 
% rm = fitrm(t, 'aCorr~aPos', 'WithinDesign', rms);
% ranovatbl = ranova(rm)


%% 2 way anova 
% APos (unfolded)
% Congruence (0 or 1)

% Dependent variable
y = allData.ACorrect;

% Independent variables
X1 = abs(allData.Position(:,1));
X2 = zeros(height(allData),1);
X2(allData.Diff==0,1) = 1;
X2(allData.Diff==15,1) = 2;
X2(allData.Diff==30,1) = 3;
X3 = allData.nEvents;

idx = allData.Diff<=30;
y = y(idx,1);
X1 = X1(idx,1);
X2 = X2(idx,1);
X3 = X3(idx,1);

% Fit
[p, tbl, stats] = anovan(y, {X1, X2, X3}, ...
    'model','interaction', 'varname', ...
    {'aPos', 'cong', 'rate'});

figure
[c, m, h, gnames] = multcompare(stats, 'Dimension', [1, 2]);


%% Subject averages first

t =  table(y, X1, X2, X3, allData.Subject(idx), ...
    'VariableNames', {'aCorr', 'aPos', 'Cong', 'rate', 'Sub'});

summaryStats = grpstats(t, {'Sub', 'Cong', 'aPos', 'rate'});

[p, tbl, stats] = anovan(summaryStats.mean_aCorr, ...
    {summaryStats.Cong, summaryStats.aPos, summaryStats.rate}, ...
    'model', 'interaction', ...
    'varname', {'cong', 'aPos', 'rate'});
  
figure
[c, m, h, gnames] = multcompare(stats, 'Dimension', [1, 3]);


%% 2 way anova 
% APos (unfolded)
% Congruence (0 or 1)

diff = 0-(abs(allData.Position(:,1)) - abs(allData.Position(:,2)));

% Dependent variable
y = abs(allData.ACorrect);

% Independent variables
X1 = abs(allData.Position(:,1));
X2 = diff;
X2(X2<0) = -1;
X2(X2==0) = 0;
X2(X2>0) = 1;

idx = (abs(X1)>7.5) & (abs(X1)<67.5);
y = y(idx);
X1 = X1(idx);
X2 = X2(idx);
X3 = X3(idx,1);

% Fit
[p, tbl, stats] = anovan(y, {X1, X2, X3}, ...
    'model','interaction', 'varname', ...
    {'cong','aPos', 'rate'});

[c, m, h, gnames] = multcompare(stats, 'Dimension', [1, 2]);


%% Subject averages first

t =  table(y, X1, X2, allData.Subject(idx), ...
    'VariableNames', {'aCorr', 'aPos', 'Cong', 'Sub'});

summaryStats = grpstats(t, {'Sub', 'Cong', 'aPos'});

[p, tbl, stats] = anovan(summaryStats.mean_aCorr, ...
    {summaryStats.Cong, summaryStats.aPos}, ...
    'model', 'interaction', ...
    'varname', {'cong', 'aPos'});
  
figure
[c, m, h, gnames] = multcompare(stats, 'Dimension', [1, 2]);


