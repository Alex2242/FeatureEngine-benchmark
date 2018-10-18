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

function tolAggregationAndPlotsIntersites( timeAggregation, ...
    inputTimestampFormat, timestampSegment, nfc, fc, vtol,...
    path_soundscapeResultsFigures,nameBoxplotFig, ...
    nameHeatmapFig)
% tolAggregationAndPlots( timeAggregation, ...
%    inputTimestampFormat, tolAnalysis, timestampSegment, nfc, fc, vtol, ...
%    path_soundscapeResultsFigures,nameBoxplotFig, ...
%    nameHeatmapFig)
% This function enables to save the boxplot and heatmaps of aggregated TOLs
%
% Syntax:  tolAggregationAndPlots( timeAggregation, inputTimestampFormat,
% timestampSegment, path_soundscapeResultsFigures,nameBoxplotFig, nameHeatmapFig)
%
% Input:
%      timeAggregation       - Period where TOLs are aggregated (mean)
%      inputTimestampFormat  - Format of the stored timestamps
%      tolAnalysis           - 0 if you do not want these plots, 1
%      otherwise
%      timestampSegment      - Array with all timestamps
%      nfc                   - number of center frequencies of third octave bands
%      fc                    - center frequencies of third octave bands
%      path_soundscapeResultsFigures   - Path to the folder that will
%      contain the generated figures
%      nameBoxplotFig        - Name of the figure with TOL boxplot
%      nameHeatmapFig        - Name of the figure with TOL heatmaps
%
% Output:  None - Figures are saved with the names nameBoxplotFig and nameHeatmapFig
% NameFig
%
% Example:   tolAggregationAndPlots( timeAggregation, inputTimestampFormat,
% timestampSegment, path_soundscapeResultsFigures,nameBoxplotFig,
% nameHeatmapFig)

% Note :
%
% Author:
% email:
% date of creation:
% Modified [date]
%   [COMMENTS ON MODIFICATIONS]

% Other m-files required: FormatFigures.m
% Subfunctions: none
% MAT-files required: none


%% Variable initialization
linearTodB = @(x) 10.^(x./10);
dbToLinear = @(x) 10*log10(x);


%% Extract timestamp array according to the chosen format
if strcmp(inputTimestampFormat,'yyyy-MM-dd HH:mm:ss.SSS')
    rowsTime = datetime(timestampSegment,'InputFormat',inputTimestampFormat);
elseif strcmp(inputTimestampFormat,'yyyymmddHHMMSS')
    tmpDateArray = datenum(timestampSegment,'yyyymmddHHMMSS');
    rowsTime = datetime(tmpDateArray,'ConvertFrom','datenum');
end

%% Start processing

disp('Launching TOL analysis ... ')
% Column names in the dataframe should have valid name (double are not
% valid names).
variableNameCol = matlab.lang.makeValidName(cellstr(strsplit(num2str(fc(1:nfc)))));
% Split the tol array in several columns in the dataframe with timestamps
% and build the dataframe with the tol values (dB if no calibration or dB
% re 1 muPa if calibrated data)
dataframe = array2timetable(vtol,'RowTimes',rowsTime,'VariableNames',variableNameCol);

%% Build the dataframe with timestamps as key (timetable in Matlab)
linearDF = varfun(linearTodB,dataframe); % dB to linear to aggregate values
aggregationOnLinearDF = retime(linearDF,timeAggregation,'mean'); % Aggregation following the timeAggregation chosen by the user
aggregatedDF = varfun(dbToLinear,aggregationOnLinearDF); % linear to dB values
aggregatedTOL = aggregatedDF.Variables; % Extract aggregated tol values in a matrix
[nbRows,nbCols] = size(aggregatedTOL);
timestampVector = aggregatedDF.Time(1:end,1); % Extract timestamps from the DF
centerFreq = fc(1:nfc); % Extract midfrequencies of comuted tols
vecFreqBandEdgesTO = [centerFreq*10^-0.05 max(centerFreq)*10^0.5]; % array of bandedges freq of the TOB
% Build a new tol matrix of the aggregated values. The two last rows are
% equal in order to have the same dimensions to display the surf plot
aggregatedTOL = [aggregatedTOL.';aggregatedTOL(:,nbCols).'];

%% Plots
if (size(aggregatedTOL,1) > 1 && size(aggregatedTOL,2) > 1)
    %% Surf plot extracted from PAMGuide Viewer. function.
%     figure('visible','on');
    surf(timestampVector,vecFreqBandEdgesTO,aggregatedTOL,'EdgeColor','none');
    set(gca,'YScale','log','tickdir','out','layer','top','fontname',...
        'arial','fontsize',14);
    grid off; box on;
    ylim([min(centerFreq)*10^-0.05 max(centerFreq)*10^0.05]);    xlim([min(timestampVector) max(timestampVector)]);
    ylabel('Frequency [ Hz ]')
    title([timeAggregation ' mean 1/3 Octave Analysis'],'interpreter','none')
    view(0,90);
    levvec = sort(reshape(aggregatedTOL,(nbRows)*(nbCols+1),1));
    caxis([levvec(round(length(levvec)/100)) max(levvec(levvec<Inf))])
    colorbar
%     FormatFigures([path_soundscapeResultsFigures filesep  nameBoxplotFig]);

    %% Boxplots of TOL according to the chosen time aggregation
    % from Merchant et al., 2015, Measuring Acoustic habitats
    figure('visible','off');
    boxplot(aggregatedTOL(1:nfc,:).')
    set(gca,'XTickLabel',round(centerFreq))
    xlabel('Nominal center freq of TOB')
    ylabel('TOL')
    title(['Boxplot TOL on the aggregated (' timeAggregation ' mean aggregation) period'])
%     FormatFigures([path_soundscapeResultsFigures filesep  nameHeatmapFig]);

else
    disp(['Your time aggregation factor  (' timeAggregation ') is too big to compute' ...
        'your analysis, please reduce your time aggredation factor.'])
end

disp('TOL analysis achieved .')

end
