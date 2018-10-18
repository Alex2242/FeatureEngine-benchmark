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

function PutTimeStamp(TimeVector,Opt)
%PutTimeStamp(TimeVector,Opt)
% This function enables to put timestamps on the x axis of a figure
%
% Syntax: PutTimeStamp(TimeVector,Opt)
%
% Input:    
%      TimeVector - Spectrogram to plot
%      Opt - Structure containing options for the computation of LTSA
%
% Output:   
%      X axis with timestamps for a generated plot

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

if nargin<2
   Opt=[];
end

if ~isfield(Opt,'NberLabelX')
    Opt.NberLabelX=20;
end
if ~isfield(Opt,'TimeStampFormat')
    Opt.TimeStampFormat ='YYYY-mm-dd';
end

if ~isfield(Opt,'Change_Ytick')
    Opt.Change_Ytick=0;
end

sec2dtn = datenum(1982,08,01,00,00,01)-datenum(1982,08,01,00,00,00); dtn2sec = 1/sec2dtn;

DtnVal = TimeVector(1:floor(length(TimeVector) / Opt.NberLabelX):end,1);

sec2dtn = datenum(1982,08,01,00,00,01)-datenum(1982,08,01,00,00,00);
dtn2sec = 1/sec2dtn;
DayCo = (DtnVal(end,1)-DtnVal(1,1))*dtn2sec/3600/24;
if DayCo<2
    Opt.TimeStampFormat ='mm/dd HH:MM';
end

for xx=1:length(DtnVal)
    Xlab{xx} = datestr(DtnVal(xx),Opt.TimeStampFormat);
end

set(gco,'XData',TimeVector);
set(gca,'XTick',DtnVal)
set(gca,'XTickLabel',Xlab)
set(gca,'Xgrid','on')

if verLessThan('matlab','9.1')
    xticklabel_rotate(DtnVal,45,Xlab);
else
    xtickangle(45);
end

end
