% Performs DFT-based analysis (PSD,TOLf (fast 1/3-octave method),Broadband)
% for PAMGuide.m

% This code accompanies the manuscript:

%   Merchant et al. (2015). Measuring Acoustic Habitats. Methods in Ecology
%    and Evolution

% and follows the equations presented in Appendix S1. It is not necessarily
% optimised for efficiency or concision.

% Copyright 2014 The Authors.

% Author: Nathan D. Merchant. Last modified 22 Sep 2014

function [A] = computeTOLs(xbit,Fs,S,N,r,nfc,fb)

    pref = 1;

    %% COMPUTING POWER SPECTRUM

    %% Divide signal into data segments (corresponds to EQUATION 5 in PAMGuide tutorial and 3.1 in the User doc)

    xl = length(xbit);

    if N > xl                           %check segment is shorter than file
        disp('Error: The chosen segment length is longer than the file.')
        A = 0;
        return
    end
    
    xbit = single(xbit);                %reduce precision to single for speed
    xgrid = buffer(xbit, N, ceil(N * r), 'nodelay').';
                                        %grid whose rows are each (overlapped)
                                        %   segment for analysis
    clear xbit
    
    if xgrid(length(xgrid(:, 1)), N) == 0 %remove final segment if not full
        xgrid = xgrid(1 : length(xgrid(:, 1)) -1, :);
    end

    M = length(xgrid(:, 1));             %total number of data segments


    %% Apply window function (corresponds to EQUATION 6 in PAMGuide tutorial and 3.2 in the User doc)
    w = (0.54 - 0.46 * cos(2 * pi * (1:N) / N)); % only hamming windows
    alpha = 0.54;               %scaling factor

    xgrid = xgrid .* repmat(w / alpha, M, 1);
                                        %multiply segments by window function

    %% Compute DFT (EQUATION 7 in PAMGuide tutorial and 4.1 in the User doc)

    X = abs(fft(xgrid.')).';            %calculate DFT of each data segment
    
    clear xgrid
    
    % [ if a frequency-dependent correction is being applied to the signal,
    %   e.g. frequency-dependent hydrophone sensitivity, it should be applied
    %   here to each frequency bin of the DFT ]


    %% Compute power spectrum (EQUATION 8 in PAMGuide tutorial and 4.2 in the User doc)

    P = (X ./ N) .^ 2;                      %power spectrum = square of amplitude
    
    clear X

    %% Compute single-sided power spectrum (EQUATION 9 in PAMGuide tutorial and 4.3 in the User doc)

    Pss = 2 * P(:, 2 : floor(N/2) + 1);        %remove DC (0 Hz) component and
                                        % frequencies above Nyquist frequency
                                        % Fs/2 (index of Fs/2 = N/2+1), divide
                                        % by noise power bandwidth
    clear P
    
    %% Compute frequencies of DFT bins
    f = floor(Fs / 2) * linspace(1 / (N/2), 1, N/2);

    %% Compute noise power bandwidth and delta(f)
    B = (1/N) .* (sum((w / alpha) .^ 2));     %noise power bandwidth (EQUATION 12 in PAMGuide tutorial and 4.5 in the User doc)

    %% Convert to dB

    % Calculate 1/3-octave band levels (corresponds to EQUATION 16 in PAMGuide tutorial and 4.8 in the User doc)
    P13 = zeros(M, nfc);             %initialise TOL array

    for i = 1:nfc                   %loop through centre frequencies
        fli = find(f >= fb(i), 1, 'first');   %index of lower bound of band
        fui = find(f < fb(i+1), 1, 'last');   %index of upper bound of band
        for q = 1:M                 %loop through DFTs of data segments
            fcl = sum(Pss(q, fli:fui));%integrate over mth band frequencies
            P13(q, i) = fcl ;         %store TOL of each data segment
        end
    end
    if ~isempty(P13(1, 10 * log10(P13(1,:) / (pref ^ 2)) <= -10 ^ 6))
        lowcut = find(10 * log10(P13(1,:)/(pref ^ 2)) <= -10 ^ 6, 1, 'last') + 1;
                                    %index lowest band before empty bands
                                    % at low frequencies
        P13 = P13(:, lowcut:nfc);        %remove empty low-frequency bands
    end
	a = 10 * log10((1/B) * P13 / (pref ^ 2)) -S; %TOLs
    
    clear P13
    clear Pss

    %% Construct output array
    A = 10 * log10(mean(10 .^ (double(a) ./ 10))); % Mean aggregation depending on the length of integration windows

    % if disppar == 1,fprintf(['TOL computation done in ' num2str(tock) ' s.\n']),end
end
