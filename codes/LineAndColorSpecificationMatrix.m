%% Main contributors: Julien Bonnel, Dorian Cazau
function [LineSpecificationMatrix,ColorMatrixLabel,ColorMatrix] = LineAndColorSpecificationMatrix(NberColorInMap)

if nargin==0
   NberColorInMap=8;
end

LineSpecificationMatrix = {'-o','--','-.','-','-s','-d','-^','-+','-v','>','<','p','h'};
ColorMatrixLabel = {'b','g','m','r','y','k','r','b','m',};

ColorMatrix=jet(NberColorInMap);
