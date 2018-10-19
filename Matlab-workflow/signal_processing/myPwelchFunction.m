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

%% Taken from MathWorks to reduce run time and PAMGuide from Merchant et al. 2015
function [psd] = myPwelchFunction(data, nfft, nOverlap, w, fs)

    if (mod(nfft, 2) == 0)
        toKeep = nfft/2+1;
    else
        toKeep = nfft/2;
    end

    nbSegments = fix((length(data) - nOverlap) / (nfft - nOverlap));

    % grid whose rows are each (overlapped) segment for analysis
    xgrid = buffer(data, nfft, nOverlap, 'nodelay');
    clear xbit
    
    if xgrid(length(xgrid(:, 1)), nfft) == 0 %remove final segment if not full
        xgrid = xgrid(1 : length(xgrid(:, 1)) -1, :);
    end

    M = length(xgrid(1,:)); %total number of data segments

    %% Apply window function (corresponds to EQUATION 6 in PAMGuide tutorial and 3.2 in the User doc)
    xgrid = xgrid .* repmat(w, 1, M); %multiply segments by window function

    %% Compute DFT (EQUATION 7 in PAMGuide tutorial and 4.1 in the User doc)

    X = abs(fft(xgrid)); %calculate DFT of each data segment
    clear xgrid
    
    % [ if a frequency-dependent correction is being applied to the signal,
    %   e.g. frequency-dependent hydrophone sensitivity, it should be applied
    %   here to each frequency bin of the DFT ]


    %% Compute power spectrum (EQUATION 8 in PAMGuide tutorial and 4.2 in the User doc)

    P = X(1 : toKeep, :) .^ 2; % power spectrum = square of amplitude
    clear X
    % step 5: take the average of all the periodograms
    psd = mean(P, 2);
    clear P
    % throw away the 2nd half of mypsd
    %  mypsd_v1 = mypsd_v1(1:toKeep);
    % normalizing factor
    psd = psd / (fs * sum(w .^ 2));
    % ignore the DC and Nyquist value
    psd(2 : end-1) = psd(2 : end-1) * 2;
    
    
end
