function clearLog(obj)
% Clear the messages in the log and the log file

% Copyright 2018-2022 The MathWorks Inc.


% Clear the messages with the buffer index
obj.BufferIndex = 0;
obj.BufferIsWrapped = false;

% Clear the file by overwriting it
obj.fcloseLogFile();
fopenLogFile(obj, "w");