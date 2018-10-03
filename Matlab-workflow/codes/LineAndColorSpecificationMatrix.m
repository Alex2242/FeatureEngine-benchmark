% Copyright (C) 2017-2018 Project-ODE
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% Main contributors: Julien Bonnel, Dorian Cazau, Paul Nguyen HD

function [LineSpecificationMatrix,ColorMatrixLabel,ColorMatrix] = LineAndColorSpecificationMatrix(NberColorInMap)

if nargin==0
   NberColorInMap=8;
end

LineSpecificationMatrix = {'-o','--','-.','-','-s','-d','-^','-+','-v','>','<','p','h'};
ColorMatrixLabel = {'b','g','m','r','y','k','r','b','m',};

ColorMatrix=jet(NberColorInMap);
