# Advanced Logger for MATLAB

[![View Advanced Logger for MATLAB on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://www.mathworks.com/matlabcentral/fileexchange/87322-advanced-logger-for-matlab)

Advanced Logger for MATLAB provides configurable and extensible logging capabilites for MATLAB applications.

This logger can be configured to write to multiple outputs:

 - A log file in text format
 - Command window output
 - A public event that can be listened to (for example, if you want to show the user a log of informational events in your MATLAB app)

Each of these outputs can be individually configured with the minimum severity level of messages to be written. 

Give your logger a unique name and it will be globally available as a singleton instance. This is because a single instance of Logger must manage the log file being written to.  You can access the logger from multiple places in your code given its unique name.  (There is no need to pass around the logger's object handle throughout your code!)

The logger is extensible for additional message fields, message formatting, etc.


Planning a complex or business-critical app? MathWorks Consulting can advise you on design, architecture, and performance: https://www.mathworks.com/services/consulting/proven-solutions/software-development-with-matlab.html
