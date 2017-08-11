function dataT = gatherGLMCoeffs(GLMStats, targets, note)

eN = numel(fieldnames(GLMStats));

targets = string(targets);
nTar = numel(targets);


h1 = figure;
h2 = figure;

pl = 0;
for fn2 = targets
    pl = pl+1;
    % Might be 3 or 4 parameters, don't bother preallocating
    % dataT.(fn2.char()).coeffs = NaN(eN, 4);
    % dataT.(fn2.char()).pVals = NaN(eN, 4);
    
    for e = 1:eN
        fieldName = ['s', num2str(e)];
        
        
        dataT.(fn2.char()).coeffs(e,:) = ...
            GLMStats.(fieldName).(fn2.char()).Coefficients.Estimate';
        
        dataT.(fn2.char()).pVals(e,:) = ...
            GLMStats.(fieldName).(fn2.char()).Coefficients.pValue';
        
        disp(fieldName)
        disp( GLMStats.(fieldName).(fn2.char()))
        % disp(dataT.(fn2.char()).pVals(e,:))
        
        
        nCoeffs = size(dataT.(fn2.char()).coeffs,2)-1;
        coeffs = {'b', 'c', 'd'};
        
        
    end
    
    figure(h1)
    subplot(1,nTar,pl)
    bpData = dataT.(targets(pl).char()).coeffs(:,2:end);
    bpData = bpData(~isnan(bpData(:,1)),:);
    % NB: Won't work until n subs >1
    boxplot(bpData)
    title(GLMStats.(fieldName).(targets(pl).char()).Formula.char())
    x = gca;
    x.XTickLabels =  coeffs(1:nCoeffs);
    ylabel('Coeff Mag.')
    
    
    
    figure(h2)
    subplot(1,nTar,pl)
    bpData = dataT.(targets(pl).char()).pVals(:,2:end);
    bpData = bpData(~isnan(bpData(:,1)),:);
    boxplot(bpData)
    title(GLMStats.(fieldName).(targets(pl).char()).Formula.char)
    x = gca;
    x.XTickLabels = coeffs(1:nCoeffs);
    ylabel('Significance')
    
   
end

figure(h1)
suptitle('Coeffs (not inc. int.)')
figure(h2)
suptitle('Average pVals (not inc. int.)')

% figure
% subplot(1,2,1)
% boxplot(real(log(dataT.ACorr.coeffs)))
% ylim([-10, 1])
%
% subplot(1,2,2)
% boxplot(real(log(dataT.VCorr.coeffs)))
% ylim([-10, 1])
% suptitle('Log coeffs')

