function [OK, rs1, rs2] = eyeIndex(data, osp, thresh1, thresh2)
% Thresh1 applies where there is eyedata, thresh2 where there isn't.

n = height(data);
if all(isnan(data.(osp)))
    
    % This is subject with no eye data
    rs1 = 'No eye data';
    if thresh2
        % If thresh2 is true, keep all
        OK = true(n,1);
        rs2 = ['Thresh1 = true, including ', ...
            num2str(sum(OK)), '/', num2str(n)];
    else
        % If thresh>0, remove all
        OK = false(n,1);
        rs2 = ['Thresh2 = false, including ', ...
            num2str(sum(OK)), '/', num2str(n)];
    end
    
else
    
    % This subject has eye data
    % Apply thresh
    OK = data.(osp) >= thresh1;
    
    rs1 = [num2str(sum(~isnan(data.(osp)))), ...
        '/', num2str(n), ' trials have eye data'];
    
    rs2 = [num2str(sum(OK)), '/', num2str(n), ' pass thresh'];
    
end
