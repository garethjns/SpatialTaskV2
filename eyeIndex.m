function OK = eyeIndex(data, thresh)

n = height(data);
if all(isnan(data.onSurfProp))
    % This is subject with no eye data
    if thresh>0
        % If thresh>0, remove all
        OK = false(n,1);
    else
        % If index is 0, keep
        OK = true(n,1);
    end
else
    % This subject has eye data
    % Apply thrsh
    OK = data.onSurfProp>=thresh;
end
