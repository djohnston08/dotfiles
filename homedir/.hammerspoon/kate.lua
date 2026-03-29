-- Kate Hammerspoon Bridge
-- Desktop state reporting + ambient panel for Kate AI
-- Install: require("kate") from ~/.hammerspoon/init.lua
-- Requires: require("hs.ipc") in init.lua (for kate-agent hs CLI bridge)

local KATE_URL = os.getenv("KATE_URL") or "https://studio.hedgehog-chuckwalla.ts.net"
local INGEST_ENDPOINT = KATE_URL .. "/api/events/ingest"
local IDLE_THRESHOLD = 300 -- 5 minutes
local MACHINE_NAME = hs.host.localizedName()

-- ---------------------------------------------------------------------------
-- State tracking (dedup — only send on change)
-- ---------------------------------------------------------------------------

local lastSent = {}

local function stateChanged(eventType, payload)
    local key = eventType
    local encoded = hs.json.encode(payload)
    if lastSent[key] == encoded then
        return false
    end
    lastSent[key] = encoded
    return true
end

-- ---------------------------------------------------------------------------
-- HTTP helpers
-- ---------------------------------------------------------------------------

local function postEvent(eventType, payload)
    if not stateChanged(eventType, payload) then
        return
    end
    local body = hs.json.encode({
        event_type = eventType,
        source = MACHINE_NAME,
        payload = payload,
    })
    local headers = { ["Content-Type"] = "application/json" }
    hs.http.asyncPost(INGEST_ENDPOINT, body, headers, function(status, _body, _headers)
        if status < 0 or status >= 400 then
            print("[kate] POST " .. eventType .. " failed: status " .. tostring(status))
        end
    end)
end

-- ---------------------------------------------------------------------------
-- Power watcher (sleep / wake / lock / unlock)
-- ---------------------------------------------------------------------------

local powerWatcher = hs.caffeinate.watcher.new(function(event)
    local mapping = {
        [hs.caffeinate.watcher.systemDidWake]   = "wake",
        [hs.caffeinate.watcher.systemWillSleep]  = "sleep",
        [hs.caffeinate.watcher.screensDidLock]    = "lock",
        [hs.caffeinate.watcher.screensDidUnlock]  = "unlock",
    }
    local state = mapping[event]
    if state then
        postEvent("desktop.power_state", { state = state })
    end
end)
powerWatcher:start()

-- ---------------------------------------------------------------------------
-- App watcher (frontmost app changed)
-- ---------------------------------------------------------------------------

local appWatcher = hs.application.watcher.new(function(appName, eventType, _app)
    if eventType == hs.application.watcher.activated then
        postEvent("desktop.app_changed", { app = appName or "unknown" })
    end
end)
appWatcher:start()

-- ---------------------------------------------------------------------------
-- WiFi watcher (SSID changed)
-- ---------------------------------------------------------------------------

local wifiWatcher = hs.wifi.watcher.new(function()
    local ssid = hs.wifi.currentNetwork() or ""
    postEvent("desktop.wifi_changed", { ssid = ssid })
end)
wifiWatcher:start()

-- ---------------------------------------------------------------------------
-- Idle detection (transition-based, 30s poll)
-- ---------------------------------------------------------------------------

local wasIdle = false

hs.timer.doEvery(30, function()
    local idleSeconds = hs.host.idleTime()
    local isIdle = idleSeconds >= IDLE_THRESHOLD
    if isIdle ~= wasIdle then
        wasIdle = isIdle
        postEvent("desktop.idle_state", {
            idle = isIdle,
            idle_seconds = math.floor(idleSeconds),
        })
    end
end)

-- HTTP server removed — kate-agent handles all inbound HTTP now and
-- proxies to Hammerspoon via the hs CLI (requires hs.ipc in init.lua).
-- This eliminates the unreliable hs.httpserver.

print("[kate] Hammerspoon bridge active (event push only, no HTTP server)")
print("[kate] Reporting to " .. INGEST_ENDPOINT)
print("[kate] Machine name: " .. MACHINE_NAME)

-- ---------------------------------------------------------------------------
-- Kate ambient panel (Cmd+Shift+K)
-- ---------------------------------------------------------------------------

local KatePanel = dofile(hs.configdir .. "/kate-panel.lua")
katePanel = KatePanel:new({ kate_url = KATE_URL })

hs.hotkey.bind({"cmd", "shift"}, "K", function()
    katePanel:toggle()
end)

print("[kate] Ambient panel ready (Cmd+Shift+K)")
