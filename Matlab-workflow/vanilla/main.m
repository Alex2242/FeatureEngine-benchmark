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

%% init parameters

% short window, in samples
nFFT = 512; 
% long window, in seconds
nIntegWin_sec = 10*60;
% in samples
nOverlapFFT = nFFT / 2;

% SPL
f1 = 0; % frequency bands used to filter SPL, e.g. the first band is [30-80] Hz, the second [10-500] Hz ...
f2 = 40000;

% TOL parameters
lcut = 0;
hcut = 100000000;

% feature augmentation
% maximum interval (in sec) to match an acoustic data with an env data
maxTimestampMatching = 3600 * 24;

% user-defined parameters
siteToProcess = 'A';
yearToProcess = '2010';
nfilesToProcess = 1;

% number of file to process. If Inf, all files will be processed
NberMaxFile = 1;

%% define data location and read metadata

% define print format
format short

% default paths
path_auxData = strcat('.', filesep, 'auxData', filesep);
path_soundscapeResults = strcat('.', filesep, 'soundscapeResults', filesep);
path_acousticFeatures = strcat('.', filesep, 'acousticFeatures', filesep);

% include source files containing program's functions
addpath(genpath(strcat('.', filesep, 'misc_code', filesep)))
addpath(genpath(strcat('.', filesep, 'signal_processing', filesep)))
addpath(genpath(strcat('.', filesep, 'aux_data_processing', filesep)))

pathWavData = strcat(...
    '/home/datawork-alloha-ode/Datasets/SPM/PAM/SPMAural', siteToProcess,...
    yearToProcess, filesep);

% List all files in folder
wavDataFiles = dir(strcat(pathWavData, '*.WAV'));
wavDataFiles = wavDataFiles(1 : min(length(wavDataFiles), nfilesToProcess));

disp(nfilesToProcess)
info = audioinfo(strcat(pathWavData, wavDataFiles(1).name));


%% variable initialization

% Variable to list missing file or incompatible wav file
listMssingTimestamp = [];
gain = [];
vPSD = [];
vtol = [];
vspl = [];
timestampSegment = [];

fs = info.SampleRate;
nIntegWin = round(nIntegWin_sec * fs); % in samples, size of integration window
w = hamming(nFFT); % window used for windowing
fPSD = psdfreqvec('npts', nFFT, 'Fs', fs, 'Range', 'half'); % frequency vector

% this might not be the correct path on datarmor !!!
timestampFilename = '/home/datawork-alloha-ode/Datasets/SPM/PAM/Metadata_SPMAuralA2010.csv';
delimiter = ';'; % delimiter in CSV file
% Format string for each line of text:
%   column1: text (%s)
%	column10: text (%s)
%   column11: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%*s%*s%*s%*s%*s%*s%*s%*s%s%s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';
timestampAURAL = readTimestampAURAL(timestampFilename, nfilesToProcess, formatSpec, delimiter);

%% Compute

for ww = 1 : nfilesToProcess

    %% pre-processing (read and add gain if any)
    [gainedSignal, listMssingTimestamp] = readAndAddGainToData(pathWavData, wavDataFiles(ww).name,...
            listMssingTimestamp, timestampAURAL, gain);

    %% segmentation
    k = fix((length(x)) / (nIntegWin));
    xStart = 1 : nIntegWin : k*(nIntegWin);
    xEnd = xStart + nIntegWin - 1;

    for indIntegWin = 1 : k
				% Slice audio to process in integration window
        xint = x(xStart(indIntegWin) : xEnd(indIntegWin));

				% Extract timestamp
        ddd = datestr(addtodate(...
                tstartfile, round(1000 * xStart(indIntegWin) / fs),...
            'millisecond'), 'yyyymmddHHMMSS');
        timestampSegment = [timestampSegment ; {ddd}];

        %% feature computation and integration
        % PSD
        vPSD_int = myPwelchFunction(xint, nFFT, nOverlapFFT, w, fs);
        vPSD = [vPSD; vPSD_int'];

        % SPL
        vspl = [vspl; 10 * log10(mean(vPSD_int(fPSD>f1 & fPSD<f2))) ];
    end
end

%% Save all features and corresponding timestamps
% save(strcat(path_acousticFeatures, 'PSD.mat'), ...
%     'vPSD', 'vspl', 'timestampSegment', 'fPSD', '-v7.3');

%% Compute elapsed time
elapsetipeSoundscapeWorkflow = toc(timeToBegin);
fprintf('Elapsed Time: %d', elapsetipeSoundscapeWorkflow);
fprintf('End of computations')

%% Save elapsed time for Nfile
simulation_results = [nfilesToProcess, elapsetipeSoundscapeWorkflow];
dlmwrite(...
    strcat('/home/datawork-alloha-ode/results_matlab/simulaton_results_Aural',...
    siteToProcess, '_', yearToProcess, '_', num2str(nFFT), '_',...
    num2str(nIntegWin_sec), '_', num2str(nOverlapFFT), '.csv'),...
    simulation_results, '-append')
