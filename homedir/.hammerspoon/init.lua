-------------------------------------------------------------------
-- Globals
-------------------------------------------------------------------
hs.loadSpoon("GlobalMute")
hs.window.animationDuration = 0

local hyper = { "cmd", "alt", "ctrl", "shift" }

macbook_monitor = "Built-in Retina Display"
primary_monitor = "DELL U2415"
-- workLeft = 441053383
-- workRight = 441053385
-- homeLeft = 724069851
-- homeRight = 724073693

-------------------------------------------------------------------
-- Window Layouts
-------------------------------------------------------------------

-- These are just convenient names for layouts. We can use numbers
-- between 0 and 1 for defining 'percentages' of screen real estate
-- so 'right30' is the window on the right of the screen where the
-- vertical split (x-axis) starts at 70% of the screen from the
-- left, and is 30% wide.
--
-- And so on...
units = {
  right30       = { x = 0.70, y = 0.00, w = 0.30, h = 1.00 },
  right70       = { x = 0.30, y = 0.00, w = 0.70, h = 1.00 },
  left70        = { x = 0.00, y = 0.00, w = 0.70, h = 1.00 },
  left30        = { x = 0.00, y = 0.00, w = 0.30, h = 1.00 },
  top50         = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
  bot50         = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
  bot80         = { x = 0.00, y = 0.20, w = 1.00, h = 0.80 },
  bot87         = { x = 0.00, y = 0.20, w = 1.00, h = 0.87 },
  bot90         = { x = 0.00, y = 0.20, w = 1.00, h = 0.90 },
  upright30     = { x = 0.70, y = 0.00, w = 0.30, h = 0.50 },
  botright30    = { x = 0.70, y = 0.50, w = 0.30, h = 0.50 },
  upleft70      = { x = 0.00, y = 0.00, w = 0.70, h = 0.50 },
  botleft70     = { x = 0.00, y = 0.50, w = 0.70, h = 0.50 },
  right70top80  = { x = 0.70, y = 0.00, w = 0.30, h = 0.80 },
  maximum       = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
  center        = { x = 0.20, y = 0.10, w = 0.60, h = 0.80 },
  centerSmall   = { x = 0.25, y = 0.20, w = 0.50, h = 0.60 },
  centerBig     = { x = 0.05, y = 0.05, w = 0.90, h = 0.90 }
}

hs.hotkey.bind(hyper, "0", function()
  hs.reload()
end)
hs.notify.new({title="Hammerspoon", informativeText="Config loaded"}):send()

hs.hotkey.bind(hyper, "h", function()
  local win = hs.window.focusedWindow();
  if not win then return end
win:moveToUnit(hs.layout.left50)
end)
hs.hotkey.bind(hyper, "j", function()
  local win = hs.window.focusedWindow();
  if not win then return end
win:moveToUnit(hs.layout.maximized)
end)
hs.hotkey.bind(hyper, "k", function()
  local win = hs.window.focusedWindow();
  if not win then return end
win:moveToScreen(win:screen():next())
end)
hs.hotkey.bind(hyper, "l", function()
  local win = hs.window.focusedWindow();
  if not win then return end
win:moveToUnit(hs.layout.right50)
end)
hs.hotkey.bind(hyper, "1", function()
  local win = hs.window.focusedWindow();
  if not win then return end
win:move(units.centerBig, nil, true)
end)

hs.hotkey.bind(hyper, "\\", function ()
  hs.spotify.displayCurrentTrack();
end)

hs.hotkey.bind(hyper, "pageup", function ()
  hs.spotify.volumeUp();
end)

hs.hotkey.bind(hyper, "pagedown", function ()
  hs.spotify.volumeDown();
end)

