function [results] = computeFeatures(...
    wavFileLocation, wavFileName, fs, calibrationFactor, segmentSize, windowSize, nfft,...
    windowOverlap, windowFunction)

    %computeFeatures Summary of this function goes here
    %   Detailed explanation goes here

    wavInfo = audioinfo(strcat(wavFileLocation, wavFileName));
    
    % @TODO perform checks against expected infos

    rawSignal = audioread(strcat(wavFileLocation, wavFileName));
    
    calibratedSignal = rawSignal * calibrationFactor;
    
    nSegments = fix(wavInfo.TotalSamples / segmentSize);
    nSamplesToKeep = mod(wavInfo.TotalSamples, segmentSize);
    
%     segmentedSignal = reshape(calibratedSignal(1:nSamplesToKeep),...
%         segmentSize, nSegments);
    
    results = {};
    
    % going backwards to have the right struct size allocation of results
    for iSegment = nSegments-1 : -1 : 0
        result = spectralComputation(...
            calibratedSignal(1 + iSegment*segmentSize : 1 + (iSegment+1) * segmentSize),...
            fs, windowSize, nfft, windowOverlap, windowFunction);
        
        results(1 + iSegment).vFFT = result.vFFT;
        results(1 + iSegment).vPSD = result.vPSD;
        results(1 + iSegment).vWelch = result.vWelch;
    end
end

