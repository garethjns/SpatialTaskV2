function saveOK = saveHandler(fn, safeSave, mode, varargin)

% Save handler saves file in fn with vars specified in vars
% If safeSave is on, it then checks file can be loaded using loadHandler
% If it can't it tries to save again
% Returns saveOK = 1 after testing
% If mode == 3 use '-struct' to save AND append
% If mode == 2 use '-struct' to save (no append)
% If mode is 1, appends if file exists (use '-append', no '-struct')
% If append is 0, writes a new file regardless of whether file already
% exists(ie. no '-append', or '-struct')


% Check fn isn't a string in a cell
if isa(fn, 'cell')
    fn = fn{:};
end
% Assign back to caller as load will be evaled there
assignin('caller', 'FN', fn);
disp(['Saving: ', fn]);

% Check file exists
if exist(fn, 'file') && mode == 0
    disp('WARNING: Overwritng existing file')
    mode = 0;
elseif exist(fn, 'file') && mode == 1
    disp('Appending to existing file')
    mode = 1;
elseif exist(fn, 'file') && mode == 2
    disp('WARNING: Overwriting existing file (''-struct'' mode)')
    mode = 2;
elseif exist(fn, 'file') && mode == 3
    disp('Appending to existing file (''-struct'' mode)')
    mode = 2;
else
    % It does, continue
    disp('Saving new file')
    mode = 0;
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
    elseif isa(varargin{1}, 'struct')
        % Is a structure, doesn't matter what ap is here
        vars = varargin{1};
    else % Assume string
        vars = varargin;
    end
else
    % Assume multiple string inputs
    vars = varargin;
end
% Assign vars back to calling workspace as VARS
assignin('caller', 'VARS', vars);
disp('Vars:')
disp(vars);

%% Now save
saved = 0;
loadOK = 0;
saveAttempt = 1;

if safeSave
    loadAttempt = 1;
    
    while ~(loadOK == 1) && loadAttempt<5
        
        while ~(saved == 1) && saveAttempt<5
            disp('Attempting to save')
            try
                switch mode
                    case 0 % Normal save
                        evalin('caller', 'save(FN, VARS{:})');
                    case 1 % Append save
                        evalin('caller', 'save(FN, VARS{:}, ''-append'')');
                    case 2 % Struct save: Data is in this workspace
                        save(fn, '-struct', 'vars')
                    case 3 % Struct save: Data is in this workspace
                        save(fn, '-struct', 'vars', '-append')
                end
                
                saved = 1;
                disp('Saved, not yet verified')
            catch err
                % Save totally failed, try again
                disp(err)
                disp('Failed to save, trying again')
                
                saveAttempt = saveAttempt + 1;
                
                if saveAttempt == 5
                    % Give up and return error
                    saved = err;
                    
                    % Totally failed so it's not going to load, not worth
                    % trying
                    % Skip out of load loop too and just return error
                    break
                end
            end
        end
        
        if ~(saved == 1)
            disp('Totally failed to save')
            keyboard
            break
            % Total failure, break out of load attempt loop
        else
            disp('Checking loading.... ')
            % OK, now save appears to have worked
            % Try and load whole fucking file
            [ld, loadOK] = loadHandler(fn);
            
            if ~(loadOK==1)
                % Failed, try eveything again
                disp('Loading totally failed')
                loadAttempt = loadAttempt + 1;
                saved = 0;
                saveAttempt = 1;
                % Going back inside save loop....
            else
                saved = 1;
                disp('Saved and verified')
                % Saved and loaded ok, should now leave both loops
            end
        end
    end
    
else
    % Save without checking load ok - but still try again if it totally
    % fails
    while ~(saved == 1) && saveAttempt<5
        try
            switch mode
                case 0
                    evalin('caller', 'save(FN, VARS{:})');
                case 1
                    evalin('caller', 'save(FN, VARS{:}, ''-append'')');
                case 2 % Struct save: Data is in this workspace
                    save(fn, '-struct', 'vars')
                case 3 % Struct save: Data is in this workspace
                    save(fn, '-struct', 'vars', '-append')
            end
            saved = 'Maybe';
            disp('Saved, not yet verified')
        catch err
            % Save totally failed, try again
            disp(err)
            disp('Failed to save, trying again')
            
            saveAttempt = saveAttempt + 1;
            
            if saveAttempt == 5
                % Give up and return error
                saved = err;
                disp('Totally failed to save')
                keyboard
            end
        end
    end
    
end

saveOK = saved;
