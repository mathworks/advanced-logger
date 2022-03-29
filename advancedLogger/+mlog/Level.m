classdef Level < uint8
    %LEVEL Enumeration of log levels
    %   This class enumerates log message threshholds
    %
    % Syntax:
    %           mlog.Level.<MEMBER>
    %
    
    %   Copyright 2018-2021 The MathWorks Inc.
    
    
    %% Enumerations
    enumeration
        
        % 0 - No messages logged at all
        NONE (0)
        
        % 1 - Only error level messages are logged
        ERROR (1)
        
        % 2 - Only warning or error level messages are logged
        WARNING (2)
        
        % 3 - Informational messages are logged, plus all the above
        INFO (3)
        
        % 4 - Messages to the user are logged, plus all of the above
        MESSAGE (4)
        
        % 5 - Debugging info messages are logged, plus all of the above
        DEBUG (5)

        % 6 - Detailed debugging info messages are logged, plus all of the above
        DETAIL (6)

        % 7 - Trace info messages are logged, plus all of the above
        TRACE (7)


    end %enumeration
    
end % classdef