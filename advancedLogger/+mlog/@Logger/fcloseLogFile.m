function fcloseLogFile(obj)
% Close the log file for writing

% Copyright 2018-2022 The MathWorks Inc.


if obj.FileID >= 0

    try
        fclose(obj.FileID);
    catch
        warning("mlog:closeInvalidLogFileId",...
            "Failed to close logfile: %s",...
            obj.LogFile);
    end
    
    obj.FileID = -1;

end %if