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

[x,~]=audioread([path_wavData wavDataFiles(ww).name]);

%% added
fprintf('Processing file %s \n', wavDataFiles(ww).name)
%%
idx = strfind(timestampAURAL(:,1), wavDataFiles(ww).name(1:8));
idx = find(not(cellfun('isempty', idx)));
if ~isempty(idx)
    tstartfile = datenum(strcat(timestampAURAL{idx,2},...
        timestampAURAL{idx,3}),'yyyy/mm/ddHH:MM:SS');
else
    listMissingTimestamp = [listMissingTimestamp ; {wavDataFiles(ww).name(1:8)}];
end

if ~isempty(Si_db)
    x = x * (10^(Si_db/20)); % in uPa
end
