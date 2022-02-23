function updateRotationPeriod(obj)
% Updates the date of the next log rotation

% Copyright 2018-2022 The MathWorks Inc.


switch obj.RotationPeriod

    case "hourly"

    case "daily"

    case "monthly"
        

    otherwise
        obj.NextRotation = NaT("TimeZone","local");

end