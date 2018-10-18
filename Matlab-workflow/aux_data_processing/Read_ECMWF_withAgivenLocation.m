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

% Main contributors: Julien Bonnel, Dorian Cazau

clc
clear
close all

% dirnc = dir('/home4/datahome/pnguyenh/soundscape_workflow_ODE_v0/auxData/_gri*.nc');
dirnc = dir('/home4/datahome/pnguyenh/soundscape_workflow_ODE_v0/auxData/SPM*.nc');

sitename = 'SPMAuralB2011';
% gps_site = [46.7058 , -56.3056]; % site A
gps_site = [47.2129 , -56.1888]; % site B

visu_map = 0;

% sitename = 'WHOIsite4';
% gps_site = [72.61097 , -157.53745];

all_T=[];
for dd = 1:size(dirnc,1)

    NameDataset = ['/home4/datahome/pnguyenh/soundscape_workflow_ODE_v0/auxData/'...
        dirnc(dd).name];

    info=ncinfo(NameDataset);

    varNames = {info.Variables.Name};% take all variables available

    varNames = {'time','longitude','latitude','u10','v10','tp'};% select only a few variables

    for nnn=1:length(varNames)
        nnn/length(varNames)
        eval([varNames{nnn} '=ncread(NameDataset,''' varNames{nnn} ''');'])
    end

    time_str = double(time)/24 + datenum('1900-01-01 00:00:00');
    time_str = sort(time_str,'ascend');

    ind = find(~cellfun(@isempty,(strfind(varNames,'time'))),1,'first');
    varNames(ind) = [];
    ind = find(~cellfun(@isempty,(strfind(varNames,'longitude'))),1,'first');
    varNames(ind) = [];
    ind = find(~cellfun(@isempty,(strfind(varNames,'latitude'))),1,'first');
    varNames(ind) = [];

    datestr(time_str(:),'yyyy-mm-dd-HH')
    disp(['Your ECMWF data are from ' datestr(time_str(1),'yyyy-mm-dd-HH') ' to ' datestr(time_str(end),'yyyy-mm-dd-HH') ])

    longitude = longitude-180;

    [c_lat,ind_lat] = min(abs(gps_site(1)-latitude));
    [c_lon,ind_lon] = min(abs(gps_site(2)-longitude));

    var = zeros(length(time_str),length(varNames));
    datevect = {};
    for tt=1:length(time_str)
    tt/length(time_str)

        NameFile = datestr(time_str(tt,:),'yyyy-mm-ddTHH:MM:SS');
%         NameFile = datestr(time_str(tt,:),'yyyymmddHHMMSS');

        for nnn=1:length(varNames)
            % recentering map
            eval([varNames{nnn} '(:,:,tt) = [' varNames{nnn} '(end/2+1:end,:,tt) ; ' ...
                varNames{nnn} '(1:end/2,:,tt)];'])
            eval(['var(tt,nnn) = ' varNames{nnn} '(ind_lon,ind_lat,tt);'])
        end

        if visu_map
            swh(ind_lon,ind_lat,tt)
            figure, hold on,
            imagesc(longitude, latitude,swh(:,:,tt)')
            plot3(linspace(longitude(ind_lon),longitude(ind_lon),100),...
                linspace(latitude(ind_lat),latitude(ind_lat),100),...
                linspace(5,5,100),'kx','markersize',16,'linewidth',3)
            set(gca,'Ydir','normal')
            colorbar
            pause
        end

        datevect{tt,1} = NameFile;
    end

    T=table(datevect,var(:,1),var(:,2),var(:,3),'VariableNames',[{'Time'},varNames(1:end)]);

    all_T = [all_T ; T];
end

% redefine variables in T
final_T = [all_T(:,1) , table(sqrt( all_T.u10 .^2 + all_T.v10.^2)) , all_T(:,4)];
final_T.Properties.VariableNames = {'timestamp','W10','tp'};

% writetable(final_T,[cd 'variables_ECMWF_testTimestamp_' sitename '.csv'])
writetable(final_T,['/home4/datahome/pnguyenh/soundscape_workflow_ODE_v0/auxData/variables_ECMWF_Timestamps_' sitename '.csv'])

figure, hold on,
imagesc(longitude, latitude,swh(:,:,1)')
plot3(linspace(longitude(ind_lon),longitude(ind_lon),100),...
    linspace(latitude(ind_lat),latitude(ind_lat),100),linspace(5,5,100),'kx','markersize',16,'linewidth',3)
set(gca,'Ydir','normal')

figure, hold on,
imagesc(longitude, latitude,sst(:,:,1)')
plot3(linspace(longitude(ind_lon),longitude(ind_lon),100),...
    linspace(latitude(ind_lat),latitude(ind_lat),100),linspace(5,5,100),'kx','markersize',16,'linewidth',3)
set(gca,'Ydir','normal')
colorbar
