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
    if ~(strlength(obj.LogFile)) || (curTime > obj.NextRotation)

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
    obj.fopenLogFile("a");
end


%% Attempt to write the message
try
    fprintf(obj.FileID, '%s\r\n', msgObj.createLogFileMessage());
catch err
    warning(err.identifier, '%s', err.message);
end %try