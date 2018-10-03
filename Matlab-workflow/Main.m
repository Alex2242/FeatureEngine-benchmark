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

clc
close all
clear

tic

%% initialization

format short

% default paths
path_auxData = ['.' filesep 'auxData' filesep];
path_soundscapeResults = ['.' filesep 'soundscapeResults' filesep];
path_codes = ['.' filesep 'codes' filesep];
path_acousticFeatures = ['.' filesep 'acousticFeatures' filesep];
addpath(genpath(path_codes))

% user-defined parameters
% path_wavData = ['.' filesep 'wavData' filesep];
siteToProcess = 'B';
yearToProcess = '2010';
% path_wavData = '/home/datawork-alloha-ode/Datasets/SPM/PAM/SPMAuralA2010/';
path_wavData = ['/home/datawork-alloha-ode/Datasets/SPM/PAM/SPMAural' siteToProcess yearToProcess filesep];
wavDataFiles = dir([path_wavData '*.WAV']);
NberMaxFile = Inf;
wavDataFiles = wavDataFiles(1:min(length(wavDataFiles),NberMaxFile));

Nfile=size(wavDataFiles,1);
disp(Nfile)
info=audioinfo([path_wavData wavDataFiles(1).name]);

initializationScript

% variable initialization
vPSD=[];
% vPSD1=[];
vtol=[];
vspl=[];
timestampSegment=[];
timestampSegment1=[];


Fs=info.SampleRate;
nIntegWin = round(nIntegWin_sec*Fs);  %%% in samples
w = hamming(nFFT).';
fPSD = psdfreqvec('npts',nFFT,'Fs',Fs,'Range','half');

% prepare timestamp reading
filename = ['/home/datawork-alloha-ode/Datasets/SPM/PAM/Metadata_SPMAural' siteToProcess yearToProcess '.csv'];

computeTOB

% Nfile = 1
readTimestampAURAL
for ww=1:Nfile

    %% pre-processing
    preProcessing

    %% segmentation
    k = fix((length(x))/(nIntegWin));
    xStart = 1:nIntegWin:k*(nIntegWin);
    xEnd   = xStart+nIntegWin-1;

    for indIntegWin = 1:k
        xint = x(xStart(indIntegWin):xEnd(indIntegWin));

        ddd = datestr(addtodate(tstartfile,round(1000*xStart(indIntegWin)/Fs),'millisecond'),'yyyymmddHHMMSS');
%         ddd1 = datestr(addtodate(tstartfile,round(1000*xStart(indIntegWin)/Fs),'millisecond'),'yyyy-mm-dd HH:MM:SS.FFF');
        timestampSegment = [timestampSegment ; {ddd}];
%         timestampSegment1 = [timestampSegment1 ; {ddd1}];


        %% feature computation and integration
        %(btw, no script because of parfor)

        % PSD
        vPSD_int=myPwelchFunction(xint,nFFT,nOverlapFFT,w,Fs);
