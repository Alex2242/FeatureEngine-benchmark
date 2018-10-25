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

% Main contributors: Julien Bonnel, Dorian Cazau, Paul Nguyen HD,
%   Alexandre Degurse

%% Taken from MathWorks to reduce run time and PAMGuide from Merchant et al. 2015
function results = spectralComputation(...
    signalSegment, fs, windowSize, nfft, windowOverlap, windowFunction)

    if (mod(nfft, 2) == 0)
        spectrumSize = nfft/2 + 1;
    else
        spectrumSize = nfft/2;
    end

    nPredictedWindows = fix((length(signalSegment) - windowOverlap) / (nfft - windowOverlap));

    % grid whose rows are each (overlapped) segment for analysis
    segmentedSignalWithPartial = buffer(signalSegment, windowSize, windowOverlap, 'nodelay');
    
    % remove final window if not full
    if segmentedSignalWithPartial(length(segmentedSignalWithPartial(:, 1)), nPredictedWindows) == 0 
        segmentedSignal = segmentedSignalWithPartial(1 : length(segmentedSignalWithPartial(:, 1)) -1, :);
    else
        segmentedSignal = segmentedSignalWithPartial;
    end


    %% Apply window function (corresponds to EQUATION 6 in PAMGuide tutorial and 3.2 in the User doc)
    % multiply segments by window function
    windowedSignal = bsxfun(@times, segmentedSignal, windowFunction');

    %% Compute DFT (EQUATION 7 in PAMGuide tutorial and 4.1 in the User doc)

    spectrum = fft(windowedSignal); %calculate DFT of each data segment
    
    % [ if a frequency-dependent correction is being applied to the signal,
    %   e.g. frequency-dependent hydrophone sensitivity, it should be applied
    %   here to each frequency bin of the DFT ]

    % ignore the DC and Nyquist value
    oneSidedSpectrum = spectrum(1 : spectrumSize);
    oneSidedSpectrum = oneSidedSpectrum(2 : spectrumSize-1) * 2;

    %% Compute power spectrum (EQUATION 8 in PAMGuide tutorial and 4.2 in the User doc)

    % throw away the 2nd half of the spectrum & compute power spectrum
    powerSpectrum = abs(oneSidedSpectrum) .^ 2 / (fs * sum(windowFunction .^ 2));
    
    % take the average of all the periodograms
    welch = mean(powerSpectrum, 2);
    
    results = struct(...
        'vFFT', oneSidedSpectrum,...
        'vPSD', powerSpectrum,...
        'vWelch', welch...
    );
end
