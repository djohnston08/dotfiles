-------------------------------------------------------------------
-- Portrait Monitor Layouts Module
-- Handles portrait monitor detection and specialized layouts
-------------------------------------------------------------------

local hyper = { "cmd", "alt", "ctrl", "shift" }

-- Portrait-specific layout units (height > width monitors)
local portraitUnits = {
  top20         = { x = 0.00, y = 0.00, w = 1.00, h = 0.20 },  -- Spotify position
  top30         = { x = 0.00, y = 0.00, w = 1.00, h = 0.30 },
  top40         = { x = 0.00, y = 0.00, w = 1.00, h = 0.40 },
  middle30      = { x = 0.00, y = 0.20, w = 1.00, h = 0.30 },  -- Below Spotify
  middle40      = { x = 0.00, y = 0.30, w = 1.00, h = 0.40 },
  bottom50      = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
  bottom60      = { x = 0.00, y = 0.40, w = 1.00, h = 0.60 },
  bottom70      = { x = 0.00, y = 0.30, w = 1.00, h = 0.70 },
  thirds_top    = { x = 0.00, y = 0.00, w = 1.00, h = 0.33 },
  thirds_mid    = { x = 0.00, y = 0.33, w = 1.00, h = 0.34 },
  thirds_bot    = { x = 0.00, y = 0.67, w = 1.00, h = 0.33 },
  maximum       = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
}

-- Monitor detection functions
local function getPortraitScreen()
  for _, screen in ipairs(hs.screen.allScreens()) do
    local mode = screen:currentMode()
    if mode.h > mode.w then
      return screen
    end
  end
  return nil
end

local function getLandscapeScreens()
  local landscape = {}
  for _, screen in ipairs(hs.screen.allScreens()) do
    local mode = screen:currentMode()
    if mode.w > mode.h then
      table.insert(landscape, screen)
    end
  end
  return landscape
end

-- Helper function to show alert on specific screen
local function showAlertOnScreen(message, screen, duration)
  duration = duration or 2
  if screen then
    local frame = screen:frame()
    hs.alert.show(message, {
      textSize = 24,
      fadeInDuration = 0.25,
      fadeOutDuration = 0.25,
      strokeWidth = 0,
      fillColor = {white = 0, alpha = 0.75},
      textColor = {white = 1, alpha = 1}
    }, screen, duration)
  else
    hs.alert.show(message, duration)
  end
end

-- Spotify portrait positioning
local function positionSpotifyOnPortrait()
  local portraitScreen = getPortraitScreen()
  if not portraitScreen then 
    hs.alert.show("No Portrait Monitor detected", 2)
    return 
  end
  
  local spotify = hs.application.get('Spotify')
  if spotify then
    local windows = spotify:allWindows()
    for _, window in ipairs(windows) do
      window:move(portraitUnits.top20, portraitScreen, true)
    end
    showAlertOnScreen("Spotify positioned", portraitScreen, 1.5)
  else
    showAlertOnScreen("Spotify not running", portraitScreen, 2)
  end
end

-- Portrait layout definitions
local portraitLayouts = {
  productivity = {
    { app = 'Spotify',        unit = portraitUnits.top20 },      -- Top 20%
    { app = 'Google Chrome',  unit = portraitUnits.middle30 },   -- Middle 30% (20-50%)
    { app = 'Slack',          unit = portraitUnits.bottom50 },   -- Bottom 50%
  },
  monitoring = {
    { app = 'Activity Monitor', unit = portraitUnits.top40 },    -- Top 40%
    { app = 'Console',          unit = portraitUnits.bottom60 }, -- Bottom 60%
  },
  communication = {
    { app = 'Slack',       unit = portraitUnits.thirds_top },    -- Top third
    { app = 'Messages',    unit = portraitUnits.thirds_mid },    -- Middle third
    { app = 'Discord',     unit = portraitUnits.thirds_bot },    -- Bottom third
  },
  coding = {
    { app = 'Spotify',          unit = portraitUnits.top20 },    -- Top 20%
    { app = 'iTerm',            unit = portraitUnits.bottom70 }, -- Bottom 70% (overlaps for terminal)
  }
}

-- Debug function to show current portrait screen info
local function debugPortraitScreen()
  local allScreens = hs.screen.allScreens()
  local messages = {}
  
  for i, screen in ipairs(allScreens) do
    local mode = screen:currentMode()
    local frame = screen:frame()
    local name = screen:name()
    local orientation = mode.h > mode.w and "PORTRAIT" or "LANDSCAPE"
    
    table.insert(messages, string.format("%d. %s: %dx%d %s", 
      i, name, mode.w, mode.h, orientation))
  end
  
  local portraitScreen = getPortraitScreen()
  if portraitScreen then
    table.insert(messages, "\nDetected portrait: " .. portraitScreen:name())
    -- Show on the detected portrait screen
    showAlertOnScreen(table.concat(messages, "\n"), portraitScreen, 5)
  else
    table.insert(messages, "\nNo portrait monitor detected!")
    hs.alert.show(table.concat(messages, "\n"), 5)
  end
end

-- Portrait layout runner
local function runPortraitLayout(layoutName)
  local portraitScreen = getPortraitScreen()
  if not portraitScreen then 
    hs.alert.show("No Portrait Monitor detected", 2)
    return 
  end
  
  local layout = portraitLayouts[layoutName]
  if not layout then
    showAlertOnScreen("Layout '" .. layoutName .. "' not found", portraitScreen, 2)
    return
  end
  
  -- Apply layout with slight delays to ensure proper positioning
  for i, item in ipairs(layout) do
    local app = hs.application.get(item.app)
    if app then
      local windows = app:allWindows()
      for _, window in ipairs(windows) do
        -- Add small delay between window moves to prevent overlap issues
        hs.timer.doAfter(0.1 * (i-1), function()
          window:move(item.unit, portraitScreen, true)
        end)
      end
    end
  end
  
  showAlertOnScreen(layoutName:gsub("^%l", string.upper) .. " layout applied", portraitScreen, 1.5)
end

-- Portrait hotkeys (Voyager Layer: hyper + numbers)
hs.hotkey.bind(hyper, "9", function()
  positionSpotifyOnPortrait()  -- Quick Spotify positioning
end)

hs.hotkey.bind(hyper, "6", function() 
  runPortraitLayout("productivity")  -- Portrait productivity layout
end)

hs.hotkey.bind(hyper, "5", function() 
  runPortraitLayout("monitoring")    -- Portrait monitoring layout  
end)

hs.hotkey.bind(hyper, "4", function() 
  runPortraitLayout("communication") -- Portrait communication layout
end)

hs.hotkey.bind(hyper, "3", function() 
  runPortraitLayout("coding")        -- Portrait coding layout
end)

hs.hotkey.bind(hyper, "2", function()
  debugPortraitScreen()              -- Debug portrait screen info
end)

-- Auto-position Spotify when launched
local appWatcher = hs.application.watcher.new(function(name, event, app)
  if name == "Spotify" and event == hs.application.watcher.launched then
    hs.timer.doAfter(1, positionSpotifyOnPortrait)
  end
end)
appWatcher:start()