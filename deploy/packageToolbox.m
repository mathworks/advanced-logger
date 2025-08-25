function toolboxOptions = packageToolbox(toolboxVersion)
%GENERATETOOLBOX Function that generates a toolbox for the boss device API

arguments
    toolboxVersion matlab.mpm.Version
end

% Get current project object
projObj = currentProject;

% Toolbox Parameter Configuration
toolboxOptions = matlab.addons.toolbox.ToolboxOptions(fullfile(projObj.RootFolder,"advancedLogger"),'fd9733c5-082a-4325-a5e5-e7490cdb8fb1');

toolboxOptions.ToolboxName = "Advanced Logger for MATLAB";
toolboxOptions.ToolboxVersion = toolboxVersion.string;
toolboxOptions.Summary = projObj.Description;
toolboxOptions.Description = "For a more detailed description refer to the toolbox README.md file.";
toolboxOptions.AuthorName = "Robyn Jackey";
toolboxOptions.AuthorEmail = "rjackey@mathworks.com";
toolboxOptions.AuthorCompany = "MathWorks Consulting";
toolboxOptions.ToolboxImageFile = fullfile(projObj.RootFolder,"deploy/toolbox_logo.png");
toolboxOptions.ToolboxGettingStartedGuide = fullfile(projObj.RootFolder,"advancedLogger","doc","gettingStarted.mlx");

if ~exist(fullfile(projObj.RootFolder,"releases"), 'dir')
    mkdir(fullfile(projObj.RootFolder,"releases"))
end
toolboxOptions.OutputFile = fullfile(projObj.RootFolder,sprintf("releases/Advanced Logger for MATLAB %s.mltbx",toolboxVersion.string));

toolboxOptions.MinimumMatlabRelease = "R2019b";
% toolboxOptions.MaximumMatlabRelease = "R2023a"; % Won't limit maximum MATLAB release
toolboxOptions.SupportedPlatforms.Glnxa64 = true;
toolboxOptions.SupportedPlatforms.Maci64 = true;
toolboxOptions.SupportedPlatforms.MatlabOnline = true;
toolboxOptions.SupportedPlatforms.Win64 = true;

% Generate toolbox
matlab.addons.toolbox.packageToolbox(toolboxOptions);

end