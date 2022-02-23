function watchTimerCallback(obj)
% Triggered on watch timer callback

% Copyright 2018-2022 The MathWorks Inc.

% Current time
curTime = datetime("now","TimeZone","local");


%% Timeout since last message

% How long since the last message?
if isempty(obj.LastMessage)
    elapsedTime = 0;
else
    lastMsgTime = obj.LastMessage.Time;
    elapsedTime = seconds(curTime - lastMsgTime);
end

% Check for timeout condition to close file access
isTimeout = elapsedTime > 30;


%% Rollover of FileDuration increment

% Check if the file name should roll over
fileStartTime = obj.OpenFileStartTime;

% Check for rollover of file log increment
if obj.FileDuration == "daily"
    isRollover = (curTime - fileStartTime) > days(1) || day(fileStartTime) ~= day(curTime);
else %hourly
    isRollover = (curTime - fileStartTime) > hours(1) || hour(fileStartTime) ~= hour(curTime);
end


%% Close file if any conditions met

% Check for timeout condition to close file access
if isTimeout || isRollover
    obj.fcloseLogFile();
end