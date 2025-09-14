-------------------------------------------------------------------
-- Window Management Module
-- Handles window positioning, layouts, and screen management
-------------------------------------------------------------------

local M = {}

-- Monitor definitions
M.macbook_monitor = "Built-in Retina Display"
M.primary_monitor = "DELL U2415"

-- Standard layout units for landscape monitors
M.units = {
    right30      = { x = 0.70, y = 0.00, w = 0.30, h = 1.00 },
    right33      = { x = 0.67, y = 0.00, w = 0.33, h = 1.00 },
    right70      = { x = 0.30, y = 0.00, w = 0.70, h = 1.00 },
    left70       = { x = 0.00, y = 0.00, w = 0.70, h = 1.00 },
    left67       = { x = 0.00, y = 0.00, w = 0.67, h = 1.00 },
    left30       = { x = 0.00, y = 0.00, w = 0.30, h = 1.00 },
    top50        = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
    bot50        = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
    bot80        = { x = 0.00, y = 0.20, w = 1.00, h = 0.80 },
    bot87        = { x = 0.00, y = 0.20, w = 1.00, h = 0.87 },
    bot90        = { x = 0.00, y = 0.20, w = 1.00, h = 0.90 },
    upright30    = { x = 0.70, y = 0.00, w = 0.30, h = 0.50 },
    botright30   = { x = 0.70, y = 0.50, w = 0.30, h = 0.50 },
    upleft70     = { x = 0.00, y = 0.00, w = 0.70, h = 0.50 },
    botleft70    = { x = 0.00, y = 0.50, w = 0.70, h = 0.50 },
    right70top80 = { x = 0.70, y = 0.00, w = 0.30, h = 0.80 },
    maximum      = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },
    center       = { x = 0.20, y = 0.10, w = 0.60, h = 0.80 },
    centerSmall  = { x = 0.25, y = 0.20, w = 0.50, h = 0.60 },
    centerBig    = { x = 0.05, y = 0.05, w = 0.90, h = 0.90 }
}

-- Window management hotkeys (Voyager Layer: mash + vim keys)
local mash = { 'shift', 'ctrl', 'alt' }
hs.hotkey.bind(mash, 'k', function() hs.window.focusedWindow():move(M.units.top50, nil, true) end)
hs.hotkey.bind(mash, 'j', function() hs.window.focusedWindow():move(M.units.bot50, nil, true) end)
hs.hotkey.bind(mash, 'm', function() hs.window.focusedWindow():move(M.units.maximum, nil, true) end)
hs.hotkey.bind(mash, 'i', function() hs.window.focusedWindow():move(M.units.centerSmall, nil, true) end)
hs.hotkey.bind(mash, 'o', function() hs.window.focusedWindow():move(M.units.center, nil, true) end)
hs.hotkey.bind(mash, 'p', function() hs.window.focusedWindow():move(M.units.centerBig, nil, true) end)

-- Hyper key window controls (Voyager Layer: hyper + hjkl)
local hyper = { "cmd", "alt", "ctrl", "shift" }
hs.hotkey.bind(hyper, "h", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    win:moveToUnit(hs.layout.left50)
end)
hs.hotkey.bind(hyper, "j", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    win:moveToUnit(hs.layout.maximized)
end)
hs.hotkey.bind(hyper, "k", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    win:moveToScreen(win:screen():next())
end)
hs.hotkey.bind(hyper, "l", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    win:moveToUnit(hs.layout.right50)
end)
hs.hotkey.bind(hyper, "1", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    win:move(M.units.centerBig, nil, true)
end)

-- Bind hyper+7 to move window to left 67% on current screen
hs.hotkey.bind(hyper, "7", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    win:moveToUnit(M.units.left67)
end)

-- Bind hyper+8 to move window to right 33% on current screen
hs.hotkey.bind(hyper, "8", function()
    local win = hs.window.focusedWindow()
    if not win then return end
    win:moveToUnit(M.units.right33)
end)

return M

