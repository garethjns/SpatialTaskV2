function [varStruct, loadOK] = loadHandler(fn, varargin)

% loadOK retuns 1 if successful, else the err
% VARS and FN are used if input vars and fn need to be modified

% Check fn isn't a string in a cell
if isa(fn, 'cell')
    fn = fn{:};
end
% Assign back to caller as load will be evaled there
% assignin('caller', 'FN', fn);
disp(['Loading: ', fn]);

% Check file exists
if ~exist(fn, 'file')
    disp('File Doesn''t exist')
    loadOK = 'File doesn''t exist';
    return
else
    % It does, continue
    disp('File exists')
end


% Check inputs
nInputs = numel(varargin);
if nInputs == 0
    % Load whole file
    vars = {'*'};
elseif nInputs == 1
    % Assume varargin{1} is single var or cell array of vars
    if isa(varargin{1}, 'cell') % Cell array
        vars = varargin{1};
    else % Assume string
        vars = varargin;
    end
else
    % Assume multiple string inputs
    vars = varargin;
end
% Assign vars back to calling workspace as VARS
% assignin('caller', 'VARS', vars);
disp('Vars:')
disp(vars);

loadOK = 0;
attempt = 1;

while loadOK == 0 && attempt<5
    try
        % Load straight in to calling workspace
        % evalin('caller', 'load(FN, VARS{:})');
        varStruct = load(fn, vars{:});
        loadOK = 1;
        disp('File loaded OK')
    catch err
        disp(err)
        disp('Failed to load, trying again')
        
        attempt = attempt + 1;
        
        if attempt == 5
             loadOK = err;
        end
        % Exists but failed to load
        % Corrupt??
    end
end
