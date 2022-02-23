classdef TestLogger < matlab.unittest.TestCase
    % Implements unit tests
    
    % Copyright 2020-2021 The MathWorks, Inc.
    
    
    %% Properties
    properties
        Logger mlog.Logger
    end
    
    
    %% Properties
    properties (SetAccess = protected)
        
        % Count of MessageReceived events per test
        MessageReceivedCount (1,1) double {mustBeInteger, mustBeNonnegative} = 0
        
        % Eventdata of MessageReceived event
        MessageReceivedData (:,1) mlog.Message
        
        % Listener for MessageReceived
        MessageReceivedListener event.listener
        
    end %properties
    
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        
        function clearMessageCounts(testCase)
            
            % Clear the event data
            testCase.MessageReceivedCount = 0;
            testCase.MessageReceivedData(:) = [];
            
        end %function
        
        
        function constructLogger(testCase)
            
            % Create a unique name for the logger, so we have a unique
            % logger for each test
            filePath = tempname() + "_log.txt";
            [~,name] = fileparts(filePath);
            
            % Create a unique logger for each test
            testCase.Logger = mlog.Logger(name, filePath);
            
            % Verify the logger is empty
            % singletons should be destroyed in teardown
            testCase.assertEmpty(testCase.Logger.Messages)
            
            % Set default callback
            testCase.MessageReceivedListener = event.listener(...
                testCase.Logger, "MessageReceived", ...
                @(src,evt)onMessageReceived(testCase, evt) );
            
        end %function
        
    end %methods
    
    
    
    %% Test Method Teardown
    methods (TestMethodTeardown)
        
        function teardown(testCase)
            
            % Get the log file
            if isvalid(testCase.Logger)
                filePath = testCase.Logger.LogFile;
            else
                filePath = "";
            end
            
            % Delete the logger
            delete(testCase.Logger);
            
            % Delete the log file
            if isfile(filePath)
                delete(filePath);
            end
            
        end %function
        
    end %methods
    
    
    
    %% Unit Tests
    methods (Test)
        
        function testDefaults(testCase)
            
            % Get the logger
            logObj = testCase.Logger;
            
            % It should be empty with no messages
            testCase.verifyEmpty(logObj.Messages)
            
            % Default levels should not change
            testCase.verifyEqual(logObj.FileThreshold, ...
                mlog.Level.INFO)
            
            testCase.verifyEqual(logObj.CommandWindowThreshold, ...
                mlog.Level.WARNING)
            
            testCase.verifyEqual(logObj.MessageReceivedEventThreshold, ...
                mlog.Level.MESSAGE)
            
        end %function
        
        
        function testBasicMessaging(testCase)
            % Test messaging options
            
            % Get the logger
            logObj = testCase.Logger;
            
            
            % Write with enumeration for severity
            msg = "Test message 1";
            
            testCase.writeMsg(mlog.Level.ERROR, msg);
            
            testCase.verifyNotEmpty(logObj.Messages)
            testCase.verifyMatches(logObj.LastMessage.Text, msg)
            
            
            % Write with shortcut text for severity
            msg = "Test message 2";
            
            testCase.writeMsg("WARNING",msg);
            
            testCase.verifyMatches(logObj.LastMessage.Text, msg)
            
        end %function
        
        
        function testSprintfMessaging(testCase)
            % Test messaging with sprintf args
            
            % Get the logger
            logObj = testCase.Logger;
            
            
            % Write using sprintf args
            msg = "%s %d";
            args = {"Test", 21};
            expValue = sprintf(msg, args{:});
            
            testCase.writeMsg(mlog.Level.ERROR, msg, args{:});
            
            testCase.verifyNotEmpty(logObj.Messages)
            testCase.verifyMatches(logObj.LastMessage.Text, expValue)
            
        end %function
        
        
        function testMException(testCase)
            % Test messaging with MException
            
            % Get the logger
            logObj = testCase.Logger;
            
            % Create a basic MException
            msg1 = "Test Logger MException 1";
            err1 = MException("test:exception1",msg1);
            
            % Create another MException with a stack
            msg2 = "Test Logger MException 2";
            try
                error("test:exception2",msg2);
            catch err2
            end
            
            
            % Write with the basic MException
            testCase.writeMsg(err1);
            
            testCase.verifyNotEmpty(logObj.Messages)
            testCase.verifyMatches(logObj.LastMessage.Text, msg1)
            
            expLevel = mlog.Level.ERROR;
            testCase.verifyEqual(logObj.LastMessage.Level, expLevel)
            
            
            % Write the MException with a severity level
            testCase.writeMsg("WARNING",err1);
            
            expLevel = mlog.Level.WARNING;
            testCase.verifyEqual(logObj.LastMessage.Level, expLevel)
            
            
            % Write with the MException that has stack info
            testCase.writeMsg(err2);
            
            % Get an approximation of what the message should have, without
            % the line numbers. The actual message should be longer.
            expMsgPart = strjoin(string({err2.message err2.stack.name}), newline);
            
            % Verify the actual message is longer than the approximation
            expMsgMinLength = strlength(expMsgPart);
            actMsgLength = strlength(logObj.LastMessage.Text);
            testCase.verifyGreaterThan(actMsgLength, expMsgMinLength)
            
        end %function
        
        
        function testLogFile(testCase)
            % Test the log file is written
            
            % Get the logger
            logObj = testCase.Logger;
            
            % Write a basic message
            msg = "Test message 1";
            testCase.writeMsg("ERROR", msg);
            testCase.verifyMatches(logObj.LastMessage.Text, msg)
            
            % Read the log file
            logFileData = testCase.readLogFile();
            
            % Verify the date, severity, and message are included
            testCase.verifySubstring(logFileData, logObj.LastMessage.Text)
            testCase.verifySubstring(logFileData, string(logObj.LastMessage.Time))
            testCase.verifySubstring(logFileData, "ERROR")
            
        end %function
        
        
        function testLevelsAndOutput(testCase)
            % Test the log levels and the outputs match
            
            % Get the logger
            logObj = testCase.Logger;
            
            % Adjust the levels
            logObj.CommandWindowThreshold = "ERROR";
            logObj.FileThreshold = "WARNING";
            logObj.MessageReceivedEventThreshold = "INFO";
            
            
            % Write a DEBUG message, capturing command window output
            msgInfo = "Test message - DEBUG";
            commandWindowOutput = testCase.writeMsg("DEBUG", msgInfo);
            
            % Verify no location received it
            testCase.verifyEmpty(commandWindowOutput)
            testCase.verifyEmpty(testCase.readLogFile())
            testCase.verifyEqual(testCase.MessageReceivedCount, 0)
            
            
            % Write an INFO message, capturing command window output
            msgInfo = "Test message - INFO";
            commandWindowOutput = testCase.writeMsg("INFO", msgInfo);
            
            % Verify each location received or didn't receive based on
            % levels
            testCase.verifyEmpty(commandWindowOutput)
            testCase.verifyEmpty(testCase.readLogFile())
            testCase.verifyEqual(testCase.MessageReceivedCount, 1)
            testCase.verifyNotEmpty(testCase.MessageReceivedData)
            lastMessageEvent = testCase.MessageReceivedData(end);
            testCase.verifySubstring(lastMessageEvent.Text, msgInfo)
            
            
            % Write an ERROR message, capturing command window output
            msgInfo = "Test message - ERROR";
            commandWindowOutput = testCase.writeMsg("ERROR", msgInfo);
            
            % Verify all locations received it
            testCase.verifySubstring(commandWindowOutput, msgInfo)
            testCase.verifySubstring(testCase.readLogFile(), msgInfo)
            testCase.verifyEqual(testCase.MessageReceivedCount, 2)
            lastMessageEvent = testCase.MessageReceivedData(end);
            testCase.verifySubstring(lastMessageEvent.Text, msgInfo)
            
        end %function
        
        
        function testSendToDialog(testCase)
            % Test sending a message to a dialog window
            
            msg = "Send this error to a dialog";
            [~,msgObj] = testCase.writeMsg("ERROR",msg);
            
            % Make a temporary figure
            fig = uifigure;
            cleanupObj = onCleanup(@()delete(fig));
            
            % Send the message to a dialog in the figure
            fcn = @()toDialog(msgObj, fig);
            testCase.verifyWarningFree(fcn);
            
        end %function
        
        
        function testBufferSizeChanges(testCase)
            % Test buffer size changes
            
            % Get the logger
            logObj = testCase.Logger;
            
            % Set a small buffer for testing
            logObj.BufferSize = 5;
            
            % Write messages
            for idx = 1:3
                testCase.writeMsg(mlog.Level.ERROR, string(idx) );
            end
            
            % Increase buffer size
            logObj.BufferSize = 7;
            
            % Validate the messages are in sequence
            msgText = logObj.MessageTable.Text;
            testCase.verifyEqual(msgText, string(1:3)')
            
            % Write more messages and wrap the buffer
            for idx = 4:10
                testCase.writeMsg(mlog.Level.ERROR, string(idx) );
            end
            
            % Decrease buffer size
            logObj.BufferSize = 5;
            
            % Validate the messages are in sequence
            msgText = logObj.MessageTable.Text;
            testCase.verifyEqual(msgText, string(6:10)')
            
            % Write more messages and wrap the buffer
            for idx = 11:12
                testCase.writeMsg(mlog.Level.ERROR, string(idx) );
            end
            
            % Validate the messages are in sequence
            msgText = logObj.MessageTable.Text;
            testCase.verifyEqual(msgText, string(8:12)')
            
            % Increase buffer size
            logObj.BufferSize = 10;
            
            % Validate the messages are in sequence
            msgText = logObj.MessageTable.Text;
            testCase.verifyEqual(msgText, string(8:12)')
            
            % Verify error if buffer < 1
            fcn = @()set(logObj,"BufferSize",0);
            testCase.verifyError(fcn,'MATLAB:validators:mustBePositive');
            
        end %function
        
        
        function testSaveLoad(testCase)
            % Test save and load a logger full of messages
            
            % Get the logger
            logObj = testCase.Logger;
            
            % Decrease buffer size
            logObj.BufferSize = 5;
            
            % Write messages
            for idx = 1:7
                testCase.writeMsg(mlog.Level.ERROR, string(idx) );
            end
            
            % Save the logger to file
            fileName = tempname() + ".mat";
            save(fileName,'logObj');
            
            % Ensure we remove the temp file
            cleanupObj = onCleanup(@()delete(fileName));
            
            % Now, we must explicitly destroy the local logger
            delete(logObj);
            
            % Load the logger back in
            s = load(fileName);
            logObj = s.logObj;
            testCase.Logger = logObj;
            
            % Write messages
            for idx = 8:10
                testCase.writeMsg(mlog.Level.ERROR, string(idx) );
            end
            
            % Validate the messages are in sequence
            msgText = logObj.MessageTable.Text;
            testCase.verifyEqual(msgText, string(6:10)')
            
        end %function
        

        function testShortcuts(testCase)
            
            % Get the logger
            logObj = testCase.Logger;
            
            % Adjust the levels
            logObj.CommandWindowThreshold = "DEBUG";
            logObj.MessageReceivedEventThreshold = "DEBUG";

            
            % It should be empty with no messages
            testCase.verifyEmpty(logObj.Messages)
            
            % Test each level
            msg = "Test Message";

            logObj.fatal(msg)
            lastMsg = logObj.LastMessage;
            testCase.verifyEqual(lastMsg.Level, mlog.Level.FATAL)

            logObj.critical(msg)
            lastMsg = logObj.LastMessage;
            testCase.verifyEqual(lastMsg.Level, mlog.Level.CRITICAL)

            logObj.error(msg)
            lastMsg = logObj.LastMessage;
            testCase.verifyEqual(lastMsg.Level, mlog.Level.ERROR)

            logObj.warning(msg)
            lastMsg = logObj.LastMessage;
            testCase.verifyEqual(lastMsg.Level, mlog.Level.WARNING)

            logObj.info(msg)
            lastMsg = logObj.LastMessage;
            testCase.verifyEqual(lastMsg.Level, mlog.Level.INFO)

            logObj.message(msg)
            lastMsg = logObj.LastMessage;
            testCase.verifyEqual(lastMsg.Level, mlog.Level.MESSAGE)

            logObj.debug(msg)
            lastMsg = logObj.LastMessage;
            testCase.verifyEqual(lastMsg.Level, mlog.Level.DEBUG)
            
        end %function
        
    end %methods
    
    
    
    %% Helper Methods
    methods (Access = protected)
        
        function [str, msgObj] = writeMsg(testCase, varargin) %#ok<STOUT,INUSD>
            % Write logger message SILENTLY and capture command window output
            
            str = evalc('msgObj = testCase.Logger.write(varargin{:});');
            
        end %function
        
        
        function str = readLogFile(testCase)
            % Reads the log file and returns the data

            % Default to empty
            str = string.empty();

            % Read the file if it exists
            filePath = testCase.Logger.LogFile;
            if strlength(filePath) && isfile(filePath)

                % Read the log file
                if verLessThan('matlab','9.9')
                    str = readcell(filePath,'FileType','text',...
                        'ExpectedNumVariables',1,'Delimiter',newline);
                    str = string(str);
                else
                    str = readlines(filePath,"EmptyLineRule","skip");
                end

            end

        end %function
        
        
        function onMessageReceived(testCase, evt)
            % Callback for MessageReceived listener
            
            % Append the event data
            testCase.MessageReceivedCount = testCase.MessageReceivedCount + 1;
            testCase.MessageReceivedData(end+1) = evt;
            
        end %function
        
    end %methods
    
end %classdef