%% Main contributors: Julien Bonnel, Dorian Cazau, Paul Nguyen HD

% pwelch
[vPSD_int,~]=pwelch(xint,nFFT,nOverlapFFT,nFFT,fs,'psd','onesided');
vPSD = [vPSD;vPSD_int'];

% TOL
tol = computeTOLs(xint, fs, 0, fs, 0,lowFreqTOL,highFreqTOL);
vtol = [vtol;tol];

% SPL
vspl = [vspl; 10*log10(mean(vPSD_int(fPSD>f1 & fPSD<f2))) ];
