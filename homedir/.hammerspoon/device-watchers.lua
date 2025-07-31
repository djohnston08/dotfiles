-------------------------------------------------------------------
-- Device Watchers Module
-- Handles USB device detection and profile switching
-------------------------------------------------------------------

-- USB device callback for Karabiner profile switching
local function usbDeviceCallback(data)
  if (data["productName"] == "Razer BlackWidow Ultimate 2016") then
      if (data["eventType"] == "added") then
        hs.execute("/Library/Application\\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --select-profile win", true)
      elseif (data["eventType"] == "removed") then
        hs.execute("/Library/Application\\ Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli --select-profile mac", true)
      end
  end
end

local usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbWatcher:start()