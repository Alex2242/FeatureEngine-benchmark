%% Main contributors: Julien Bonnel, Dorian Cazau

[x,~]=audioread([path_wavData wavDataFiles(ww).name]);

%% added
fprintf('Processing file %s \n', wavDataFiles(ww).name)
%% 
idx = strfind(timestampAURAL(:,1), wavDataFiles(ww).name(1:8));
idx = find(not(cellfun('isempty', idx)));
if ~isempty(idx)
    tstartfile = datenum(strcat(timestampAURAL{idx,2},...
        timestampAURAL{idx,3}),'yyyy/mm/ddHH:MM:SS');
else
    listMissingTimestamp = [listMissingTimestamp ; {wavDataFiles(ww).name(1:8)}];
end
        
if ~isempty(Si_db)
    x = x * (10^(Si_db/20)); % in uPa
end
