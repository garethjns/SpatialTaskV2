function [st1, st2] = gatherAPCvsVL(stimLog, flag)
% Fold space Gather data for auditory % correct (location response correct)
% as a function of visual position
% Averages over auditory location
% Flag == 1 use absolute difference data (between V loc and A loc at each V
% position)
% Flag == 2 Use relative instead of absolute for above

% Get unique, absolute positions - ie. -7.5 and 7.5 will be treated as the
% same
% possFold = unique(abs(stimLog.Position(:,1)));
possList = [-82.5, -67.5, -52.5, -37.5, -22.5, -7.5, ...
    7.5, 22.5, 37.5, 52.5, 67.5, 82.5];
% Actually, use this version instead: Will be using .respBin and .PosBinLog
% fields with possFold here, which are 2x12 and include unused 82.5
% position (which obviously doesn't show up in unique(positions)).
possFold = possList(7:12);

% In this version, everything is relative to auditory location rather than
% visual
% If using absolute differences, need to fold space around A not V
% Assume same convention - negative is back towards midline
% So A with V diff of -15 is V 15deg back towards midline
% This block calculates available diffs, same whether folding around A or V
if flag == 1 % Gather ABSOLUTE difference data
    % posDataSubset.Diff already includes abosulte incongruency value
    % Find all unique values (will be nDiffs or fewer)
    diffs = unique(stimLog.Diff);
    % Don't need to recalucalte diffs column
    AVDiffs = stimLog.Diff;
else % Gather RELATIVE difference data
    % In this case, don't take absolute of error (as in .Diff column) -
    % this folds space around visual location
    % Instead, recalulate error of auditory position relative to visual
    % psosition, where negative indicates back towards midline and
    % positive indicates outwards
    
    
    % Do usual calucaltion to get unique diffs
    % Get all the absolute visual positions (still folding overall
    % space in half)
    vp = abs(stimLog.Position(:,2));
    % Get all the absolute auditory positions
    ap = abs(stimLog.Position(:,1));
    
    % Recaulcaute the between these (not the abs difference)
    allDiffs = abs(vp) - abs(ap);
    % Then flip the sign, so negative is back towards midline
    allDiffs = 0 - allDiffs;
    
    % And just keep the unique ones
    diffs = unique(allDiffs);
    
    
    % Also calculate new relativee difference column
    % Anchored to A, neg is V back to midline
    ap = stimLog.Position(:,2);
    vp = stimLog.Position(:,1);
    
    AVDiffs = abs(ap) - abs(vp);
    
end


%% Calculate % accuracy averaging over A position

nDiffs = numel(unique(AVDiffs));
% Position
% Diff
% PC
% PC std
% Error
% Error std
% n
st1 = NaN(7, nDiffs);

% For all differences
for d = 1:nDiffs
    % Get auditory location % accuracy
    dIdx = AVDiffs == diffs(d);
    
    % Get subset
    data = stimLog(dIdx,:);
    
    [cor, err, nData] = getCEFromSubset(data, possFold);
    
    % PC cor
    PC = sum(cor)/nData;
    
    % Error
    % If flag==1, space is folded around A location
    % Therefore, error should not have a direction either
    if flag == 1
        error = abs(err);
    elseif flag == 2
        error = err;
    end
    
    
    % Save stats
    st1(1,d) = 111; % Average pos
    st1(2,d) = diffs(d);
    st1(3,d) = PC;
    st1(4,d) = std(cor);
    st1(5,d) = mean(error);
    st1(6,d) = std(error);
    st1(7,d) = nData;
end


%% Calculate % accuracy for each A position

nPoss = numel(possFold)-1;
% Minus 1 because posFold contains unused 82.5 position in this
% function

nDiffs = numel(unique(AVDiffs));
% Position
% Diff
% PC
% PC std
% Error
% Error std
% n
st2 = NaN(7, nDiffs, nPoss-1);

% For each A position
for p = 1:nPoss
    
    pIdx = abs(stimLog.Position(:,1)) == possFold(p);
    
    % For all differences
    for d = 1:nDiffs
        % Get auditory location % accuracy
        dIdx = AVDiffs == diffs(d);
        
        % Get subset
        data = stimLog(dIdx & pIdx,:);
        
        [cor, err, nData] = getCEFromSubset(data, possFold);
        
        % PC cor
        PC = sum(cor)/nData;
        
        % Error
        % If flag==1, space is folded around A location
        % Therefore, error should not have a direction either
        if flag == 1
            error = abs(err);
        elseif flag == 2
            error = err;
        end
        
        
        % Save stats
        st2(1,d,p) = possFold(p);
        st2(2,d,p) = diffs(d);
        st2(3,d,p) = PC;
        st2(4,d,p) = std(cor);
        st2(5,d,p) = mean(error);
        st2(6,d,p) = std(error);
        st2(7,d,p) = nData;
    end
end

%% Return stats

% stats.PosAv = st1;
% stats.PerPos = st2;


function [cor, error, nData] = getCEFromSubset(data, possFold)
% Return to A accuracy (resp to pos)
% PC correct and error

% There's no correct column. Need to compare .respBinAN to .PosBinLog
% Each is 2x12, first row is aud
% Also want to get the siged error
nData = height(data);
cor = NaN(nData,1);
error = NaN(nData,1);
for r = 1:nData
    resp = data(r,:).respBinAN{1,:}(1,:);
    pos = data(r,:).PosBinLog{1,:}(1,:);
    
    cor(r) = all(resp==pos);
    
    % Error between response and position
    % Could either be difference in angle (.Angle and diffAngle)
    % Or difference between bins
    % Let's go with difference between bins for now, as everything else has
    % been binned
    
    % Remember, possFold is folded, resp and pos are not
    % Fold resp and pos
    % Resp and pos run -67:15:67
    % PossFold is positive, and represents right half of space
    % So need to fold resp and pos, left on to right.
    resp = any([resp(6:-1:1); resp(7:12)]);
    pos = any([pos(6:-1:1); pos(7:12)]);
    
    respBin = possFold(resp==1);
    posBin = possFold(pos==1);
    
    % Calculate so - is back towards midline
    error(r) = respBin-posBin;
end