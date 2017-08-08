%% 2 way anova 
% APos (unfolded)
% Congruence (0 or 1)

% Dependent variable
y = allData.ACorrect; % Auditory response

% Independent variables
X1 = allData.Position(:,1); % Auditory position
X2 = allData.Diff == 0; % Congruence (binary)

% Fit
[p, tbl, stats] = anovan(y, {X1, X2}, ...
    'model', 'interaction', ...
    'varname', {'aPos', 'cong'});
  

[c, m, h, gnames] = multcompare(stats, 'Dimension', [1,2]);


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

y = y(allData.Diff<=30,1);
X1 = X1(allData.Diff<=30,1);
X2 = X2(allData.Diff<=30,1);

% Fit
[p, tbl, stats] = anovan(y, {X2, X1}, ...
    'model','interaction', 'varname', ...
    {'cong','aPos'});

[c, m, h, gnames] = multcompare(stats, 'Dimension', [1]);


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

% Fit
[p, tbl, stats] = anovan(y, {X2, X1}, ...
    'model','interaction', 'varname', ...
    {'cong','aPos'});

[c, m, h, gnames] = multcompare(stats, 'Dimension', [1,2]);
