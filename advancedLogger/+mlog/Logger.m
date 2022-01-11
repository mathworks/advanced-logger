classdef Logger < handle & matlab.mixin.SetGetExactNames & ...
        matlab.mixin.Heterogeneous & matlab.mixin.CustomDisplay
    %LOGGER Advanced logging tool for MATLAB
    %   This class provides configurable logging capabilites for MATLAB
    %   applications.
    %
    %   Logger provides for singleton logger instances given a
    %   unique name of the application. This means that you can get an
    %   instance of the same logger from multiple places in code without
    %   needing to pass around the object handle!
    %
    %   This logger can be configured to write to a file, to the command
    %   window, and to external listeners. Each of these can be
    %   individually configured with a minimum severity of the log message
    %   that should be written.
    %
    %   Please see advancedLogger\GettingStarted.mlx for usage examples.
    
    %   Copyright 2018-2022 The MathWorks Inc.
    
    
    
    %% Events
    events (NotifyAccess = protected)
        
        % The externally-accessible event that is triggered when a new
        % message is received. Listen to this event to implement custom log
        % notifications beyond the typical file and command window options.
        MessageReceived
        
    end %events
    
    
    %% Properties
    properties (AbortSet)
        
        % Name of this logger (each unique name has a singleton logger)
        Name (1,1) string = "Advanced Logger for MATLAB"
        
        % File for log messages (optional)
        LogFile (1,1) string = ""
        
        % Number of messages to retain
        BufferSize (1,1) uint32 {mustBePositive} = 1000
        
        % Level of messages to save to the log file
        FileThreshold (1,1) mlog.Level = mlog.Level.INFO
        
        % Level of messages to display in the command window
        CommandWindowThreshold (1,1) mlog.Level = mlog.Level.WARNING
        
        % Level of messages to trigger MessageReceived event notification
        MessageReceivedEventThreshold (1,1) mlog.Level = mlog.Level.MESSAGE
        
    end %properties
    
    
    
    %% Read-Only Properties
    properties (Dependent, SetAccess = protected)
        
        % Log message history
        Messages (:,1) mlog.Message
        
        % Messages in table format for display purposes
        MessageTable table
        
        % Most recent log message
        LastMessage (:,1) mlog.Message
        
    end %properties
    
    
    
    %% Internal Properties
    properties (Access = protected)
        
        % Circular buffer of log messages
        MessageBuffer (:,1) mlog.Message = repmat(mlog.Message, 1000, 1)
        
        % Index of last message in buffer
        BufferIndex (1,1) double = 0
        
        % Indicates whether the buffer has wrapped around
        BufferIsWrapped (1,1) logical = false
        
        % Message type constructor
        MessageConstructor (1,1) function_handle = @mlog.Message
        
    end %properties
    
    
    properties (Transient, Access = protected)
        
        % File identifier for the log file
        FileID (1,1) double = -1
        
    end %properties
    
    
    
    %% Constructor / Destructor
    methods
        
        function obj = Logger(name, filePath)
            % Construct the logger
            
            % Define input arguments
            arguments
                name (1,1) string = "Advanced_Logger_for_MATLAB"
                filePath (1,1) string = ""
            end
            
            % Logger is a singleton by Name. Only a single logger for each
            % name is stored in memory. If the name is a repeat, this
            % method will return the existing logger. Otherwise, it keeps
            % the new one.
            obj = getSingletonLogger(obj,name);
            
            % Was a file name provided?
            if strlength(filePath)
                % Yes - use it
                
                obj.LogFile = filePath;
                
            elseif ~strlength(obj.LogFile)
                % No - need to define the file path
                
                logFileName = matlab.lang.makeValidName(obj.Name,...
                    'ReplacementStyle','delete');
                obj.LogFile = fullfile(tempdir, logFileName + "_log.txt");
                
            end
            
        end %function
        
        
        function delete(obj)
            % Destruct the Logger
            
            % If a log file was open, close it
            obj.fcloseLogFile();
            
        end %function
        
    end %methods
    
    
    
    %% Public Methods
    methods
        
        function varargout = write(obj, varargin)
            % write a message to the log
            % Adds a new message to the Logger, with the specified message
            % level and text
            %
            % Syntax:
            %       logObj.write(Level, MessageText)
            %       logObj.write(Level, MessageText, sprintf_args...)
            %       logObj.write(MException)
            %       logObj.write(Level, MException)
            %       logObj.write(mlog.Message)
            %       write(logObj,...)
            
            % Construct the message
            msg = constructMessage(obj, varargin{:});
            
            % Add the message to the log
            if ~isempty(msg)
                obj.addMessage(msg);
            end
            
            % Send msg output if requested
            if nargout
                varargout{1} = msg;
            end
            
        end %function
        
        
        function clearLog(obj)
            % Clear the messages in the log and the log file
            
            % Clear the messages with the buffer index
            obj.BufferIndex = 0;
            obj.BufferIsWrapped = false;
            
            % Clear the file by overwriting it
            obj.fcloseLogFile();
            fopenLogFile(obj, "w");
            
        end %function
        
        
        function openLogFile(obj)
            % Open the log file for viewing
            
            % Does it exist?
            if isfile(obj.LogFile)
                
                try
                    if ispc
                        winopen(obj.LogFile);
                    else
                        open(obj.LogFile);
                    end
                catch err
                    warning("mlog:openLogFail",...
                        "The log file could not be opened: %s", err.message);
                end
                
            else
                
                warning("mlog:openLogFileNotFound",...
                    "The log file does not exist: %s", obj.LogFile);
                
            end %if isfile(obj.LogFile)
            
        end %function
        
    end %methods
    
    
    
    %% Protected Methods
    methods (Access = protected)
        
        function msg = constructMessage(obj, argA, argB, varargin)
            % write a message to the log
            % Adds a new message to the Logger, with the specified message
            % level and text
            %
            % Syntax:
            %       logObj.write(Level, MessageText)
            %       logObj.write(Level, MessageText, sprintf_args...)
            %       logObj.write(MException)
            %       logObj.write(Level, MException)
            %       logObj.write(mlog.Message)
            %       write(logObj,...)
            
            % Default new message to empty
            msg = obj.MessageBuffer([]);
            
            % Check input format
            if nargin == 3 && ( ischar(argB) || isStringScalar(argB) )
                %logObj.write(Level, MessageText)
                
                if obj.isLevelLogged(argA)
                    msg = obj.MessageConstructor();
                    msg.Level = argA;
                    msg.Text = argB;
                end
                
            elseif nargin > 3
                %logObj.write(Level, MessageText, sprintf_args...)
                
                if obj.isLevelLogged(argA)
                    msg = obj.MessageConstructor();
                    msg.Level = argA;
                    msg.Text = sprintf(argB, varargin{:});
                end
                
            elseif nargin == 2 && isa(argA, "mlog.Message")
                %logObj.write(mlog.Message)
                
                if obj.isLevelLogged(msg.Level)
                    msg = argA;
                end
                
            elseif nargin == 2 && isa(argA,'MException')
                %logObj.write(MException)
                
                if obj.isLevelLogged(mlog.Level.ERROR)
                    msg = obj.MessageConstructor();
                    msg.Level = mlog.Level.ERROR;
                    msg.Text = obj.convertExceptionText(argA);
                end
                
            elseif nargin == 3 && isa(argB,'MException')
                %logObj.write(Level, MException)
                
                if obj.isLevelLogged(argA)
                    msg = obj.MessageConstructor();
                    msg.Level = argA;
                    msg.Text = obj.convertExceptionText(argB);
                end
                
            else
                error("mlog:invalidWriteInputs",...
                    "Invalid inputs to write method.")
            end
            
        end %function
        
        
        function addMessage(obj, msgObj)
            % Call the function handle based callback
            
            % Check arguments
            arguments
                obj (1,1) mlog.Logger
                msgObj (1,1) mlog.Message
            end
            
            % Get the next position in the circular MessageBuffer
            obj.BufferIndex = obj.BufferIndex + 1;
            if obj.BufferIndex > obj.BufferSize
                obj.BufferIndex = 1;
                obj.BufferIsWrapped = true;
            end
            
            % Add the message to the buffer
            obj.MessageBuffer(obj.BufferIndex) = msgObj;
            
            % Write to file
            if msgObj.Level <= obj.FileThreshold
                obj.writeToLogFile(msgObj);
            end
            
            % Log to command window
            if msgObj.Level <= obj.CommandWindowThreshold
                obj.writeToCommandWindow(msgObj);
            end
            
            % Send event notification
            if msgObj.Level <= obj.MessageReceivedEventThreshold
                obj.notify("MessageReceived", msgObj);
            end
            
        end %function
        
        
        function writeToCommandWindow(obj, msgObj)
            % Writes a log message
            
            fprintf("\t%s Logger: %s\n", obj.Name, ...
                msgObj.createDisplayMessage());
            
        end %function
        
        
        function writeToLogFile(obj, msgObj)
            % Writes a log message
            
            arguments
                obj
                msgObj (1,1) mlog.Message
            end
            
            obj.fopenLogFile("a");
            try
                fprintf(obj.FileID,'%s\r\n',msgObj.createLogFileMessage());
            catch err
                warning(err.identifier, '%s', err.message);
            end %try
            
        end %function
        
        
        function tf = isLevelLogged(obj, level)
            % Determines if the specified level is logged
            
            arguments
                obj
                level (1,1) mlog.Level
            end
            
            tf = level <= obj.FileThreshold || ...
                level <= obj.CommandWindowThreshold || ...
                level <= obj.MessageReceivedEventThreshold;
            
        end %function
        
        
        function propgrp = getPropertyGroups(obj)
            % Customize property display in command window
            
            if ~isscalar(obj)
                
                % Skip customization if nonscalar
                propgrp = obj.getPropertyGroups@matlab.mixin.CustomDisplay();
                
            else
                
                % Start with all properties
                p1 = properties(obj);
                
                % Threshold group
                isMatch = contains(p1, "Threshold");
                p2 = p1(isMatch);
                p1(isMatch) = [];
                
                % Messages group
                p3 = ["BufferSize","Messages","LastMessage","MessageTable"];
                isMatch = matches(p1, p3);
                p1(isMatch) = [];
                
                % Create property groups
                propgrp = [
                    matlab.mixin.util.PropertyGroup(p1)
                    matlab.mixin.util.PropertyGroup(p2,"Log Level Thresholds:")
                    matlab.mixin.util.PropertyGroup(p3,"Messages:")
                    ];
                
            end %if ~isscalar(obj)
            
        end %function
        
        
        function displayScalarObject(obj)
            
            % Start with default display
            obj.displayScalarObject@matlab.mixin.CustomDisplay();
            
            % Display the recent messages
            msgTable = obj.MessageTable;
            if ~isempty(msgTable)
                fprintf('  Recent Messages:\n\n');
                disp(msgTable);
            end
            
        end %function
        
    end %methods
    
    
    methods (Static, Access = protected)
        
        function msgText = convertExceptionText(mExceptionObj)
            % Convert MException with stack trace to message text
            
            arguments
                mExceptionObj (1,1) MException
            end
            
            msgText = string(mExceptionObj.message);
            
            % Include the stack
            if ~isempty(mExceptionObj.stack)
                msgInputs = [{mExceptionObj.stack.name};{mExceptionObj.stack.line}];
                stackText = sprintf('\n\t\t> %s (line %d)',msgInputs{:});
                msgText = msgText + stackText;
            end
            
        end %function
        
    end %methods
    
    
    
    %% Private Methods
    methods (Sealed, Access = private)
        
        function obj = getSingletonLogger(obj,name)
            % Get a singleton logger
            
            % Define input arguments
            arguments
                obj (1,1) mlog.Logger
                name (1,1) string = "Advanced_Logger_for_MATLAB"
            end
            
            % Track a singleton logger for each unique name
            persistent AllLoggers
            if isempty(AllLoggers)
                AllLoggers = mlog.Logger.empty(0);
            end
            AllLoggers(~isvalid(AllLoggers)) = [];
            
            % Is there a match?
            allNames = string([AllLoggers.Name]);
            isMatch = matches(allNames, name);
            if any(isMatch)
                % Yes it exists - return the stored logger
                
                obj = AllLoggers(isMatch);
                
            else
                % No it does not exist - use the newly instantiated object
                % and set the file name
                
                % Add this logger to the persistent list
                obj.Name = name;
                AllLoggers(end+1) = obj;
                
            end %if any(isMatch)
            
        end %function
        
        
        function updateBufferSize(obj, newSize)
            % Updates the buffer size
            
            % Grab the messages in order
            msgObj = obj.Messages;
            
            % Crop if buffer is reduced
            if numel(msgObj) > newSize
                msgObj(1:end-newSize) = [];
            end
            
            % Adjust message buffer size
            obj.MessageBuffer = repmat(obj.MessageBuffer(1), newSize, 1);
            
            % Place messages in buffer
            numMsg = numel(msgObj);
            obj.MessageBuffer(1:numMsg) = msgObj;
            
            % Update counters
            obj.BufferIsWrapped = false;
            obj.BufferIndex = numMsg;
            
        end %function
        
        
        function updateMessageClass(obj)
            % Updates the class of messages if MessageConstructor changes
            
            defaultMessage = obj.MessageConstructor();
            if ~matches(class(defaultMessage), class(obj.MessageBuffer))
                sz = size(obj.MessageBuffer);
                obj.MessageBuffer = repmat(defaultMessage, sz);
                obj.BufferIndex = 0;
                obj.BufferIsWrapped = false;
            end
            
        end %function
        
        
        function fopenLogFile(obj, permission)
            % Open the log file for writing
            
            % Is it already open?
            if ismember(obj.FileID, fopen('all'))
                
                % Do nothing - it's already open
                
            elseif strlength(obj.LogFile)
                
                % Open the file
                [obj.FileID, openMsg] = fopen(obj.LogFile, permission);
                if obj.FileID == -1
                    msg = "Unable to open log file for writing: ''%s''\n%s\n";
                    error(msg, obj.LogFile, openMsg);
                end
                
            end %if strlength(fileName)
            
        end %function
        
        
        function fcloseLogFile(obj)
            % Close the log file for writing
            
            if obj.FileID >= 0
                try
                    fclose(obj.FileID);
                catch
                    warning("mlog:closeInvalidLogFileId",...
                        "Failed to close logfile: %s",...
                        obj.LogFile);
                end
                obj.FileID = -1;
            end %if
            
        end %function
        
    end %private methods
    
    
    
    %% Customize save/load
    methods (Static)
        
        function obj = loadobj(s)
            
            if isstruct(s)
                warning("mlog:loadobjFailed",...
                    "Unable to load saved logger. Creating a new instance.");
                obj = mlog.Logger(s.Name, s.LogFile);
            else
                obj = s;
                obj.fopenLogFile("a");
            end
            
        end %function
        
    end %methods
    
    
    %% Get/Set Methods
    methods
        
        function value = get.Messages(obj)
            % Get the ordered messages from the circular buffer
            if obj.BufferIsWrapped
                value = circshift(obj.MessageBuffer, -obj.BufferIndex);
            else
                value = obj.MessageBuffer(1:obj.BufferIndex, 1);
            end
            
        end %function
        
        
        function value = get.MessageTable(obj)
            % Get a timetable of messages
            value = obj.Messages.toTable();
        end %function
        
        
        function value = get.LastMessage(obj)
            % Get the most recent message
            if obj.BufferIndex > 0
                value = obj.MessageBuffer(obj.BufferIndex);
            else
                value = obj.MessageBuffer([],1);
            end
        end %function
        
        
        function set.LogFile(obj,value)
            obj.fcloseLogFile();
            obj.LogFile = value;
            obj.fopenLogFile("a");
        end %function
        
        
        function set.BufferSize(obj,value)
            obj.updateBufferSize(value);
            obj.BufferSize = value;
        end %function
        
        
        function set.MessageConstructor(obj,value)
            obj.MessageConstructor = value;
            obj.updateMessageClass();
        end %function
        
    end %methods
    
end %classdef

