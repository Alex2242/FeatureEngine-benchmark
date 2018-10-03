%% Main contributors: Julien Bonnel, Dorian Cazau, Paul Nguyen HD

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
