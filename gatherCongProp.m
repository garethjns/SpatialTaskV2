function stats = gatherCongProp(stimLog, flag, flag2)
% Flag == 1 use absolute difference data (between V loc and A loc at each V
% position)
% Flag == 2 Use relative instead of absolute for above
% Flag2 == 1 When collecting proportion of congruent responses, assume V 
% location is the actual location V came from
% Flag2 == 2 Instead, use the "percieved" V location(ie where the response
% was) to judge if subject marked these congruent.
% This makes more sense? Even if wrong location was pressed, subject would
% have pressed same location on screen twice. So should include this as a
% congruent response even if the wrong location was pressed

% Get unique, absolute positions - ie. -7.5 and 7.5 will be treated as the
% same
possFold = unique(abs(stimLog.Position(:,1)));
possList = [-82.5, -67.5, -52.5, -37.5, -22.5, -7.5, ...
    7.5, 22.5, 37.5, 52.5, 67.5, 82.5];

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
stats = NaN(6, nDiffs+1, nPoss); 
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
        
        % Dif == 0 is congruent condition
        
        
        % Get the already binned data
        switch flag2
            case 1
                % Using A marked as coming from actual V location
                % In this case need to get position angle and bin
                data = posDataSubset.Position(dIdx,:);
                respData = posDataSubset.respBinAN(dIdx);
                % Bin
                % 2x12 Logical, A on row 1
                n = size(data,1);
                bData = cell(n, 1);
                for r = 1:n
                    bData{r} = zeros(2,12);
                    % bData{r}(1,:) = data(r,1) == possList;
                    % Bin visual positions - get A from respBin
                    bData{r}(2,:) = data(r,2) == possList;
                    % And get already binned A response
                    bData{r}(1,:) = respData{r}(1,:);
                end
                
                data = bData;
                clear respData bData
            case 2
                % Using A marked as coming from reported V location
                data = posDataSubset.respBinAN(dIdx);
        end
        
        % This data is a cell array that contains two 2x12 logical values
        % A = row 1, V = row 2
        % Was this response congruent?
        n = size(data,1);
        congLog = NaN(n, 1);
        for r = 1:n
            congLog(r) = sum(all(data{r},1));
        end
        
        congProp = sum(congLog)/length(congLog);
        
        
        % Calculate proportion marked as congruent
        
        st(1,1) = pos;
        st(2,1) = dif;
        st(3,1) = congProp;
        st(4,1) = std(congLog);
        st(5,1) = sum(congLog); 
        st(6,1) = numel(data);
        
        
        % Save this data in to a simple matrix for plotting later
        stats(:,d,pf) = st;
    end
end