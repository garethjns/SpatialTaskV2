function stats = fitGLM4(allData)

% AResp = a+ b*ALoc + c*Vloc
if ~isempty(allData)
    nRows = height(allData);
    
    data = table;
    data.AResp = NaN(nRows,1);
    data.VResp = NaN(nRows,1);
    for r = 1:nRows
        % A
        respBin = allData.respBinAN{r}(1,:);
        % Mirror
        respBin = [respBin(6:-1:1); respBin(7:12)];
        % Reduce
        respBin = any(respBin);
        % Find and convert to postion
        data.AResp(r,1) = find(respBin)*15+7.5;
        
        % V
        respBin = allData.respBinAN{r}(2,:);
        % Mirror
        respBin = [respBin(6:-1:1); respBin(7:12)];
        % Reduce
        respBin = any(respBin);
        % Find and convert to postion
        data.VResp(r,1) = find(respBin)*15+7.5;
    end
    
    incIdx = abs(data.AResp-data.VResp)==15;
    data = data(incIdx,:);
    
    data.APos = abs(allData.Position(incIdx,1));
    data.VPos = abs(allData.Position(incIdx,2));
    
    
    % CorAud = a + b*ALoc + c*VLoc + d*ALoc*VLoc
    mdlSpec = 'AResp ~ APos*VPos';
    mdl1 = fitglm(data, mdlSpec, 'Distribution', 'normal');
    
    % CorAud = a + b*ALoc + c*VLoc + d*ALoc*VLoc
    mdlSpec = 'VResp ~ APos*VPos';
    mdl2 = fitglm(data, mdlSpec, 'Distribution', 'normal');
    
    stats.AResp = mdl1;
    stats.VResp = mdl2;
    
else
    stats.AResp.Coefficients.Estimate = [NaN, NaN, NaN, NaN];
    stats.AResp.Coefficients.pValue = [NaN, NaN, NaN, NaN];
    stats.VResp.Coefficients.Estimate = [NaN, NaN, NaN, NaN];
    stats.VResp.Coefficients.pValue = [NaN, NaN, NaN, NaN];
end