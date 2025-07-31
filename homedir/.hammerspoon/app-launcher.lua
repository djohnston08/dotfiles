-------------------------------------------------------------------
-- Application Launcher Module
-- Handles application hotkeys and launching
-------------------------------------------------------------------

local hyper = { "cmd", "alt", "ctrl", "shift" }

-- Application hotkey mappings (Voyager Layer: hyper + letters)
local applicationHotkeys = {
  -- Communication
  s = 'Slack',        -- Voyager Layer: hyper+S
  i = 'Messages',     -- Voyager Layer: hyper+I  
  q = 'Discord',      -- Voyager Layer: hyper+Q
  e = 'Superhuman',   -- Voyager Layer: hyper+E
  
  -- Development Tools
  p = 'PhpStorm',     -- Voyager Layer: hyper+P
  v = 'Visual Studio Code', -- Voyager Layer: hyper+V
  t = 'iTerm',        -- Voyager Layer: hyper+T
  [';'] = 'Linear',   -- Voyager Layer: hyper+; (Fixed from 'o')
  g = 'OpenLens',     -- Voyager Layer: hyper+G
  r = 'Postman',      -- Voyager Layer: hyper+R
  m = 'DataGrip',     -- Voyager Layer: hyper+M
  
  -- Productivity & Browser
  c = 'Google Chrome', -- Voyager Layer: hyper+C
  n = 'Obsidian',     -- Voyager Layer: hyper+N
  w = 'Claude',       -- Voyager Layer: hyper+W
  f = 'Fantastical',  -- Voyager Layer: hyper+F
  d = 'Reminders',    -- Voyager Layer: hyper+D
  x = 'Microsoft Excel', -- Voyager Layer: hyper+X
  b = 'Miro',         -- Voyager Layer: hyper+B
  a = 'ChatGPT',      -- Voyager Layer: hyper+A
  
  -- Media & Utilities
  y = 'Spotify',      -- Voyager Layer: hyper+Y
  u = 'Granola',      -- Voyager Layer: hyper+U
  z = 'Keymapp',      -- Voyager Layer: hyper+Z
  
  -- Available for future use: 'o' (freed from Linear)
}

-- Bind all application hotkeys
for key, app in pairs(applicationHotkeys) do
  hs.hotkey.bind(hyper, key, function()
    hs.application.launchOrFocus(app)
  end)
end