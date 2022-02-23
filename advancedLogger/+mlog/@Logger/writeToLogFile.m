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
        obj.NextRotation = obj.RotationPeriod.getNextPeriod();
        
%         switch obj.RotationPeriod
% 
%             case "hourly"
%                 dateSuffix = datestr(curTime, "yyyyMMdd_HH");
%                 obj.NextRotation = curTime + hours(1);
% 
%             case "daily"
%                 dateSuffix = datestr(curTime, "yyyyMMdd");
%                 obj.NextRotation = curTime + days(1);
% 
%             case "monthly"
%                 dateSuffix = datestr(curTime, "yyyyMM");
%                 obj.NextRotation = curTime + months(1);
% 
%             otherwise
%                 dateSuffix = "";
%                 obj.NextRotation = NaT("TimeZone","local");
% 
%         end %switch

        % Formulate file path
        if strlength(dateSuffix)
            fileName = namePart + "_" + dateSuffix + ".log";
        else
            fileName = namePart + ".log";
        end

        obj.LogFile = fullfile(obj.LogFolder, fileName);

    end


    %     % Check if rotation is needed
    %     needRotation = (obj.RotationPeriod ~= "none") && (curTime > obj.NextRotation);
    %
    %     % Is a new file needed?
    %     needNewFile = needRotation || isempty(obj.OpenFilePath);
    %
    %
    %     % Prepare the file name
    %     if needNewFile
    %
    %         % Determine the log file name
    %         if strlength(obj.LogFile)
    %             % (deprecated) Use the specified path
    %
    %             filePath = obj.LogFile;
    %
    %         else
    %             % Use the logger Name and the date/time
    %
    %
    %
    %         end %if
    %
    %     end %if



end %if obj.RotationPeriod == "none" && strlength(obj.LogFile)



%% Ensure the log file is open for writing
obj.fopenLogFile("a");


%% Attempt to write the message
try
    fprintf(obj.FileID, '%s\r\n', msgObj.createLogFileMessage());
catch err
    warning(err.identifier, '%s', err.message);
end %try