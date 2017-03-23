function stats = fitGLM2(allData)

data = table;
data.ACorrect = allData.ACorrect;
data.VCorrect = allData.VCorrect;
data.APos = abs(allData.Position(:,1));
data.VPos = abs(allData.Position(:,2));

if ~isempty(data)
    % CorAud = a + b*ALoc + c*VLoc + d*ALoc*VLoc
    mdlSpec = 'ACorrect ~ APos*VPos';
    mdl1 = fitglm(data, mdlSpec, 'Distribution', 'binomial', 'Link', 'logit');
    
    % CorAud = a + b*ALoc + c*VLoc + d*ALoc*VLoc
    mdlSpec = 'VCorrect ~ APos*VPos';
    mdl2 = fitglm(data, mdlSpec, 'Distribution', 'binomial', 'Link', 'logit');
    
    stats.ACorr = mdl1;
    stats.VCorr = mdl2;
    
else
    stats.ACorr.Coefficients.Estimate = [NaN, NaN, NaN, NaN];
    stats.ACorr.Coefficients.pValue = [NaN, NaN, NaN, NaN];
    stats.VCorr.Coefficients.Estimate = [NaN, NaN, NaN, NaN];
    stats.VCorr.Coefficients.pValue = [NaN, NaN, NaN, NaN];
end
