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

function [gainedSignal, listMssingTimestamp] = readAndAddGainToData(pathWavData, wavFile,...
            listMssingTimestamp, timestampAURAL, Si_db)
% readAndAddGainToData( wavFile, listMissingTimestamp, timestampAURAL)
% This function enables to read and add gain to data
%
% Syntax: [x, listMssingTimestamp] = readAndAddGainToData(wavFile,...
%               listMssingTimestamp, timestampAURAL)
%
% Input:
%      wavFile           - WAV file to process
%      listMssingTimestamp  - array containing missing / corrupted files
%      timestampSegment      - Array with all timestamps
%
% Output:  x - gained audio signal
%          listMissingTimestamp - array containing missing / corrupted files
%
%
% Example:   [x, listMissingTimestamp] = readAndAddGainToData( wavFile, ...
%                        listMissingTimestamp, timestampAURAL)

% Note : 
%
% Author: 
% email: 
% date of creation: 
% Modified [date]
%   [COMMENTS ON MODIFICATIONS]

% Other m-files required: none
% Subfunctions: none
% MAT-files required: none

[gainedSignal,~] = audioread( strcat(pathWavData, wavFile));

fprintf('Processing file %s \n', wavFile)

idx = strfind(timestampAURAL(:,1), wavFile);
idx = find(not(cellfun('isempty', idx)));

if ~isempty(idx)
    tstartfile = datenum(strcat(timestampAURAL{idx, 2},...
        timestampAURAL{idx,3}), 'yyyy/mm/ddHH:MM:SS');
else
    listMissingTimestamp = [listMissingTimestamp ; {wavDataFiles(ww).name(1:8)}];
end

if ~isempty(Si_db)
    gainedSignal = gainedSignal * (10 ^ (Si_db / 20)); % in uPa
end
