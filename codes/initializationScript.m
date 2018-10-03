%% Main contributors: Julien Bonnel, Dorian Cazau, Paul Nguyen HD
%% pre-processing

Si_db = []; % the measured sensitivity of the recorder, Si, in dB
%%%% NB: if Si_db = [], then data are not normalized and dB are
%%%% relative

%% segmentation
nFFT= 512; % short window, in samples
nIntegWin_sec= 10*60 % long window, in seconds
nOverlapFFT = nFFT / 2 %%% in samples  

%% feature computation & integration

% SPL
f1 = 0; % frequency bands used to filter SPL, e.g. the first band is [30-80] Hz, the second [10-500] Hz ...
f2 = 40000;

% TOL parameters
lcut = 0;
hcut = 100000000;

parforSwitch = 0;
%%%% NB: set to 1 if you want to use parfor loop (parallelization on multiple cores
%%%% using the parallel toolbox) instead of the for serial loop


%% feature augmentation
maxTimestampMatching = 3600 * 24; % maximum interval (in sec) to match an acoustic data with an env data

%% raw and augmented visualization
OptLSTA.OffsetFreqDescriptors=40;
OptLSTA.InterFreqDescriptors=200;
OptLSTA.NberLabelX=20;
OptLSTA.TimeStampFormat='yyyy/mm/dd:HH';
OptLSTA.MV_Apply_MedFilt = 40;
