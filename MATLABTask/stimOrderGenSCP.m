function [stimOrder, n] = stimOrderGenSCP(params)
% Generate and reandomise stimulus blocks
% Single block contains all possible stim combinations, minus litiations
% set in params
% Shuffled in blocks, then combine up to number of requested blocks
% Returns order of stim to present, and actual number

% Create all possibilities
all = combvec(params.Positions, ....
    params.Positions, ....
    params.Rates)';

% Label type in col 1
block = [zeros(size(all,1), 1), all];
% Congruent - same pos in both cols
block(block(:,2) == block(:,3),1) = 1;
% Incongruent - different pos in each col
block(block(:,2) ~= block(:,3),1) = 2;

% Remove types not required
keepIdx = zeros(size(block,1),1);
for t = 1:numel(params.Types)
    keepIdx = keepIdx + block(:,1)==params.Types(t);
end
block = block(keepIdx,:);

% If type 2 (incongruent) is present
if any(params.Types == 2)
    % Remove incons that cross midline
    rmIdx = ~((block(:,2)>0 & block(:,3)>0) ...
        | (block(:,2)<0 & block(:,3)<0));
    block(rmIdx,:) = [];
    
    % Remove incons above maximum (relative) specified in params
    rmIdx = abs(block(:,2) - block(:,3))>params.InconLimitMax;
    block(rmIdx,:) = [];
    % Remove incons below minimum (relative) specified in params
    % (but not 0!)
    rmIdx = (abs(block(:,2) - block(:,3))<params.InconLimitMin) ...
        & (abs(block(:,2) - block(:,3)) ~= 0);
    block(rmIdx,:) = [];
    
end

% Remove all positions that are outside maximum absolute extremity
rmIdx = abs(block(:,2))>params.PositionMax ...
    |  abs(block(:,3))>params.PositionMax;
block(rmIdx,:) = [];

% Other params
block(block(:,2)<0,5) = 1; % Side, left
block(block(:,2)>0,5) = 2; % Side, right
block(:,6) = abs(block(:,2) - block(:,3)); % Diff
block(:,7) = params.duration; % Duration,

% Rep up to nBlocks, and shuffle in blocks
bs = size(block, 1);
blocks = NaN(bs*params.nBlocks, 7);
for nb = 1:params.nBlocks
    % For each block, shuffle and add to blocks
    idx = nb*bs-(bs-1):nb*bs;
    shuffIdx = Shuffle(idx);
    blocks(idx, :) = block(shuffIdx-idx(1)+1,:);
end

% Convert to a nice table
vars = { ...
   'Type', '1 = Con, 2 = Incon'; ...
   'Position', '[A, V]'; ...
   'Diff', 'Absoloute difference'; ...
   'nEvents', 'Number of events in each modality'; ...
   'Duration', 'Duration ms'; ...
   'Side', 'Side of presentation 1 = left, 2 = right';
    };

stimOrder = table(blocks(:,1), blocks(:,2:3), ...
    blocks(:,6), blocks(:,4), blocks(:,7), blocks(:,5));
stimOrder.Properties.VariableNames = vars(:,1);
stimOrder.Properties.VariableDescriptions = vars(:,2);

% Return actual number of total stim
n = height(stimOrder);