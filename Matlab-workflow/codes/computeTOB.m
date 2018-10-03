%% Compute center and bandedge frequencies for third octave bands (TOB)
% Script taken from PAMGuide, Merchant et al., 2015, Measuring acoustic
% habitats

% Several variables like center and bandedges frequencies do not need to be
% reused in each iteration in the main script. As a consequence, all these
% variables are set once for the whole process.

% lcut should not be less than 25 Hz to avoid differences bigger than 1 dB
% compared to the standard method for TOL computations with filters (see
% the user documentation for more informations).

% This code accompanies the manuscript:

%   Merchant et al. (2015). Measuring Acoustic Habitats. Methods in Ecology
%    and Evolution

% and follows the equations presented in Appendix S1. It is not necessarily
% optimised for efficiency or concision.

% Copyright © 2014 The Authors.

% Author: Nathan D. Merchant. Last modified 22 Sep 2014

if lcut < 25
    lcut = 25; % Mennitt2012
end
if Fs/2 < hcut
    hcut = Fs / 2;
end
lobandf = floor(log10(lcut));   %lowest power of 10 frequency for 1/3
                                % octave band computation
hibandf = ceil(log10(hcut));    %highest ""
nband = 10*(hibandf-lobandf)+1; %number of 1/3-octave bands
fc = zeros(1,nband);            %initialise 1/3-octave frequency vector
fc(1) = 10^lobandf;             %lowest frequency = lowest power of 10

% Calculate centre frequencies (corresponds to EQUATION 13 in PAMGuide tutorial and 4.6 in the User doc)
for i = 2:nband                 %calculate 1/3 octave centre
    fc(i) = fc(i-1)*10^0.1;     % frequencies to (at least) precision
end                             % of ANSI standard

fc = fc(find(fc >= lcut,1,'first'):find(fc <= hcut,1,'last'));
                                %crop frequency vector to frequency
                                %   range of data

nfc = length(fc);               %number of 1/3 octave bands

% Calculate boundary frequencies of each band (EQUATIONS 14-15 in PAMGuide tutorial and 4.7 in User doc)
fb = fc*10^-0.05;               %lower bounds of 1/3 octave bands
fb(nfc+1) = fc(nfc)*10^0.05;    %upper bound of highest band (upper
                                %   bounds of previous bands are lower
                                %   bounds of next band up in freq.)
if max(fb) > hcut               %if highest 1/3 octave band extends
    nfc = nfc-1;                %   above highest frequency in DFT,
end
