-- Kate Hammerspoon Bridge
-- Desktop state reporting + outbound tools for Kate AI
-- Install: require("kate") from ~/.hammerspoon/init.lua

local KATE_URL = os.getenv("KATE_URL") or "https://studio.hedgehog-chuckwalla.ts.net"
local INGEST_ENDPOINT = KATE_URL .. "/api/events/ingest"
local IDLE_THRESHOLD = 300 -- 5 minutes
local MACHINE_NAME = hs.host.localizedName()
local SERVER_PORT = 8420

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

-- ---------------------------------------------------------------------------
-- HTTP server (commands from Kate)
-- ---------------------------------------------------------------------------

local server = hs.httpserver.new(false, false)

server:setCallback(function(method, path, _headers, body)
    -- GET /health
    if method == "GET" and path == "/health" then
        return hs.json.encode({ status = "ok", machine = MACHINE_NAME }),
               200,
               { ["Content-Type"] = "application/json" }
    end

    -- GET /state
    if method == "GET" and path == "/state" then
        local idleSeconds = hs.host.idleTime()
        local frontmost = "unknown"
        local app = hs.application.frontmostApplication()
        if app then
            frontmost = app:name() or "unknown"
        end
        return hs.json.encode({
            idle = idleSeconds >= IDLE_THRESHOLD,
            idle_seconds = math.floor(idleSeconds),
            frontmost_app = frontmost,
        }), 200, { ["Content-Type"] = "application/json" }
    end

    -- POST /notify
    if method == "POST" and path == "/notify" then
        local ok, data = pcall(hs.json.decode, body)
        if not ok or type(data) ~= "table" then
            return hs.json.encode({ error = "invalid JSON" }),
                   400,
                   { ["Content-Type"] = "application/json" }
        end
        local message = data.message or ""
        -- Route through the panel (handles notification + menubar unread)
        if katePanel then
            katePanel:setProactiveMessage(message)
        else
            hs.notify.new({ title = "Kate", informativeText = message }):send()
        end
        return hs.json.encode({ status = "ok" }),
               200,
               { ["Content-Type"] = "application/json" }
    end

    -- POST /speak — TTS via macOS say command
    if method == "POST" and path == "/speak" then
        local pok, data = pcall(hs.json.decode, body)
        if not pok or type(data) ~= "table" or not data.text then
            return hs.json.encode({ ok = false, error = "invalid JSON or missing text" }),
                   400, { ["Content-Type"] = "application/json" }
        end
        local sok, serr = pcall(function()
            -- Write text to a temp file to avoid shell escaping issues
            local tmpfile = os.tmpname()
            local f = io.open(tmpfile, "w")
            if f then
                f:write(tostring(data.text))
                f:close()
            end
            local args = ""
            if data.voice then
                local voice = tostring(data.voice)
                voice = voice:gsub("'", "'\\''")
                args = args .. " -v '" .. voice .. "'"
            end
            if data.rate then
                args = args .. " -r " .. tostring(math.floor(tonumber(data.rate) or 200))
            end
            hs.execute("say" .. args .. " -f " .. tmpfile)
            os.remove(tmpfile)
        end)
        if sok then
            return hs.json.encode({ ok = true }),
                   200, { ["Content-Type"] = "application/json" }
        else
            return hs.json.encode({ ok = false, error = tostring(serr) }),
                   500, { ["Content-Type"] = "application/json" }
        end
    end

    -- GET /windows — list all visible windows
    if method == "GET" and path == "/windows" then
        local ok2, result = pcall(function()
            local wins = hs.window.allWindows()
            local out = {}
            for _, w in ipairs(wins) do
                local wid = w:id()
                if wid then
                    local app = w:application()
                    local frame = w:frame()
                    table.insert(out, {
                        id = wid,
                        title = w:title() or "",
                        app = app and app:name() or "unknown",
                        x = math.floor(frame.x),
                        y = math.floor(frame.y),
                        w = math.floor(frame.w),
                        h = math.floor(frame.h),
                    })
                end
            end
            return out
        end)
        if ok2 then
            return hs.json.encode({ ok = true, data = result }),
                   200, { ["Content-Type"] = "application/json" }
        else
            return hs.json.encode({ ok = false, error = tostring(result) }),
                   500, { ["Content-Type"] = "application/json" }
        end
    end

    -- POST /windows/focus — focus a window by ID
    if method == "POST" and path == "/windows/focus" then
        local ok, data = pcall(hs.json.decode, body)
        if not ok or type(data) ~= "table" or not data.window_id then
            return hs.json.encode({ ok = false, error = "missing window_id" }),
                   400, { ["Content-Type"] = "application/json" }
        end
        local w = hs.window.get(data.window_id)
        if not w then
            return hs.json.encode({ ok = false, error = "window not found" }),
                   404, { ["Content-Type"] = "application/json" }
        end
        w:focus()
        return hs.json.encode({ ok = true }),
               200, { ["Content-Type"] = "application/json" }
    end

    -- POST /windows/move — move/resize a window by ID
    if method == "POST" and path == "/windows/move" then
        local ok, data = pcall(hs.json.decode, body)
        if not ok or type(data) ~= "table" or not data.window_id then
            return hs.json.encode({ ok = false, error = "missing window_id" }),
                   400, { ["Content-Type"] = "application/json" }
        end
        local w = hs.window.get(data.window_id)
        if not w then
            return hs.json.encode({ ok = false, error = "window not found" }),
                   404, { ["Content-Type"] = "application/json" }
        end
        local frame = w:frame()
        frame.x = data.x or frame.x
        frame.y = data.y or frame.y
        frame.w = data.w or frame.w
        frame.h = data.h or frame.h
        w:setFrame(frame)
        return hs.json.encode({ ok = true }),
               200, { ["Content-Type"] = "application/json" }
    end

    -- POST /screenshot — capture screen, save to disk, return path
    if (method == "GET" or method == "POST") and path == "/screenshot" then
        local sok, serr = pcall(function()
            local path = "/tmp/kate_screenshot.jpg"
            hs.execute("screencapture -x -t jpg " .. path)
            hs.execute("sips --resampleWidth 1280 -s formatOptions 50 "
                .. path .. " 2>/dev/null")
        end)
        if sok then
            return hs.json.encode({ ok = true, data = { path = "/tmp/kate_screenshot.jpg" } }),
                   200, { ["Content-Type"] = "application/json" }
        else
            return hs.json.encode({ ok = false, error = tostring(serr) }),
                   500, { ["Content-Type"] = "application/json" }
        end
    end

    -- POST /find — Spotlight search via mdfind
    if method == "POST" and path == "/find" then
        local pok, data = pcall(hs.json.decode, body)
        if not pok or type(data) ~= "table" or not data.query then
            return hs.json.encode({ ok = false, error = "missing query" }),
                   400, { ["Content-Type"] = "application/json" }
        end
        local fok, fresult = pcall(function()
            local limit = math.min(tonumber(data.limit) or 20, 50)
            local query = tostring(data.query)
            query = query:gsub("'", "'\\''")
            local cmd = "mdfind '" .. query .. "' 2>/dev/null | head -" .. tostring(limit)
            local output = hs.execute(cmd)
            local files = {}
            for line in (output or ""):gmatch("[^\n]+") do
                table.insert(files, line)
            end
            return files
        end)
        if fok then
            return hs.json.encode({ ok = true, data = { files = fresult } }),
                   200, { ["Content-Type"] = "application/json" }
        else
            return hs.json.encode({ ok = false, error = tostring(fresult) }),
                   500, { ["Content-Type"] = "application/json" }
        end
    end

    -- GET /apps — list running applications
    if method == "GET" and path == "/apps" then
        local apps = hs.application.runningApplications()
        local result = {}
        for _, app in ipairs(apps) do
            local name = app:name()
            if name and name ~= "" and app:kind() == 1 then
                table.insert(result, name)
            end
        end
        table.sort(result)
        local frontmost = "unknown"
        local front = hs.application.frontmostApplication()
        if front then
            frontmost = front:name() or "unknown"
        end
        return hs.json.encode({ ok = true, data = { apps = result, frontmost = frontmost } }),
               200, { ["Content-Type"] = "application/json" }
    end

    -- POST /apps/launch — launch or focus an application
    if method == "POST" and path == "/apps/launch" then
        local ok, data = pcall(hs.json.decode, body)
        if not ok or type(data) ~= "table" or not data.name then
            return hs.json.encode({ ok = false, error = "missing name" }),
                   400, { ["Content-Type"] = "application/json" }
        end
        local launched = hs.application.launchOrFocus(data.name)
        return hs.json.encode({ ok = launched }),
               200, { ["Content-Type"] = "application/json" }
    end

    -- GET /clipboard — read clipboard text
    if method == "GET" and path == "/clipboard" then
        local text = hs.pasteboard.getContents() or ""
        return hs.json.encode({ ok = true, data = { text = text } }),
               200, { ["Content-Type"] = "application/json" }
    end

    -- POST /photo — capture webcam photo, save to disk, return path
    if (method == "GET" or method == "POST") and path == "/photo" then
        local pok, perr = pcall(function()
            hs.execute("/opt/homebrew/bin/imagesnap -w 1 /tmp/kate_photo.jpg")
        end)
        if pok then
            return hs.json.encode({ ok = true, data = { path = "/tmp/kate_photo.jpg" } }),
                   200, { ["Content-Type"] = "application/json" }
        else
            return hs.json.encode({ ok = false, error = tostring(perr) }),
                   500, { ["Content-Type"] = "application/json" }
        end
    end

    -- Fallback
    return hs.json.encode({ error = "not found" }),
           404,
           { ["Content-Type"] = "application/json" }
end)

server:setPort(SERVER_PORT)
server:start()

print("[kate] Hammerspoon bridge started on port " .. tostring(SERVER_PORT))
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