-- There is a 'layout' plugin but it was more difficult for me to
-- understand than it was for me to just write my own, so this is
-- my definitions for defining the layouts for all of the apps
-- that I tend to use.
layouts = {
--   coding = {
--     -- { name = 'VimR',    unit = units.left70 },
--     { name = 'Firefox',           app = 'Firefox.app',           unit = units.left70 },
--     { name = 'MacVim',            app = 'MacVim.app',            unit = units.left70 },
--     { name = 'iTerm2',            app = 'iTerm2.app',            unit = units.right30 }
--   },
  -- I'll use 'work' as my example. If I want to position the windows of
  -- all of these applications, then I simply specify 'layouts.work' and 
  -- then the layout engine will move all of the windows for these apps to
  -- the right monitor and in the right position on that monitor.

  -- build start of day, start of programming work, end of day, etc routines

  planning = {
    { name = 'Sunsama',            app = 'Sunsama.app',         unit = units.centerBig, screen = macbook_monitor },
    { name = 'Roam',            app = 'Roam Research.app',         unit = units.centerBig, screen = primary_monitor },
  },
  work = {
    { name = 'PhpStorm',            app = 'PhpStorm.app',         unit = units.maximum, screen = primary_monitor },
    { name = 'iTerm2',            app = 'iTerm.app',              unit = units.maximum, screen = macbook_monitor },
    { name = 'Slack',             app = 'Slack.app',              unit = units.center,   screen = macbook_monitor },
    { name = 'Google Chrome',     app = 'Google Chrome.app',      unit = units.centerBig, screen = primary_monitor },
    { name = 'Sunsama',            app = 'Sunsama.app',             unit = units.centerBig, screen = macbook_monitor }
  }
}

-- Takes a layout definition (e.g. 'layouts.work') and iterates through
-- each application definition, laying it out as speccified
function runLayout(layout)
  for i = 1,#layout do
    local t = layout[i]
    local theapp = hs.application.get(t.name)
    if windows == nil then
      hs.application.open(t.app)
      theapp = hs.application.get(t.name)
    end
    local windows = theapp:allWindows()
    local screen = nil
    if t.screen ~= nil then
      screen = hs.screen.find(t.screen)
    end
    for i, w in ipairs(windows) do
        w:move(t.unit, screen, true)
    end
  end
end

-- All of the mappings for moving the window of the 'current' application
-- to the right spot. Tries to map 'vim' keys as much as possible, but
-- deviates to a 'visual' representation when that's not possible.
mash = { 'shift', 'ctrl', 'alt' }
hs.hotkey.bind(mash, 'l', function() hs.window.focusedWindow():move(units.right30,    nil, true) end)
hs.hotkey.bind(mash, 'h', function() hs.window.focusedWindow():move(units.left70,     nil, true) end)
hs.hotkey.bind(mash, 'k', function() hs.window.focusedWindow():move(units.top50,      nil, true) end)
hs.hotkey.bind(mash, 'j', function() hs.window.focusedWindow():move(units.bot50,      nil, true) end)
hs.hotkey.bind(mash, ']', function() hs.window.focusedWindow():move(units.upright30,  nil, true) end)
hs.hotkey.bind(mash, '[', function() hs.window.focusedWindow():move(units.upleft70,   nil, true) end)
hs.hotkey.bind(mash, ';', function() hs.window.focusedWindow():move(units.botleft70,  nil, true) end)
hs.hotkey.bind(mash, "'", function() hs.window.focusedWindow():move(units.botright30, nil, true) end)
hs.hotkey.bind(mash, 'm', function() hs.window.focusedWindow():move(units.maximum,    nil, true) end)
hs.hotkey.bind(mash, 'i', function() hs.window.focusedWindow():move(units.centerSmall,    nil, true) end)
hs.hotkey.bind(mash, 'o', function() hs.window.focusedWindow():move(units.center,    nil, true) end)
hs.hotkey.bind(mash, 'p', function() hs.window.focusedWindow():move(units.centerBig,    nil, true) end)
hs.hotkey.bind(mash, 'y', function() hs.window.focusedWindow():centerOnScreen() end)

-- The goal here is to bind mash+0 and mash+9 to the grander layouts
-- but there's a quick difference depending on whether or not I happen
-- to be on my work machine or not
hs.hotkey.bind(hyper, '8', function() runLayout(layouts.work) end)
hs.hotkey.bind(hyper, '7', function() runLayout(layouts.planning) end)

-------------------------------------------------------------------
-- Deep Work
--
-- Some functions that will disable notifications for a specified
-- number of minutes, setting a timer that will enable them once
-- it completes
-------------------------------------------------------------------

