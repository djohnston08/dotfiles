-------------------------------------------------------------------
-- Hammerspoon Main Configuration
-- Modular setup with Voyager keyboard integration
-------------------------------------------------------------------

hs.window.animationDuration = 0
local hyper = { "cmd", "alt", "ctrl", "shift" }

-- Load all modules
require("window-management")
require("app-launcher") 
require("portrait-layouts")
require("deep-work")
require("spotify-controls")
require("device-watchers")

-- Global reload hotkey
hs.hotkey.bind(hyper, "0", function()
  hs.reload()
end)

-- Startup notification
hs.notify.new({
  title="Hammerspoon", 
  informativeText="Modular config loaded with portrait monitor support"
}):send()