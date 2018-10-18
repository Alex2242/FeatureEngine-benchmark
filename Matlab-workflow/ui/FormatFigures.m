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

function FormatFigures(NameFig)
%FormatFigures(NameFig)
% This function enables to save the figures previously generated with a
% specific name
%
% Syntax: FormatFigures(NameFig)
%
% Input:    
%      NameFig       - Name of the figure to save, str
%
% Output:  None - Figures are saved with the name
% NameFig
%
% Example:  FormatFigure('SpectrogramToSave')

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

box on

h = get(0,'children');
scrsz = get(0,'ScreenSize');
set(h,'Position',[scrsz(1) scrsz(2) scrsz(3) scrsz(4)])

set(gcf,'color','w');

print(gcf,NameFig,'-dpng')
saveas(gcf,NameFig,'fig')

close(gcf)

end
