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


%% build folder result of soundscape analysis and load acoustic features
% dirs = dir(path_soundscapeResults); dirs(1:2) = []; dirs = dirs([dirs.isdir]);
% if length(dirs)+1<10
%     namedir = ['00' num2str(length(dirs)+1)];
% elseif length(dirs)+1<1000
%     namedir = ['0' num2str(length(dirs)+1)];
% else
%     namedir = num2str(length(dirs)+1);
% end
mkdir([path_soundscapeResults namedir])

did = dir([path_acousticFeatures 'PSD*']);
copyfile([path_acousticFeatures did(end).name],[path_soundscapeResults namedir filesep 'PSD.mat'])
did = dir([path_acousticFeatures 'metadata*']);
copyfile([path_acousticFeatures did(end).name],[path_soundscapeResults namedir filesep 'metadataAcousticComputation.csv'])
copyfile(['.' filesep 'Main.m'],[path_soundscapeResults namedir filesep 'Main.m'])
copyfile(['.' filesep 'codes'],[path_soundscapeResults namedir filesep 'codes'])

path_soundscapeResults = [path_soundscapeResults namedir filesep];

path_soundscapeResultsFigures = [path_soundscapeResults 'Figures'];
mkdir(path_soundscapeResultsFigures)

%% Loading data
load([path_soundscapeResults 'PSD.mat']);
