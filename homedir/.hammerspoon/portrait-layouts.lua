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
  if not spotify then
    -- Launch Spotify if not running
    hs.application.launchOrFocus('Spotify')
    showAlertOnScreen("Launching Spotify...", portraitScreen, 1.5)
    -- Wait for it to launch then position it
    hs.timer.doAfter(2, function()
      local spotify = hs.application.get('Spotify')
      if spotify then
        local windows = spotify:allWindows()
        for _, window in ipairs(windows) do
          window:move(portraitUnits.top20, portraitScreen, true)
        end
      end
    end)
  else
    local windows = spotify:allWindows()
    for _, window in ipairs(windows) do
      window:move(portraitUnits.top20, portraitScreen, true)
    end
    showAlertOnScreen("Spotify positioned", portraitScreen, 1.5)
  end
end

-- Portrait layout definitions
local portraitLayouts = {
  monitoring = {
    { app = 'OpenLens',     unit = portraitUnits.thirds_top },    -- Top third
    { app = 'DataGrip',     unit = portraitUnits.thirds_mid },    -- Middle third  
    { app = 'Docker Desktop', unit = portraitUnits.thirds_bot },  -- Bottom third
  },
  communication = {
    { app = 'Discord',     unit = portraitUnits.thirds_top },    -- Top third (least used)
    { app = 'Slack',       unit = portraitUnits.thirds_mid },    -- Middle third (most used)
    { app = 'Messages',    unit = portraitUnits.thirds_bot },    -- Bottom third (second most)
  },
  meeting = {
    { app = 'Fantastical', unit = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 } }, -- Top half
    { app = 'Slack',       unit = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 } }, -- Bottom half
    -- Other monitors handled in special logic
  },
  coding = {
    -- Portrait monitor apps (exact positions from captured layout)
    { app = 'Spotify',          unit = { x = 0.00, y = 0.00, w = 1.00, h = 0.234 } },  -- Top 23.4% (600px of 2560px)
    { app = 'Linear',           unit = { x = 0.00, y = 0.234, w = 1.00, h = 0.259 } }, -- 25.9% height (662px of 2560px)
    { app = 'Slack',            unit = { x = 0.00, y = 0.493, w = 1.00, h = 0.507 } }, -- Bottom 50.7% (1267px of ~2500px)
    -- Other monitors handled in special logic
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

-- Get all landscape monitors sorted by position (left to right)
local function getLandscapeMonitorsByPosition()
  local screens = hs.screen.allScreens()
  local landscapeScreens = {}
  
  -- Collect all landscape screens
  for _, screen in ipairs(screens) do
    local mode = screen:currentMode()
    if mode.w > mode.h then
      table.insert(landscapeScreens, screen)
    end
  end
  
  -- Sort by x position (left to right)
  table.sort(landscapeScreens, function(a, b)
    return a:frame().x < b:frame().x
  end)
  
  return landscapeScreens
end

-- Get specific landscape monitor by position
local function getLeftMonitor()
  local monitors = getLandscapeMonitorsByPosition()
  return monitors[1] -- First is leftmost
end

local function getMiddleMonitor()
  local monitors = getLandscapeMonitorsByPosition()
  -- If we have 2 landscape monitors, return the second (right) one as "middle"
  -- If we have 3+, return the actual middle one
  if #monitors == 2 then
    return monitors[2]
  elseif #monitors >= 3 then
    return monitors[2]
  end
  return monitors[1] -- Fallback to first if only one
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
  
  -- Special handling for meeting layout
  if layoutName == "meeting" then
    local leftMonitor = getLeftMonitor()
    local middleMonitor = getMiddleMonitor()
    
    -- Launch apps if not running
    local appsToLaunch = {'Google Chrome', 'Granola', 'iTerm', 'Fantastical', 'Slack'}
    for _, appName in ipairs(appsToLaunch) do
      if not hs.application.get(appName) then
        hs.application.launchOrFocus(appName)
      end
    end
    
    -- Wait for apps to launch
    hs.timer.doAfter(1.5, function()
      -- Middle monitor: Chrome centered at 70%
      if middleMonitor then
        local chrome = hs.application.get('Google Chrome')
        if chrome then
          chrome:activate()
          local windows = chrome:allWindows()
          if #windows > 0 then
            -- Centered 70% width and height
            windows[1]:move({x=0.15, y=0.15, w=0.7, h=0.7}, middleMonitor, true)
          end
        end
      end
      
      -- Left monitor layout
      if leftMonitor then
        -- Granola: left 30%
        local granola = hs.application.get('Granola')
        if granola then
          granola:activate()
          local windows = granola:allWindows()
          for _, window in ipairs(windows) do
            window:move({x=0, y=0, w=0.3, h=1}, leftMonitor, true)
          end
        end
        
        -- iTerm: remaining right 70%
        hs.timer.doAfter(0.3, function()
          local iterm = hs.application.get('iTerm')
          if iterm then
            iterm:activate()
            local windows = iterm:allWindows()
            for _, window in ipairs(windows) do
              window:move({x=0.3, y=0, w=0.7, h=1}, leftMonitor, true)
            end
          end
        end)
      end
    end)
  -- Special handling for coding layout
  elseif layoutName == "coding" then
    local leftMonitor = getLeftMonitor()
    local middleMonitor = getMiddleMonitor()
    
    -- Launch apps if not running
    local appsToLaunch = {'iTerm', 'Google Chrome', 'DataGrip', 'Spotify', 'Linear', 'Slack'}
    for _, appName in ipairs(appsToLaunch) do
      if not hs.application.get(appName) then
        hs.application.launchOrFocus(appName)
      end
    end
    
    -- Wait a bit for apps to launch
    hs.timer.doAfter(1.5, function()
      -- Left monitor layout
      if leftMonitor then
        -- Chrome: 90% width, 88% height, slightly offset from edges
        local chrome = hs.application.get('Google Chrome')
        if chrome then
          local windows = chrome:allWindows()
          if #windows > 0 then
            windows[1]:move({x=0.05, y=0.066, w=0.9, h=0.88}, leftMonitor, true)
          end
        end
        
        -- DataGrip: bottom 60% of screen, full width
        hs.timer.doAfter(0.5, function()
          local datagrip = hs.application.get('DataGrip')
          if datagrip then
            local windows = datagrip:allWindows()
            for _, window in ipairs(windows) do
              window:move({x=0, y=0.4, w=1, h=0.6}, leftMonitor, true)
            end
            -- Focus Chrome after DataGrip to ensure it's on top
            hs.timer.doAfter(0.5, function()
              if chrome then
                chrome:activate()
              end
            end)
          end
        end)
      end
      
      -- Middle monitor: iTerm full screen (do this after DataGrip)
      hs.timer.doAfter(1.5, function()
        if middleMonitor then
          local iterm = hs.application.get('iTerm')
          if iterm then
            local windows = iterm:allWindows()
            for _, window in ipairs(windows) do
              window:move({x=0, y=0, w=1, h=1}, middleMonitor, true)
            end
            -- Focus iTerm last
            hs.timer.doAfter(1, function()
              iterm:activate()
            end)
          end
        end
      end)
    end)
  end
  
  -- Launch apps if not running (for non-coding and non-meeting layouts)
  if layoutName ~= "coding" and layoutName ~= "meeting" then
    for _, item in ipairs(layout) do
      if not hs.application.get(item.app) then
        hs.application.launchOrFocus(item.app)
      end
    end
  end
  
  -- Apply layout with slight delays to ensure proper positioning
  local applyLayoutFn = function()
    for i, item in ipairs(layout) do
      local app = hs.application.get(item.app)
      if app then
        -- Add delay between apps, with extra time for activation
        hs.timer.doAfter(0.5 * (i-1), function()
          local windows = app:allWindows()
          for _, window in ipairs(windows) do
            local unit = item.unit
            -- Handle offset_y if specified
            if item.offset_y then
              unit = {x = unit.x, y = item.offset_y, w = unit.w, h = unit.h}
            end
            window:move(unit, portraitScreen, true)
          end
          -- Activate after positioning to ensure proper layering
          app:activate()
        end)
      end
    end
  end
  
  -- Apply layouts with appropriate timing
  if layoutName == "coding" then
    -- Coding layout applies portrait apps after other monitors are done
    hs.timer.doAfter(2, applyLayoutFn)
  elseif layoutName == "meeting" then
    -- Meeting layout applies portrait apps after other monitors are done
    hs.timer.doAfter(2, applyLayoutFn)  
  else
    -- Other layouts (communication, monitoring) wait for apps to launch
    hs.timer.doAfter(1.5, applyLayoutFn)
  end
  
  showAlertOnScreen(layoutName:gsub("^%l", string.upper) .. " layout applied", portraitScreen, 1.5)
end

-- Portrait hotkeys (Voyager Layer: hyper + numbers)
hs.hotkey.bind(hyper, "9", function()
  positionSpotifyOnPortrait()  -- Quick Spotify positioning
end)

hs.hotkey.bind(hyper, "6", function() 
  runPortraitLayout("meeting")       -- Meeting layout
end)

hs.hotkey.bind(hyper, "5", function() 
  runPortraitLayout("monitoring")    -- Monitoring layout  
end)

hs.hotkey.bind(hyper, "4", function() 
  runPortraitLayout("communication") -- Communication layout
end)

hs.hotkey.bind(hyper, "3", function() 
  runPortraitLayout("coding")        -- Coding layout
end)


-- Auto-position Spotify when launched
local appWatcher = hs.application.watcher.new(function(name, event, app)
  if name == "Spotify" and event == hs.application.watcher.launched then
    hs.timer.doAfter(1, positionSpotifyOnPortrait)
  end
end)
appWatcher:start()