deepWorkTimer = nil

function enableDoNotDisturb()
  local dt = os.date("!%Y-%m-%d %H:%M:%S +000")
  local output, status, typ, rc = hs.execute("defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean true")
  if rc == 0 then
    local output, status, typ, rc = hs.execute("defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturbDate -date '" .. dt .. "'")
    if rc == 0 then
      local output, status, typ, rc = hs.execute("killall NotificationCenter")
      return output, status, typ, rc
    else
      return output, status, typ, rc
    end
  else
    return output, status, typ, rc
  end
end

function disableDoNotDisturb()
  local output, status, typ, rc = hs.execute("defaults -currentHost write ~/Library/Preferences/ByHost/com.apple.notificationcenterui doNotDisturb -boolean false")
  if rc == 0 then
    local output, status, typ, rc = hs.execute("killall NotificationCenter")
    return output, status, typ, rc
  else
    return output, status, typ, rc
  end
end

function displayAlertDialog(msg)
  local screen = hs.screen.mainScreen():currentMode()
  local width = screen["w"]
  hs.dialog.alert((width / 2) - 80, 25, function() end, msg)
end

function resumeNotifications()
  if deepWorkTimer ~= nil and deepWorkTimer:running() then
    deepWorkTimer:stop()
  end
  deepWorkTimer = nil
  local output, status, typ, rc = disableDoNotDisturb()
  if rc ~= 0 then
    displayAlertDialog("Failed to start notifications: " .. output)
  end
end

function stopNotifcations(minutes)
  local output, status, typ, rc = enableDoNotDisturb()
  if rc ~= 0 then
    displayAlertDialog("Failed to stop notifications: " .. output)
  else
    deepWorkTimer = hs.timer.doAfter(minutes * 60, function() resumeNotifications(); displayAlertDialog("Deep Work has ended"); return 0 end)
  end
end

function interrogateDeepWorkTimer()
  if deepWorkTimer == nil then
    displayAlertDialog("Deep Work timer isn't running")
  else
    local secs = math.floor(deepWorkTimer:nextTrigger() % 60)
    local mins = math.floor(deepWorkTimer:nextTrigger() / 60)
    displayAlertDialog(string.format("There is %02d:%02d left for deep work", mins, secs))
  end
end

function deepwork()
  resumeNotifications()
  local code, mins = hs.dialog.textPrompt("How many minutes for deep work?", "", "90", "OK", "Cancel")
  if code == "OK" then
    local minNumber = tonumber(mins)
    if minNumber == nil then
      displayAlertDialog(string.format("'%s' is not a valid number of minutes", mins))
    else
      stopNotifcations(minNumber)
    end
  end
end

local applicationHotkeys = {
  c = 'Google Chrome',
  t = 'iTerm',
  s = 'Slack',
  p = 'PhpStorm',
  n = 'Obsidian',
  -- n = 'Notion',
  m = 'DataGrip',
  i = 'Messages',
  f = 'Fantastical',
  v = 'Visual Studio Code',
  y = 'Spotify',
  x = 'Microsoft Excel',
  -- w = 'Calendar',
  z = 'News',
  -- d = 'Sunsama',
  e = 'Superhuman',
  g = 'OpenLens',
  r = 'Postman',
  d = 'Reminders',
  q = 'Discord',
  w = 'Claude',
  u = 'Granola',
  b = 'Miro',
  z = 'Keymapp',
  a = 'ChatGPT',
}

for key, app in pairs(applicationHotkeys) do
  hs.hotkey.bind(hyper, key, function()
    hs.application.launchOrFocus(app)
  end)
end

-- -- Map global mic mute/unmute
-- spoon.GlobalMute:bindHotkeys({
--   toggle = {hyper, "space"}
-- })

-- Switch between Karabiner-Elements profiles by keyboard

function usbDeviceCallback(data)
  if (data["productName"] == "Razer BlackWidow Ultimate 2016") then
      if (data["eventType"] == "added") then
        hs.execute("/Library/Application\\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --select-profile win", true)
      elseif (data["eventType"] == "removed") then
        hs.execute("/Library/Application\\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --select-profile mac", true)
      end
  end
end

usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbWatcher:start()

