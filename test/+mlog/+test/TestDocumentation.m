classdef TestDocumentation < matlab.unittest.TestCase
    % Implements unit tests
    
    % Copyright 2020-2024 The MathWorks, Inc.
    
    %% Constants
    properties (Constant)
        
        ProjectID = "advanced-logger";
        
    end %properties
    
    
    
    %% Unit Tests
    methods (Test)
        
        function testGettingStarted(testCase)
            
            % Project must be loaded
            proj = currentProject();
            testCase.assumeNotEmpty(proj);
            testCase.assumeEqual(proj.Name, testCase.ProjectID);
            
            % Locate GettingStarted.mlx
            filePath = fullfile(proj.RootFolder, ...
                "advancedLogger", "doc", "GettingStarted.mlx");
            
            % Did we find it?
            testCase.fatalAssertTrue(isfile(filePath),...
                "Unable to locate GettingStarted.mlx");
            
            % Run the file
            runFcn = @()runScriptFile(filePath);
            testCase.verifyWarningFree(runFcn);
            
        end %function
        
        
        function testCustomizingLogger(testCase)
            
            % Project must be loaded
            proj = currentProject();
            testCase.assumeNotEmpty(proj);
            testCase.assumeEqual(proj.Name, testCase.ProjectID);
            
            % Locate the file
            filePath = fullfile(proj.RootFolder, ...
                "advancedLogger", "examples", "CustomizingLogger.mlx");
            
            % Did we find it?
            testCase.fatalAssertTrue(isfile(filePath),...
                "Unable to locate CustomizingLogger.mlx");
            
            % Run the file
            runFcn = @()runScriptFile(filePath);
            testCase.verifyWarningFree(runFcn);
            
        end %function
        
    end %methods
    
    
end %classdef


function runScriptFile(filePath)
% Run the script in a non-static workspace


% What figures are currently open?
openFig = findall(groot,"Type","figure");

% What editor files are currently open?
openDocs = matlab.desktop.editor.getAll();

% Prep for cleanup
cleanupObj = onCleanup(@()cleanupFcn(openFig, openDocs, pwd));

% Change directory
[filePath, fileName] = fileparts(filePath);
cd(filePath);

% Run the script with no output
evalc(fileName);

% Delete the loggers created by the GettingStarted.mlx
logObj = mlog.Logger("MyApp");
delete(logObj)

end %function



function cleanupFcn(existingFig, existingDocs, existingDir)

% Close any figures that weren't there before
newFig = setdiff(findall(groot,"Type","figure"), existingFig);
close(newFig)

% Close any editor documents that weren't there before
newDocs = setdiff(matlab.desktop.editor.getAll(), existingDocs);
close(newDocs)

% Go to original directory
cd(existingDir)

% Close any open files
fclose all;

end %function