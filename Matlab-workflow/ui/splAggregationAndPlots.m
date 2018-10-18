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

function splAggregationAndPlots( timeAggregation, inputTimestampFormat, timestampSegment,...
     vspl, path_soundscapeResultsFigures, nameHeatmapFig)
% splAggregationAndPlots( timeAggregation, splAnalysis, ...
% path_soundscapeResultsFigures, nameHeatmapFig)
% This function enables to save heatmaps of aggregated SPL
%
% Syntax: splAggregationAndPlots( timeAggregation, splAnalysis, ...
%    path_soundscapeResultsFigures, nameHeatmapFig)
%
% Input:
%      splAnalysis           - 0 if you do not want these plots, 1
%      otherwise
%      inputTimestampFormat  - Format of the stored timestamps
%      timestampSegment      - Array with all timestamps
%      vspl                  - computed SPL
%      path_soundscapeResultsFigures   - Path to the folder that will
%      contain the generated figures
%      nameHeatmapFig        - Name of the figure with TOL heatmaps
%
% Output:  None - Figures are saved with the name nameHeatmapFig
% NameFig
%
% Example:   splAggregationAndPlots( timeAggregation, splAnalysis, ...
%    path_soundscapeResultsFigures, nameHeatmapFig)

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

% Plot the whole spl timeserie
plotTimeseries = 0;

% Only the mean value is comupted with aggregated SPL
newfunc = @(x) 10*log10(mean(10.^(x./10)));
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

disp('Launching SPL analysis...')

%% Build spl dataframe with timestamps and timeseries to plot
dataframeSPL = array2timetable(vspl,'RowTimes',rowsTime);

%% Build the dataframe with timestamps as key (timetable in Matlab) (useless right now)
linearDF = varfun(linearTodB,dataframeSPL); % dB to linear to aggregate values
aggregationOnLinearDFSPL = retime(linearDF,timeAggregation,'mean'); % Aggregation following the timeAggregation chosen by the user
aggregatedDFSPL = varfun(dbToLinear,aggregationOnLinearDFSPL); % linear to dB values
aggregatedSPL = aggregatedDFSPL.Variables; % Extract aggregated tol values in an array
timestampVectorSPL = aggregatedDFSPL.Time(1:end,1); % Extract timestamps from the DF

% Convert into a timeserie to plot with dates
aggSPLTimeserie = timeseries(aggregatedSPL,datestr(timestampVectorSPL));
aggSPLTimeserie.Name = 'SPL (units to add)';
% figure('visible','off');
% plot(aggSPLTimeserie)
%     FormatFigures([path_soundscapeResultsFigures filesep  'aggSPL']);

% % Intersite comparison of SPL.
% figure('visible','off')
% boxplot(vspl)

%% Groups
[groupsOfAnalysis,hourOfAnalysis,dayOfAnalysis,monthOfAnalysis] = findgroups(hour(dataframeSPL.Time)...
    ,day(dataframeSPL.Time),month(dataframeSPL.Time));
% The aggregatedData is the average spl for each audio recording
aggregatedData = splitapply(newfunc, dataframeSPL.Variables,groupsOfAnalysis);
tableResults = table(hourOfAnalysis,monthOfAnalysis,aggregatedData);
matrixResults = table2array(tableResults);
[ah,~,ch] = unique(matrixResults(:,1:2),'rows');
out_hour = [ah,accumarray(ch,matrixResults(:,3),[],newfunc)];
a = array2table(out_hour, 'VariableNames',{'Hour','Month','aggSPL'});
% %avergae values per hour
% [ah,~,ch] = unique(data(:,1:4),'rows');
% out_hour = [ah,accumarray(ch,data(:,5),[],@nanmean)];
%
% %avergae values per day
% [ad,~,cd] = unique(data(:,1:3),'rows');
% out_day = [ad,accumarray(cd,data(:,5),[],@nanmean)];
%
% %avergae values per month
% [am,~,cm] = unique(data(:,1:2),'rows');
% out_month = [am,accumarray(cm,data(:,5),[],@nanmean)];
%
% %avergae values per year
% [ay,~,cy] = unique(data(:,1:2),'rows');
% out_year = [ay,accumarray(cy,data(:,5),[],@nanmean)];


%% Plots
% The idea was to create a heatmap with hour/day/month/year against hour/day/month/year
% against spl
% figure; h = heatmap(a,'Hour','Month','ColorVariable','aggSPL','ColorMethod','none');
if (size(tableResults,1) > 1 && size(tableResults,2) > 1)
    figure('visible','off');
    imagesc(tableResults.hourOfAnalysis,1:length(dayOfAnalysis),tableResults{:,2:end}.')
    title(['SPL aggregated and analysis of the levels (' timeAggregation ')'])
    colorbar
%         FormatFigures([path_soundscapeResultsFigures filesep  nameHeatmapFig]);
else
    disp(['Your time aggregation factor  (' timeAggregation ') is too big to compute' ...
        'your analysis, please reduce your time aggredation factor.'])
end

if plotTimeseries == 1
    timestampStartAudioRecord = timestampSegment(1:45:end);
    splTimeserieToPlot = timeseries(vspl,timestampSegment);
    aggSPLTimeserie = timeseries(aggregatedData,timestampStartAudioRecord);
    figure('visible','off');
    plot(splTimeserieToPlot)
    figure('visible','off');
    plot(aggSPLTimeserie)
end

disp('SPL analysis achieved if any was launched.')

%% 1-way ANOVA to test for significant differences be tween months
y = table2array(a(:,3)); groups = table2array(a(:,2));
[pmonth,tblmonth] = anova1(y,groups);

%% 1-way ANOVA to test for diel periodicity
y = table2array(a(:,3)); groups = table2array(a(:,1));
[phour,tblhour] = anova1(y,groups);


end
