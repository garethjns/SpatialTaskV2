function [OK, rs1, rs2] = eyeIndex(data, osp, thresh)

n = height(data);
if all(isnan(data.(osp)))
    % This is subject with no eye data
    rs1 = 'No eye data';
    if thresh>0
        % If thresh>0, remove all
        OK = false(n,1);
        rs2 = 'Thresh >0, including none';
    else
        % If thresh is 0, keep all
        OK = true(n,1);
        rs2 = 'Thresh 0, including all';
    end
else
    
    % This subject has eye data
    % Apply thresh
    OK = data.(osp)>=thresh;
    
    rs1 = [num2str(sum(~isnan(data.(osp)))), ...
        '/', num2str(n), ' trials have eye data'];
    
    rs2 = [num2str(sum(OK)), '/', num2str(n), ' pass thresh'];
end


