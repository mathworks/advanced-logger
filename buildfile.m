function plan = buildfile

import matlab.buildtool.Task
import matlab.buildtool.tasks.CodeIssuesTask
import matlab.buildtool.tasks.TestTask
import matlab.buildtool.tasks.PcodeTask
import matlab.unittest.Verbosity

% Create a plan with no tasks
plan = buildplan;

plan("check") = CodeIssuesTask(...
    ["advancedLogger", "test"],...
    Results='results.sarif', ...
    ErrorThreshold=0,...
    WarningThreshold=0);

plan("test") = TestTask("test",...
    TestResults = "results.xml",...
    OutputDetail = Verbosity.Detailed,...
    Strict = true);

plan("package") = Task(...
    "Actions", @(~, version) matlab.addons.toolbox.packageToolbox("deploy/Advanced Logger for MATLAB.prj",sprintf("Advanced Logger for MATLAB %s",version)),...
    "Dependencies",["check", "test"]);

% Set default tasks in the plan
plan.DefaultTasks = ["check" "test"];

end
