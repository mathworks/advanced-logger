% Run project startup tasks

% Copyright 2019-2024 The MathWorks, Inc.


%% Re-enable any installed version

% Get installed addons
addonInfo = matlab.addons.installedAddons();

% Addon ID
addonId = "fd9733c5-082a-4325-a5e5-e7490cdb8fb1"; % Advanced Logger for MATLAB

% Enable
if ismember(addonId, addonInfo.Identifier)
    matlab.addons.enableAddon(addonId);
end
