function [AO, chanMap] = initHW(params)
% Get the chanMap2 from initMOTU. Retrun in AO.chanMap and chanMap

AO = initMOTU(params);

chanMap = params.chanMap2;
AO.chanMap = chanMap;
