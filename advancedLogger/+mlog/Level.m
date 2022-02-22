classdef Level < uint8
    %LEVEL Enumeration of log levels
    %   This class enumerates log message threshholds
    %
    % Syntax:
    %           mlog.Level.<MEMBER>
    %
    % Caution: Use the text form to indicate message levels in code. Do not
    % rely on the numeric enumerations, as new levels may be added or
    % inserted.
    %
    
    %   Copyright 2018-2022 The MathWorks Inc.
    
    
    %% Enumerations
    enumeration
        
        NONE (0)
        FATAL (1)
        CRITICAL (2)
        ERROR (3)
        WARNING (4)
        INFO (5)
        MESSAGE (6)
        DEBUG (7)
        
    end %enumeration
    
end % classdef