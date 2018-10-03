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

function FormatFigures(NameFig)

box on

h = get(0,'children');
scrsz = get(0,'ScreenSize');
set(h,'Position',[scrsz(1) scrsz(2) scrsz(3) scrsz(4)])

set(gcf,'color','w');

print(gcf,NameFig,'-dpng')
saveas(gcf,NameFig,'fig')

close(gcf)

end
