function fopenLogFile(obj, permission)
% Open the log file for writing

% Copyright 2018-2022 The MathWorks Inc.


% Is it already open?
if ismember(obj.FileID, fopen('all'))

    % Do nothing - it's already open

elseif strlength(obj.LogFile)

    % Open the file
    [obj.FileID, openMsg] = fopen(obj.LogFile, permission);
    if obj.FileID == -1
        msg = "Unable to open log file for writing: ''%s''\n%s\n";
        error(msg, obj.LogFile, openMsg);
    end

end %if strlength(fileName)