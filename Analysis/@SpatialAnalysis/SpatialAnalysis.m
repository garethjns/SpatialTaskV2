classdef SpatialAnalysis < InitialAnalysis
    % Can be run from analysis.m
    %
    % Class to handle import and analysis of SpatialTaskV2 data.
    % Inherits previous (static) methods from InitialAnalysis and overloads
    % where needed. For example, .setPaths() and .import(). These
    % contain path and data templates for subjects so far, and should be
    % edited directly to specify what to import. Any data added or removed
    % after this point will not be inlucded in initalAnalysis script, but
    % will be here.
    %
    % TO DO:
    % 1) Sort graph presentation/sizing/titles out
    
    properties
        paths % Data, graph paths for this experiment
        GLMs % Struct with various GLM fits
        stats % Struct with dumps of graph data
        statsSubsets % Struct withs stats done on subsets
        integrators % Struct with "integrators" by model
    end
    
    methods
        
        function obj = SpatialAnalysis()
        end
        
        function [mn, mfn, mod] = setMod(obj, mn)
            switch mn
                case {'NLC', 'NonLinearCorr'}
                    mn = 'NonLinearCorr';
                    mfn = 'Corr';
                    mod = obj.GLMs.NonLinearCorr;
                case {'NLR', 'NonLinearResp'}
                    mn = 'NonLinearResp';
                    mfn = 'Resp';
                    mod = obj.GLMs.NonLinearResp;
                otherwise
                    disp('Invalid model.')
                    return
            end
        end
        
        obj = import(obj, eyePlot, debug, print)
        
        [obj, h] = accuracy(obj, plt, subs)
        
        [obj, h] = GLMNonLinearResp(obj)
        
        [obj, h] = GLMNonLinearCor(obj)
        
        obj = findIntegrators(obj, mn, thresh)
        
        [obj, h] = congruence(obj, plt, subs)
        
        h = plotCongruence(obj, stats, tit)
        
        h = dispIntergrators(obj, mn, plt)
        
        plotSingleSubjectSummary(obj, s, accFold, ...
            accRel, congRel, midErrorRel)

        [obj, h] = midError(obj, plt, subs)
        
        h = plotMidError(obj, dataA, dataV, tit, absX, normX, normY)

        [obj, h] = plotGroupSummary(obj, group, type, name)

        h = plotAccuracy(obj, summaryA, summaryV, posAx, tit)
        
    end
    
    methods (Static)
        % None
    end
    
end
