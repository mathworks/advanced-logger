function writeToLogFile(obj, msgObj)
% Writes a message to the log file

% Copyright 2018-2022 The MathWorks Inc.

% Validate inputs
arguments
    obj
    msgObj (1,1) mlog.Message
end

% Ensure the log file is open for writing
obj.fopenLogFile("a");

% Attempt to write the message
try
    fprintf(obj.FileID, '%s\r\n', msgObj.createLogFileMessage());
catch err
    warning(err.identifier, '%s', err.message);
end %try