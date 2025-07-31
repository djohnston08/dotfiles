-------------------------------------------------------------------
-- Spotify Controls Module  
-- Handles Spotify playback and volume controls
-------------------------------------------------------------------

local hyper = { "cmd", "alt", "ctrl", "shift" }

-- Load GlobalMute spoon
hs.loadSpoon("GlobalMute")

-- Spotify control hotkeys (Voyager Layer: hyper + media keys)
hs.hotkey.bind(hyper, "\\", function ()
  hs.spotify.displayCurrentTrack()
end)

hs.hotkey.bind(hyper, "pageup", function ()
  hs.spotify.volumeUp()
end)

hs.hotkey.bind(hyper, "pagedown", function ()
  hs.spotify.volumeDown()
end)