%% Taken from MathWorks to reduce running time
function [mypsd_v1] = myPwelchFunction(data, nfft, nOverlap, w,fs)

 if (mod(nfft,2) == 0)
     toKeep = nfft/2+1;
 else
     toKeep = nfft/2;
 end
 
 nbSegments = fix((length(data)-nOverlap)/(nfft-nOverlap));
 
% preallocate the space for the psd results
 mypsd = zeros(toKeep, nbSegments);
 % step 1: loop through the data, 512 points at a time, with 256 points overlap
 for i = 0:nbSegments-1
    % step 2: apply a hamming window
    temp = data(1+(nfft-nOverlap)*i:nfft+i*(nfft-nOverlap))'.*w;
    % step 3: calculate FFT and take just the first half
    temp = fft(temp);
    % step 4: calculate the "periodogram" by taking the absolute value squared
    temp = abs(temp(1:toKeep)).^2;
    % save the results in the storage variable
    mypsd(:, i+1) = temp;
 end
 % step 5: take the average of all the periodograms
 mypsd_v1 = mean(mypsd,2);
 % throw away the 2nd half of mypsd
%  mypsd_v1 = mypsd_v1(1:toKeep);
 % normalizing factor
 mypsd_v1 = mypsd_v1/(fs*sum(w.^2));
 % ignore the DC and Nyquist value
 mypsd_v1(2:end-1) = mypsd_v1(2:end-1) * 2;
 
end
