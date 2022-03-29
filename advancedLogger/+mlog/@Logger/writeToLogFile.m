function writeToLogFile(obj, msgObj)
% Writes a message to the log file

% Copyright 2018-2022 The MathWorks Inc.

% Validate inputs
arguments
    obj
    msgObj (1,1) mlog.Message
end


%% Check if we need a new log file

if obj.RotationPeriod == "none" && strlength(obj.LogFile)
    % Legacy behavior - file is specified directly

    % No action

else

    % Get the current time
    curTime = datetime("now","TimeZone","local");

    % Is a log file rotation needed?
    if ~(strlength(obj.LogFile)) || (curTime > obj.NextRotation) ||...
            fileparts(obj.LogFile) ~= obj.LogFolder

        % Name part
        namePart = matlab.lang.makeValidName(obj.Name,'ReplacementStyle','delete');

        % Date Part
        dateSuffix = datestr(curTime, obj.RotationPeriod.DateFormat);
        obj.NextRotation = obj.RotationPeriod.getNextPeriod(curTime);

        % Formulate file path
        if strlength(dateSuffix)
            fileName = namePart + "_" + dateSuffix + ".log";
        else
            fileName = namePart + ".log";
        end

        obj.LogFile = fullfile(obj.LogFolder, fileName);

    end

end %if obj.RotationPeriod == "none" && strlength(obj.LogFile)



%% Open the log file for writing
if ~ismember(obj.FileID, fopen("all"))

    % Make the log folder if needed
    if ~isfolder(obj.LogFolder)
        [status, message] = mkdir(obj.LogFolder);
        if ~status
            [~,fileName,fileExt] = fileparts(obj.LogFile);
            newLogFile = fullfile(tempdir, fileName + fileExt);
            warning("mlog:unableCreateLogFolder",...
                "Unable to create log folder: %s\n" + ...
                "Defaulting to temp directory: %s\n" + ...
                "Message: %s",...
                obj.LogFolder, newLogFile, message);
            obj.LogFolder = tempdir;
            obj.LogFile = newLogFile;
        end
    end

    % Open the log file for writing
    obj.fopenLogFile("a");

end


%% Attempt to write the message
try
    fprintf(obj.FileID, '%s\r\n', msgObj.createLogFileMessage());
catch err
    warning(err.identifier, '%s', err.message);
end %try