%         [vPSD_int1,~]=pwelch(xint,nFFT,nOverlapFFT,nFFT,Fs,'psd','onesided');
        vPSD = [vPSD;vPSD_int'];
%         vPSD1 = [vPSD1;vPSD_int1'];

        % TOL
        tol = computeTOLs(xint, Fs, 0, Fs, 0,nfc,fb);
        vtol = [vtol;tol];

        % SPL
        vspl = [vspl; 10*log10(mean(vPSD_int(fPSD>f1 & fPSD<f2))) ];
    end
end

%% output formatting
% did = dir([path_acousticFeatures 'PSD*']);
% if length(did)+1<10
%     namedir = ['00' num2str(length(did)+1)];
% elseif length(did)+1<1000
%     namedir = ['0' num2str(length(did)+1)];
% else
%     namedir = num2str(length(did)+1);
% end
% namedir = ['Benchmark' num2str(Nfile) 'files_' 'Aural' num2str(siteToProcess) num2str(yearToProcess) '_' num2str(nFFT) 'samples_'...
%     num2str(nIntegWin_sec) 's_' num2str(nOverlapFFT) 's'];

namedir = ['Aural' num2str(siteToProcess) num2str(yearToProcess) '_' num2str(nFFT) 'samples_'...
    num2str(nIntegWin_sec) 's_' num2str(nOverlapFFT) 's'];
fprintf('Result folder name: %s \n', namedir);

save([path_acousticFeatures 'PSD.mat'],'vPSD','vtol','vspl','nfc','fc','timestampSegment'...
    ,'timestampSegment1','fPSD','-v7.3')
% save([path_acousticFeatures 'PSD_' namedir '.mat'],'vPSD','vtol','vspl','nfc','fc','timestampSegment','fPSD','-v7.3')


nRawObs = length(timestampSegment);
nFFT_tab={ num2str(nFFT) };
nIntegWin_tab={ [num2str(nIntegWin_sec) ' / ' num2str(nIntegWin)] };
nOverlapFFT_tab={ num2str(nOverlapFFT) };
nberProcessedFiles={Nfile};

% writetable(table(nFFT_tab,nIntegWin_tab,nOverlapFFT_tab,...
%     nberProcessedFiles,nRawObs),...
%     [path_acousticFeatures 'metadataAcousticComputation_' namedir '.csv'])

writetable(table(nFFT_tab,nIntegWin_tab,nOverlapFFT_tab,...
    nberProcessedFiles,nRawObs),...
    [path_acousticFeatures 'metadataAcousticComputation.csv'])

elapsetipeComputeAcoustics=toc;

%% Raw visualization
% createFigureResultFolder
%
% vPSD_db=10*log10(vPSD);

%% Feature augmentation

%  tstart=clock;
%
%  auxDataFiles = dir([path_auxData 'variables_ECMWF_SPMAural' siteToProcess yearToProcess '.csv']);
%
%  Nt_spectro = size(vPSD,1);
%  timestamp_num_spectro=datenum(timestampSegment,'yyyymmddHHMMSS'); %%% date as a numeric array in days since Jan 0, 0000)
%  auxData_t_psd=[];
%  ecartTime_tot=[];
%  auxVarNames=[];
%
%  for aa = 1:size(auxDataFiles,1)
%        T = readtable([path_auxData auxDataFiles(aa).name]);
%        timestamp_num_env=datenum(num2str(T.timestamp),'yyyymmddHHMMSS');
%        ecartTime=zeros(Nt_spectro,1);
%        vecind=zeros(Nt_spectro,1);
%        for tt=1:Nt_spectro
%            [ecartTime(tt),vecind(tt)] = min(abs(timestamp_num_env - timestamp_num_spectro(tt))); %% in days
%        end
%        ecartTime=ecartTime/3600; %% in sec
%
%        auxData_t_psd = [auxData_t_psd , T{vecind,2:end}];
%        ecartTime_tot = [ecartTime_tot , repmat(ecartTime,1,size(T{vecind,2:end},2))];
%        auxVarNames=[auxVarNames , T.Properties.VariableNames(2:end)];
%  end
%
%  % put NaN for time observation that do not fit within maxTimestampMatching
%  auxData_t_psd(ecartTime_tot> maxTimestampMatching)=NaN;
%
%  elapsetipeMergingAux = etime(clock,tstart)/60;

% % EPD
% figure('visible','off');
% prctilePlot_jb;
% FormatFigures([path_soundscapeResultsFigures filesep 'EPD'])

%% Boxplots of TOL according to the chosen time aggregation
% from Merchant et al., 2015, Measuring Acoustic habitats
% centerFreq = fc(1:nfc); % Extract midfrequencies of comuted tols
% figure('visible','off');
% boxplot(vtol(1:nfc,:).')
% set(gca,'XTickLabel',round(centerFreq))
% xlabel('Nominal center freq of TOB')
% ylabel('TOL')
% title('Boxplot TOL period')
% FormatFigures([path_soundscapeResultsFigures filesep  'boxplotsTolsWithoutAgg']);

% %% TOL analysis
% tolAnalysis = 0;
% timeAggregation = 'hourly'; % mean aggregation. Example taken from PAMGuide and their Welch factor
% inputTimestampFormat = 'yyyy-MM-dd HH:mm:ss.SSS';
% %inputTimestampFormat = 'yyyymmddHHMMSS';
% nameBoxplotFig = 'aggregatedBoxplotTOL';
% nameHeatmapFig = 'aggregatedHeatmapTOL';
%
% if tolAnalysis == 1
% 	tolAggregationAndPlots( timeAggregation, inputTimestampFormat,...
% 	    timestampSegment1, nfc, fc, vtol, ...
% 	    path_soundscapeResultsFigures,nameBoxplotFig, nameHeatmapFig)
% end
% %% SPL analysis
% splAnalysis = 0;
% timeAggregation = 'daily';
% nameHeatmapFig = strcat(timeAggregation, 'aggregatedHeatmapSPL');
% if splAnalysis == 1
% 	splAggregationAndPlots( timeAggregation, inputTimestampFormat, timestampSegment1,...
% 	    vspl, path_soundscapeResultsFigures, nameHeatmapFig)
% end
% %% Feature augmentation
% %
% %  tstart=clock;
% %
% %  auxDataFiles = dir([path_auxData 'variables*.csv']);
% %
% %  Nt_spectro = size(vPSD,1);
% %  timestamp_num_spectro=datenum(timestampSegment,'yyyymmddHHMMSS'); %%% date as a numeric array in days since Jan 0, 0000)
% %  auxData_t_psd=[];
% %  ecartTime_tot=[];
% %  auxVarNames=[];
% %
% %  parfor (aa = 1:size(auxDataFiles,1) )
% %        T = readtable([path_auxData auxDataFiles(aa).name]);
% %        timestamp_num_env=datenum(num2str(T.timestamp),'yyyymmddHHMMSS');
% %
% %        ecartTime=zeros(Nt_spectro,1);
% %        vecind=zeros(Nt_spectro,1);
% %        for tt=1:Nt_spectro
% %            [ecartTime(tt),vecind(tt)] = min(abs(timestamp_num_env - timestamp_num_spectro)); %% in days
% %        end
% %        ecartTime=ecartTime/3600; %% in sec
% %
% %        auxData_t_psd = [auxData_t_psd , T{vecind,2:end}];
% %        ecartTime_tot = [ecartTime_tot , repmat(ecartTime,1,size(T{vecind,2:end},2))];
% %        auxVarNames=[auxVarNames , T.Properties.VariableNames(2:end)];
% %  end
% %
% %  % put NaN for time observation that do not fit within maxTimestampMatching
% %  auxData_t_psd(ecartTime_tot> maxTimestampMatching)=NaN;
% %
% %  elapsetipeMergingAux = etime(clock,tstart)/60;
% %
% %  %% Augmented visualization
% %  figure('visible','off');
% %  Plot_LongTermAverageSpectro_jb
% %  FormatFigures([path_soundscapeResultsFigures filesep 'LTAS'])
%
% % if ~usejava('desktop')
% % 	disp('Done')
% %     exit
% % end
