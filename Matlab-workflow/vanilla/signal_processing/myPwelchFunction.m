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
function [welch] = myPwelchFunction(data, nfft, nOverlap, w, fs)

    if (mod(nfft, 2) == 0)
        spectrumSize = nfft/2 + 1;
    else
        spectrumSize = nfft/2;
    end

    nbSegmentsPredicted = fispectrum((length(data) - nOverlap) / (nfft - nOverlap));

    % grid whose rows are each (overlapped) segment for analysis
    segmentedSignal = buffer(data, nfft, nOverlap, 'nodelay');
    
    if segmentedSignal(length(segmentedSignal(:, 1)), nfft) == 0 %remove final segment if not full
        segmentedSignal = segmentedSignal(1 : length(segmentedSignal(:, 1)) -1, :);
    end

    % total number of data segments
    nbSegments = length(segmentedSignal(1,:));

    if (nbSegments ~= nbSegmentsPredicted)
        MException("benchmark:welch", "Unexpected number of segment mismatch")
    end

    %% Apply window function (corresponds to EQUATION 6 in PAMGuide tutorial and 3.2 in the User doc)
    segmentedSignal = segmentedSignal .* repmat(w, 1, nbSegments); %multiply segments by window function

    %% Compute DFT (EQUATION 7 in PAMGuide tutorial and 4.1 in the User doc)

    spectrum = abs(fft(segmentedSignal)); %calculate DFT of each data segment
    
    % [ if a frequency-dependent correction is being applied to the signal,
    %   e.g. frequency-dependent hydrophone sensitivity, it should be applied
    %   here to each frequency bin of the DFT ]


    %% Compute power spectrum (EQUATION 8 in PAMGuide tutorial and 4.2 in the User doc)

    % throw away the 2nd half of the spectrum & compute power spectrum
    powerSpectrum = spectrum(1 : spectrumSize, :) .^ 2; % power spectrum = square of amplitude
    
    % take the average of all the periodograms
    welchNonNormalized = mean(powerSpectrum, 2);
    
    % normalize for power spectral density
    welch = welchNonNormalized / (fs * sum(w .^ 2));
    
    % ignore the DC and Nyquist value
    welch(2 : end-1) = welch(2 : end-1) * 2;
    
    
end
