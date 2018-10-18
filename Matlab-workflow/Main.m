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

%% Main script of the workflow

clc
close all
clear

timeToBegin = tic;

% user-defined parameters
siteToProcess = 'A';
yearToProcess = '2010';
nfilesToProcess = 1;

% number of file to process. If Inf, all files will be processed
NberMaxFile = 1;

%% initialization

format short

% default paths
path_auxData = strcat('.', filesep, 'auxData', filesep);
path_soundscapeResults = strcat('.', filesep, 'soundscapeResults', filesep);
path_acousticFeatures = strcat('.', filesep, 'acousticFeatures', filesep);

% include source files containing program's functions
addpath(genpath(strcat('.', filesep, 'misc_code', filesep)))
addpath(genpath(strcat('.', filesep, 'signal_processing', filesep)))
addpath(genpath(strcat('.', filesep, 'aux_data_processing', filesep)))
addpath(genpath(strcat('.', filesep, 'ui', filesep)))

pathWavData = strcat(...
    '/home/datawork-alloha-ode/Datasets/SPM/PAM/SPMAural', siteToProcess,...
    yearToProcess, filesep);

% List all files in folder
wavDataFiles = dir(strcat(pathWavData, '*.WAV'));
wavDataFiles = wavDataFiles(1 : min(length(wavDataFiles), NberMaxFile));

Nfile = size(wavDataFiles, 1);
disp(Nfile)
info = audioinfo(strcat(pathWavData, wavDataFiles(1).name));

initializationScript

% variable initialization
vPSD = [];
vtol = [];
vspl = [];
timestampSegment = [];
timestampSegment1 = [];

Fs=info.SampleRate;
nIntegWin = round(nIntegWin_sec * Fs); % in samples, size of integration window
w = hamming(nFFT).'; % window used for windowing
fPSD = psdfreqvec('npts', nFFT, 'Fs', Fs, 'Range', 'half'); % frequency vector

% prepare timestamp reading
filename = strcat(...
    '/home/datawork-alloha-ode/Datasets/SPM/PAM/Metadata_SPMAural',...
    siteToProcess, yearToProcess, '.csv');

Nfile = nfilesToProcess;

% this might not be the correct path on datarmor !!!
timestampFilename = '/home/datawork-alloha-ode/Datasets/SPM/PAM/Metadata_SPMAuralA2010.csv';
readTimestampAURAL

for ww=1:Nfile

    %% pre-processing (read and add gain if any)
    preProcessing

    %% segmentation
    k = fix((length(x)) / (nIntegWin));
    xStart = 1 : nIntegWin : k*(nIntegWin);
    xEnd = xStart + nIntegWin - 1;

    for indIntegWin = 1:k
				% Slice audio to process in integration window
        xint = x(xStart(indIntegWin) : xEnd(indIntegWin));

				% Extract timestamp
        ddd = datestr(addtodate(...
                tstartfile, round(1000 * xStart(indIntegWin) / Fs),...
            'millisecond'), 'yyyymmddHHMMSS');
        timestampSegment = [timestampSegment ; {ddd}];

        %% feature computation and integration
        % PSD
        vPSD_int=myPwelchFunction(xint, nFFT, nOverlapFFT, w, Fs);
        vPSD = [vPSD; vPSD_int'];

        % SPL
        vspl = [vspl; 10 * log10(mean(vPSD_int(fPSD>f1 & fPSD<f2))) ];
    end
end

% Save all features and corresponding timestamps
% save(strcat(path_acousticFeatures, 'PSD.mat'), ...
%     'vPSD', 'vspl', 'timestampSegment', 'fPSD', '-v7.3');

% Compute elapsed time
elapsetipeSoundscapeWorkflow = toc(timeToBegin);
fprintf('Elapsed Time: %d', elapsetipeSoundscapeWorkflow);
fprintf('End of computations')

% Save elapsed time for Nfile
simulation_results = [nfilesToProcess, elapsetipeSoundscapeWorkflow];
dlmwrite(...
    '/home/datawork-alloha-ode/results_matlab/simulaton_results_AuralA_2010_512_60_0.csv',...
    simulation_results, '-append')
