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
%   Alexandre Degurse

%% Main script of the workflow

clc
close all
clear

timeToBegin = tic;

%% include source files containing program's functions
addpath(genpath(strcat('.', filesep, 'signal_processing', filesep)));


%% init parameters

% linear scale
calibrationFactor = 1.0;
% long window, in samples
segmentSize = 1024;
% short window, in samples
windowSize = 512;
% short window, in samples
nfft = 512; 
% in samples
windowOverlap = fix(nfft / 2);

%windowFunction = hamming(windowSize); % window used for windowing
windowFunction = ones(1, windowSize); % window used for windowing


%% define data location

nFiles = 1;

wavFilesLocation = strcat('..', filesep, '..', filesep, 'resources',...
    filesep, 'sounds', filesep);

wavFiles = struct(...
    'name', ["Example_64_16_3587_1500.0_1.wav"],...
    'fs', [1500]...
);


%% Compute

for iFile = 1 : nFiles
    results = computeFeatures(...
        wavFilesLocation, char(wavFiles(iFile).name), wavFiles(iFile).fs, calibrationFactor,...
        segmentSize, nfft, windowSize, windowOverlap, windowFunction);
end


%% Compute elapsed time

elapsetipeSoundscapeWorkflow = toc(timeToBegin);

fprintf('Elapsed Time: %d\n', elapsetipeSoundscapeWorkflow);
fprintf('End of computations\n')

