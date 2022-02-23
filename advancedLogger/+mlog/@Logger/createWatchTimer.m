function createWatchTimer(obj)
% Adds a watch timer to close the log file after a timeout

% Copyright 2018-2022 The MathWorks Inc.


if isempty(obj.WatchTimer) || ~isvalid(obj.WatchTimer)

    % Create a watch timer
    obj.WatchTimer = timer;
    obj.WatchTimer.Name = "Logger " + obj.Name;
    obj.WatchTimer.ObjectVisibility = 'off';
    obj.WatchTimer.ExecutionMode = "fixedDelay";
    obj.WatchTimer.Period = 30;
    obj.WatchTimer.StartDelay = 30;
    obj.WatchTimer.TimerFcn = @(src,evt)watchTimerCallback(obj);

    % Start the timer
    start(obj.WatchTimer);

end