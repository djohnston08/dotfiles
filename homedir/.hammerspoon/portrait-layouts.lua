-------------------------------------------------------------------
-- Portrait Monitor Layouts Module
-- Handles portrait monitor detection and specialized layouts
-------------------------------------------------------------------

local hyper = { "cmd", "alt", "ctrl", "shift" }

-- Portrait-specific layout units (height > width monitors)
local portraitUnits = {
  top20         = { x = 0.00, y = 0.00, w = 1.00, h = 0.20 },  -- Spotify position
  top30         = { x = 0.00, y = 0.00, w = 1.00, h = 0.30 },
  middle40      = { x = 0.00, y = 0.30, w = 1.00, h = 0.40 },
  bottom50      = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
  bottom70      = { x = 0.00, y = 0.30, w = 1.00, h = 0.70 },
  thirds_top    = { x = 0.00, y = 0.00, w = 1.00, h = 0.33 },
  thirds_mid    = { x = 0.00, y = 0.33, w = 1.00, h = 0.34 },
  thirds_bot    = { x = 0.00, y = 0.67, w = 1.00, h = 0.33 },
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

-- Spotify portrait positioning
local function positionSpotifyOnPortrait()
  local portraitScreen = getPortraitScreen()
  if not portraitScreen then 
    hs.notify.new({title="No Portrait Monitor", informativeText="Portrait monitor not detected"}):send()
    return 
  end
  
  local spotify = hs.application.get('Spotify')
  if spotify then
    local windows = spotify:allWindows()
    for _, window in ipairs(windows) do
      window:move(portraitUnits.top20, portraitScreen, true)
    end
    hs.notify.new({title="Spotify", informativeText="Positioned on portrait monitor"}):send()
  else
    hs.notify.new({title="Spotify", informativeText="Spotify not running"}):send()
  end
end

-- Portrait layout definitions
local portraitLayouts = {
  productivity = {
    { app = 'Spotify',     unit = portraitUnits.top20 },
    { app = 'Linear',      unit = portraitUnits.thirds_mid },
    { app = 'Slack',       unit = portraitUnits.bottom50 },
  },
  monitoring = {
    { app = 'Activity Monitor', unit = portraitUnits.top30 },
    { app = 'Console',          unit = portraitUnits.bottom70 },
  },
  communication = {
    { app = 'Slack',       unit = portraitUnits.thirds_top },
    { app = 'Messages',    unit = portraitUnits.thirds_mid },
    { app = 'Discord',     unit = portraitUnits.thirds_bot },
  }
}

-- Portrait layout runner
local function runPortraitLayout(layoutName)
  local portraitScreen = getPortraitScreen()
  if not portraitScreen then 
    hs.notify.new({title="No Portrait Monitor", informativeText="Portrait layout requires portrait monitor"}):send()
    return 
  end
  
  local layout = portraitLayouts[layoutName]
  if not layout then
    hs.notify.new({title="Invalid Layout", informativeText="Layout '" .. layoutName .. "' not found"}):send()
    return
  end
  
  for _, item in ipairs(layout) do
    local app = hs.application.get(item.app)
    if app then
      local windows = app:allWindows()
      for _, window in ipairs(windows) do
        window:move(item.unit, portraitScreen, true)
      end
    end
  end
  
  hs.notify.new({title="Portrait Layout", informativeText="Applied '" .. layoutName .. "' layout"}):send()
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

-- Auto-position Spotify when launched
local appWatcher = hs.application.watcher.new(function(name, event, app)
  if name == "Spotify" and event == hs.application.watcher.launched then
    hs.timer.doAfter(1, positionSpotifyOnPortrait)
  end
end)
appWatcher:start()