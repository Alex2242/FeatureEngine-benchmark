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

% Main contributors: Julien Bonnel, Dorian Cazau

function gplotmatrix_jb(dataMatrix, vecIndex, names)

n_response=length(vecIndex);
iplot=1;
for mm=1:n_response
    for nn=1:n_response
        if mm==nn
            subplot(n_response,n_response,iplot)
            histogram(dataMatrix(:,vecIndex(nn)), 50);
            xlabel(names{vecIndex(nn)})
            iplot=iplot+1;
            grid on
        else
            subplot(n_response,n_response,iplot)
            plot(dataMatrix(:,vecIndex(nn)), dataMatrix(:,vecIndex(mm)), '.')
            xlabel(names{vecIndex(nn)})
            ylabel(names{vecIndex(mm)})
            iplot=iplot+1;
            grid on
        end
    end
end
