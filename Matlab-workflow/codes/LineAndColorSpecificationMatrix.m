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

function [LineSpecificationMatrix,ColorMatrixLabel,ColorMatrix] = LineAndColorSpecificationMatrix(NberColorInMap)
%[LineSpecificationMatrix,ColorMatrixLabel,ColorMatrix] = LineAndColorSpecificationMatrix(NberColorInMap)
% This function enables to create scattering plots and histograms of each
% variable available in dataMatrix against each other
%
% Syntax: [LineSpecificationMatrix,ColorMatrixLabel,ColorMatrix] = LineAndColorSpecificationMatrix(NberColorInMap)
%
% Input:    
%      NberColorInMap - colors to use
%
% Output:   
%      LineSpecificationMatrix - Matrix containing type of plots line
%      ColorMatrixLabel - Matrix containing labels of each color
%      ColorMatrix - Matrix containing colors to use
%
% Example1 :  [LineSpecificationMatrix,ColorMatrixLabel,ColorMatrix] = LineAndColorSpecificationMatrix()
% If no input is given to the function only 8 colors will be used
%
% Example2 :  [LineSpecificationMatrix,ColorMatrixLabel,ColorMatrix] = LineAndColorSpecificationMatrix(9)
% 9 types of line, colors will be used

% Note : 
%
% Author: Julien Bonnel, Dorian Cazau
% email: 
% date of creation: 
% Modified [date]
%   [COMMENTS ON MODIFICATIONS]

% Other m-files required: none
% Subfunctions: none
% MAT-files required: none


if nargin==0
   NberColorInMap=8;
end

LineSpecificationMatrix = {'-o','--','-.','-','-s','-d','-^','-+','-v','>','<','p','h'};
ColorMatrixLabel = {'b','g','m','r','y','k','r','b','m',};

ColorMatrix=jet(NberColorInMap);
