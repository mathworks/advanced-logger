classdef RotationPeriod
    
    % Enumeration of log file rotation periods
    %   This class enumerates log file rotation periods
    %
    % Syntax:
    %           mlog.RotationPeriod.<MEMBER>
    %
    
    %   Copyright 2018-2022 The MathWorks Inc.
    
    
    %% Enumerations
    enumeration
        
        none    ("")
        minute  ("yyyymmdd_HHMM")
        hour    ("yyyymmdd_HH")
        day     ("yyyymmdd")
        month   ("yyyymm")
        
    end %enumeration

    
    %% Properties
    properties
        DateFormat (1,1) string
    end


    %% Constructor
    methods 
        function obj = RotationPeriod(format)

            obj.DateFormat = format;

        end
    end


    %% Methods
    methods
        function p = getNextPeriod(obj, curTime)

            arguments
                obj (1,1)
                curTime (1,1) datetime = datetime("now","TimeZone","local")
            end

            switch obj

                case "minute"
                    p = datetime(curTime.Year, curTime.Month, curTime.Day, curTime.Hour, curTime.Minute + 1, 0, "TimeZone", curTime.TimeZone);

                case "hour"
                    p = datetime(curTime.Year, curTime.Month, curTime.Day, curTime.Hour + 1, 0, 0, "TimeZone", curTime.TimeZone);

                case "day"
                    p = datetime(curTime.Year, curTime.Month, curTime.Day + 1, "TimeZone", curTime.TimeZone);

                case "month"
                    p = datetime(curTime.Year, curTime.Month + 1, 1, "TimeZone", curTime.TimeZone);

                otherwise
                    p = NaT("TimeZone", curTime.TimeZone);

            end %switch

        end
    end
    
end % classdef