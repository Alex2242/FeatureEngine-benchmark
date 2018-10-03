%% Main contributors: Julien Bonnel, Dorian Cazau
%% Import data from text file.
% Script for importing data from the following text file:
%
%    C:\Users\Asus\Desktop\Bilan_A32C_20180724154954.txt
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2018/07/24 15:53:00

%% Initialize variables.
delimiter = ';';

%% Format string for each line of text:
%   column1: text (%s)
%	column10: text (%s)
%   column11: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%*s%*s%*s%*s%*s%*s%*s%*s%s%s%*s%*s%*s%*s%*s%*s%*s%*s%*s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%% Create output variable
timestampAURAL = [dataArray{1:end-1}];
timestampAURAL = timestampAURAL(1:Nfile,:);
%% Clear temporary variables
clearvars filename delimiter formatSpec fileID dataArray ans;
