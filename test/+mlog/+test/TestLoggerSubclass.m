classdef TestLoggerSubclass < mlog.test.TestLogger
    % Implements unit tests
    
    % Copyright 2021 The MathWorks, Inc.
    
    
    %% Test Class Setup
    methods (TestClassSetup)
        
        function repaceMessageClass(testCase)
            % Replace message class
            
            testCase.MessageReceivedData = ...
                mlog.example.MessageSubclass.empty(0,1);
            
        end %function
        
    end %methods
    
    
    %% Test Method Setup
    methods (TestMethodSetup)
        
        function constructLogger(testCase)
            % Override construction to use subclass logger
            
            % Create a unique name for the logger, so we have a unique
            % logger for each test
            filePath = tempname();
            [~,name] = fileparts(filePath);
            
            % Create a unique logger for each test
            testCase.Logger = mlog.example.LoggerSubclass(name, filePath);
            
            % Verify the logger is empty
            % singletons should be destroyed in teardown
            testCase.verifyEmpty(testCase.Logger.Messages)
            
            % Set default callback
            testCase.MessageReceivedListener = event.listener(...
                testCase.Logger, "MessageReceived", ...
                @(src,evt)onMessageReceived(testCase, evt) );
            
        end %function
        
    end %methods
    
    
    
    %% Unit Tests
    methods (Test)
       
        function testMessageTable(testCase)
            % Test a subclass logger
            
            % Verify the default table size
            testCase.verifySize(testCase.Logger.MessageTable, [0 5])
            
            % Write messages
            for idx = 1:3
                testCase.writeMsg(mlog.Level.ERROR, string(idx) );
            end
            
            % Verify the current table size
            testCase.verifySize(testCase.Logger.MessageTable, [3 5])
            
            % Verify the property names in the table
            expVal = ["Time","Level","CustomString","CustomNumber","Text"];
            actVal = string(testCase.Logger.MessageTable.Properties.VariableNames);
            testCase.verifyEqual(actVal, expVal);
            
        end %function
        
    end %methods
    
    
    
    %% Helper Methods
    methods (Access = protected)
        
        function [str, msgObj] = writeMsg(testCase, varargin) %#ok<STOUT,INUSD>
            % Override helper to pass custom subclass arguments
            
            str = evalc('msgObj = testCase.Logger.write("custom str",5,varargin{:});');
            
        end %function
        
    end %methods
    
end %classdef