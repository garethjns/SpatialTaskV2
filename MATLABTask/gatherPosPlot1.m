function stats = gatherPosPlot1(stimLog, flag)

% Get unique, absolute positions - ie. -7.5 and 7.5 will be treated as the
% same
possFold = unique(abs(stimLog.Position(:,1)));

if flag == 1 % Gather ABSOLUTE difference data
    % posDataSubset.Diff already includes abosulte incongruency value
    % Find all unique values (will be nDiffs or fewer)
    diffs = unique(stimLog.Diff);
else % Gather RELATIVE difference data
    % In this case, don't take absolute of error (as in .Diff column) -
    % this folds space around visual location
    % Instead, recalulate error of auditory position relative to visual
    % psosition, where negative indicates back towards midline and
    % positive indicates outwards
    
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
end

% Create an empty matrix to store stats
nPoss = numel(possFold);
nDiffs = numel(unique(diffs));
stats = NaN(5, nDiffs+1, nPoss); 
% Row 1 = pos
% Row 2 = Difference between V and A location
% Row 3 = mean response error 
% Row 4 = std
% Row 5 = n

for pf = 1:nPoss % For each position...
        
    % This position is:
    pos = possFold(pf);
    
    % Get index of data where visual stimulus was at this position    
    pfIdx = abs(stimLog.Position(:,2)) == pos;
    % stimLog.Position contains [A, V] positions
    
    % Get the sub set of data (ie. the rows that correspond to the pfIdx
    % index)
    posDataSubset = stimLog(pfIdx,:);
    

    for d = 1:numel(diffs) % For each incongruency at this position...
        % (using whichever list of diffs calculated before first for loop)
        clear st
        
       % This diff is:
        dif = diffs(d);
        
        % Get index of this diff in subset, subdivided by direction if
        % requested
        if flag == 1 % Absolute: Use .Diff column as it is
            dIdx = abs(posDataSubset.Diff) == dif;
        else % Relative: Use recalcualted allDiffs
            dIdx = allDiffs(pfIdx) == dif;
        end
        
        % Get the mean, std, n etc of the measured error at this diff
        % The error difference between (actual position and response
        % location, in deg)
        % The data corresponding to this position/diff in this column is:
        data = posDataSubset.diffAngle(dIdx);
        
        % This data is a cell array that contains two values on each row;
        % one for the A response and one for the V response
        % We want the A response here. Exteact these:
        data = cell2mat(data);
        data = data(1:2:end);
        
        % Calcualte mean, std and n
        st(1,1) = pos;
        st(2,1) = dif;
        st(3,1) = mean(data);
        st(4,1) = std(data);
        st(5,1) = numel(data);
        
        % Save this data in to a simple matrix for plotting later
        stats(:,d,pf) = st;
    end
end