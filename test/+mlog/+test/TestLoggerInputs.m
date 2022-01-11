classdef TestLoggerInputs < matlab.unittest.TestCase
    % Implements unit tests
    
    % Copyright 2020-2021 The MathWorks, Inc.
    
    
    %% Properties
    properties
        LoggerA mlog.Logger
        LoggerB mlog.Logger
    end
    
    
    %% Test Method Teardown
    methods (TestMethodTeardown)
        
        function teardown(testCase)
            
            % Get the log files
            if isvalid(testCase.LoggerA)
                filePathA = testCase.LoggerA.LogFile;
            else
                filePathA = "";
            end
            if isvalid(testCase.LoggerB)
                filePathB = testCase.LoggerB.LogFile;
            else
                filePathB = "";
            end
            
            % Delete the logger
            delete(testCase.LoggerA);
            delete(testCase.LoggerB);
            
            % Delete the log file
            if isfile(filePathA)
                delete(filePathA);
            end
            if isfile(filePathB)
                delete(filePathB);
            end
            
        end %function
        
    end %methods
    
    
    
    %% Unit Tests
    methods (Test)
        
        function testZeroArguments(testCase)
            
            % Verify warning-free construction
            fcnConstruct = @()mlog.Logger();
            testCase.LoggerA = testCase.verifyWarningFree(fcnConstruct);
            
            % Assert the logger is empty
            % singletons should be destroyed in teardown
            testCase.assertEmpty(testCase.LoggerA.Messages)
            
        end %function
        
        
        function testOneArgument(testCase)
            % Test messaging options
            
            % Prepare inputs
            filePath = string(tempname());
            [~,name] = fileparts(filePath);
            
            % Verify warning-free construction
            fcnConstruct = @()mlog.Logger(name);
            testCase.LoggerA = testCase.verifyWarningFree(fcnConstruct);
            
            % Assert the logger is empty
            % singletons should be destroyed in teardown
            testCase.assertEmpty(testCase.LoggerA.Messages)
            
            
            % Get the singleton logger using just the name
            testCase.LoggerB = mlog.Logger(name);
            
            % Assert they are the same logger and file path
            testCase.assertEqual(testCase.LoggerA, testCase.LoggerB)
            
        end %function
        
        
        function testTwoArguments(testCase)
            % Test messaging with sprintf args
            
            % Prepare inputs
            filePath = string(tempname());
            [~,name] = fileparts(filePath);
            
            % Verify warning-free construction
            fcnConstruct = @()mlog.Logger(name, filePath);
            testCase.LoggerA = testCase.verifyWarningFree(fcnConstruct);
            
            % Assert the logger is empty
            % singletons should be destroyed in teardown
            testCase.assertEmpty(testCase.LoggerA.Messages)
            
            
            % Get the singleton logger using the same name and path
            testCase.LoggerB = mlog.Logger(name, filePath);
            
            % Assert they are the same logger and file path
            testCase.assertEqual(testCase.LoggerA, testCase.LoggerB)
            testCase.assertEqual(testCase.LoggerA.LogFile, filePath)
            testCase.assertEqual(testCase.LoggerB.LogFile, filePath)
            
            
            % Get the singleton logger using just the name
            testCase.LoggerB = mlog.Logger(name);
            
            % Assert they are the same logger and file path
            testCase.assertEqual(testCase.LoggerA, testCase.LoggerB)
            testCase.assertEqual(testCase.LoggerA.LogFile, filePath)
            testCase.assertEqual(testCase.LoggerB.LogFile, filePath)
            
        end %function
        
    end %methods
    
end %classdef