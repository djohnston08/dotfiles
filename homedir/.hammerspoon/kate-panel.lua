-- Kate Ambient Panel — floating presence UI
-- Summoned with a hotkey, shows Kate's messages and accepts input.

local KatePanel = {}
KatePanel.__index = KatePanel

-- ---------------------------------------------------------------------------
-- HTML/CSS/JS embedded in the webview
-- ---------------------------------------------------------------------------

local PANEL_HTML = [[
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", sans-serif;
    font-size: 13px;
    background: #1e1e2e;
    color: #cdd6f4;
    height: 100vh;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    -webkit-user-select: none;
    user-select: none;
  }

  /* Title bar */
  .title-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 12px;
    background: #181825;
    border-bottom: 1px solid #313244;
    -webkit-app-region: drag;
    cursor: grab;
  }
  .title-bar span { font-weight: 600; color: #cba6f7; font-size: 14px; }
  .title-bar button {
    background: none; border: none; color: #6c7086; cursor: pointer;
    font-size: 16px; line-height: 1; padding: 2px 4px;
    -webkit-app-region: no-drag;
  }
  .title-bar button:hover { color: #f38ba8; }

  /* Proactive message area */
  .proactive {
    padding: 8px 12px;
    background: #1e1e2e;
    border-bottom: 1px solid #313244;
    border-left: 3px solid #cba6f7;
    margin: 0;
    font-size: 12px;
    color: #a6adc8;
    display: none;
    max-height: 60px;
    overflow-y: auto;
  }
  .proactive.visible { display: block; }
  .proactive .label {
    font-size: 10px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    color: #cba6f7;
    margin-bottom: 3px;
  }

  /* Response area */
  .response {
    flex: 1;
    padding: 12px;
    overflow-y: auto;
    line-height: 1.5;
    -webkit-user-select: text;
    user-select: text;
  }
  .response .thinking {
    color: #6c7086;
    font-style: italic;
  }
  .response .thinking::after {
    content: '';
    animation: dots 1.5s steps(4, end) infinite;
  }
  @keyframes dots {
    0% { content: ''; }
    25% { content: '.'; }
    50% { content: '..'; }
    75% { content: '...'; }
  }
  .response p { margin-bottom: 8px; }
  .response p:last-child { margin-bottom: 0; }

  /* Input area */
  .input-area {
    display: flex;
    padding: 8px;
    background: #181825;
    border-top: 1px solid #313244;
    gap: 6px;
  }
  .input-area input {
    flex: 1;
    background: #313244;
    border: 1px solid #45475a;
    border-radius: 6px;
    padding: 6px 10px;
    color: #cdd6f4;
    font-size: 13px;
    font-family: inherit;
    outline: none;
  }
  .input-area input:focus { border-color: #cba6f7; }
  .input-area input::placeholder { color: #585b70; }
  .input-area input:disabled { opacity: 0.5; }
  .input-area button {
    background: #cba6f7;
    border: none;
    border-radius: 6px;
    padding: 6px 10px;
    color: #1e1e2e;
    font-weight: 600;
    cursor: pointer;
    font-size: 13px;
  }
  .input-area button:hover { background: #b4befe; }
  .input-area button:disabled { opacity: 0.4; cursor: default; }
</style>
</head>
<body>
  <div class="title-bar">
    <span>Kate</span>
    <button onclick="sendAction('hide')" title="Close">&times;</button>
  </div>
  <div class="proactive" id="proactive">
    <div class="label">Kate said</div>
    <div id="proactive-text"></div>
  </div>
  <div class="response" id="response"></div>
  <div class="input-area">
    <input type="text" id="input" placeholder="Talk to Kate..."
           autocomplete="off" spellcheck="false">
    <button id="send-btn" onclick="submitMessage()">&#x2192;</button>
  </div>

<script>
  var input = document.getElementById('input');
  var responseEl = document.getElementById('response');
  var sendBtn = document.getElementById('send-btn');

  function sendAction(action, data) {
    var url = 'hammerspoon://kate?action=' + action;
    if (data) url += '&data=' + encodeURIComponent(data);
    window.location.href = url;
  }

  function submitMessage() {
    var text = input.value.trim();
    if (!text) return;
    sendAction('send', text);
    input.value = '';
    input.disabled = true;
    sendBtn.disabled = true;
  }

  input.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      submitMessage();
    }
    if (e.key === 'Escape') {
      sendAction('hide');
    }
  });

  // Called from Lua via evaluateJavaScript
  function setThinking(on) {
    if (on) {
      responseEl.innerHTML = '<p class="thinking">Thinking</p>';
    }
  }

  function setResponse(text) {
    input.disabled = false;
    sendBtn.disabled = false;
    // Convert newlines to paragraphs
    var paragraphs = text.split(/\n\n+/);
    var html = paragraphs.map(function(p) {
      return '<p>' + p.replace(/\n/g, '<br>') + '</p>';
    }).join('');
    responseEl.innerHTML = html;
    responseEl.scrollTop = responseEl.scrollHeight;
  }

  function setProactiveMessage(text) {
    var el = document.getElementById('proactive');
    var textEl = document.getElementById('proactive-text');
    if (text) {
      textEl.textContent = text;
      el.classList.add('visible');
    } else {
      el.classList.remove('visible');
    }
  }

  function focusInput() {
    input.disabled = false;
    sendBtn.disabled = false;
    input.focus();
  }

  function clearResponse() {
    responseEl.innerHTML = '';
  }
</script>
</body>
</html>
]]

-- ---------------------------------------------------------------------------
-- Panel constructor
-- ---------------------------------------------------------------------------

function KatePanel:new(config)
    local self = setmetatable({}, KatePanel)
    self.kate_url = config.kate_url or "http://studio:8080"
    self.visible = false
    self.webview = nil
    self.clickWatcher = nil
    self.lastProactive = nil

    -- Menu bar
    self.menubar = hs.menubar.new()
    self:_setupMenubar()

    -- Health poll
    self.connected = false
    self.healthTimer = hs.timer.doEvery(60, function()
        self:_checkHealth()
    end)
    -- Check immediately
    self:_checkHealth()

    return self
end

-- ---------------------------------------------------------------------------
-- Panel show / hide / toggle
-- ---------------------------------------------------------------------------

function KatePanel:toggle()
    if self.visible then
        self:hide()
    else
        self:show()
    end
end

function KatePanel:show()
    if self.visible and self.webview then
        self.webview:show()
        hs.timer.doAfter(0.1, function()
            if self.webview then
                self.webview:evaluateJavaScript("focusInput()")
            end
        end)
        return
    end

    -- Create webview centered on screen
    local screen = hs.screen.mainScreen():frame()
    local w, h = 420, 380
    local x = screen.x + (screen.w - w) / 2
    local y = screen.y + (screen.h - h) / 3  -- upper third

    local rect = hs.geometry.rect(x, y, w, h)

    self.webview = hs.webview.new(rect, {
        developerExtrasEnabled = false,
    })

    self.webview:windowStyle(
        hs.webview.windowMasks.borderless |
        hs.webview.windowMasks.utility |
        hs.webview.windowMasks.HUD
    )
    self.webview:level(hs.drawing.windowLevels.floating)
    self.webview:allowTextEntry(true)
    self.webview:shadow(true)
    self.webview:alpha(0.96)
    self.webview:behavior(hs.drawing.windowBehaviors.canJoinAllSpaces)

    -- Intercept navigation for JS->Lua communication
    self.webview:navigationCallback(function(_action, wv, navAction)
        local url = navAction
        if type(navAction) == "string" and navAction:find("^hammerspoon://") then
            local action = navAction:match("action=([^&]+)")
            local data = navAction:match("data=([^&]+)")
            if data then
                data = hs.http.urlParts(navAction).queryItems and
                    hs.http.urlParts(navAction).queryItems.data or
                    hs.http.convertHtmlEntities(data)
                -- URL decode
                data = data:gsub("%%(%x%x)", function(hex)
                    return string.char(tonumber(hex, 16))
                end)
            end

            if action == "hide" then
                self:hide()
            elseif action == "send" and data then
                self:sendMessage(data)
            end
            return true  -- cancel navigation
        end
        return true
    end)

    self.webview:html(PANEL_HTML)
    self.webview:show()
    self.visible = true

    -- Focus input after a short delay for rendering
    hs.timer.doAfter(0.15, function()
        if self.webview then
            self.webview:evaluateJavaScript("focusInput()")
            -- Restore last proactive message if any
            if self.lastProactive then
                local escaped = self.lastProactive:gsub("\\", "\\\\"):gsub("'", "\\'"):gsub("\n", "\\n")
                self.webview:evaluateJavaScript("setProactiveMessage('" .. escaped .. "')")
            end
        end
    end)

    -- Click-outside watcher
    self:_startClickWatcher()

    -- Clear unread indicator
    self:_updateMenubar(false)
end

function KatePanel:hide()
    if self.webview then
        self.webview:hide()
    end
    self.visible = false
    self:_stopClickWatcher()
end

function KatePanel:destroy()
    if self.webview then
        self.webview:delete()
        self.webview = nil
    end
    self:_stopClickWatcher()
    if self.healthTimer then
        self.healthTimer:stop()
    end
    if self.menubar then
        self.menubar:delete()
    end
end

-- ---------------------------------------------------------------------------
-- Messaging
-- ---------------------------------------------------------------------------

function KatePanel:sendMessage(text)
    if not self.webview then return end

    -- Show thinking state
    self.webview:evaluateJavaScript("setThinking(true)")

    local url = self.kate_url .. "/api/chat"
    local body = hs.json.encode({
        message = text,
        platform = "hammerspoon",
    })
    local headers = { ["Content-Type"] = "application/json" }

    hs.http.asyncPost(url, body, headers, function(status, responseBody, _headers)
        if not self.webview then return end

        if status < 0 or status >= 400 then
            self.webview:evaluateJavaScript(
                "setResponse('Sorry, I could not reach Kate. (status: " .. tostring(status) .. ")')"
            )
            return
        end

        -- Parse SSE response — extract the done event or last paragraph
        local finalText = self:_parseSSE(responseBody or "")
        if finalText == "" then
            finalText = "(No response)"
        end

        local escaped = finalText:gsub("\\", "\\\\"):gsub("'", "\\'"):gsub("\n", "\\n")
        self.webview:evaluateJavaScript("setResponse('" .. escaped .. "')")
    end)
end

function KatePanel:_parseSSE(body)
    -- SSE format: "event: <type>\ndata: <text>\n\n"
    -- Look for the "done" event first, fall back to last paragraph
    local doneText = nil
    local lastParagraph = nil

    for event, data in body:gmatch("event: (%w+)\ndata: ([^\n]+)") do
        if event == "done" then
            doneText = data
        elseif event == "paragraph" then
            lastParagraph = data
        end
    end

    -- Also handle multi-line data fields
    if not doneText then
        local inDone = false
        local lines = {}
        for line in body:gmatch("[^\n]+") do
            if line == "event: done" then
                inDone = true
                lines = {}
            elseif inDone and line:find("^data: ") then
                table.insert(lines, line:sub(7))
            elseif inDone and line == "" then
                doneText = table.concat(lines, "\n")
                break
            end
        end
    end

    return doneText or lastParagraph or ""
end

-- ---------------------------------------------------------------------------
-- Proactive messages (called from /notify handler)
-- ---------------------------------------------------------------------------

function KatePanel:setProactiveMessage(text)
    self.lastProactive = text

    -- Update panel if visible
    if self.visible and self.webview then
        local escaped = text:gsub("\\", "\\\\"):gsub("'", "\\'"):gsub("\n", "\\n")
        self.webview:evaluateJavaScript("setProactiveMessage('" .. escaped .. "')")
    end

    -- Show unread indicator in menubar
    if not self.visible then
        self:_updateMenubar(true)
    end

    -- Show notification with reply action
    local n = hs.notify.new(function(_notification)
        self:show()
    end, {
        title = "Kate",
        informativeText = text,
        actionButtonTitle = "Reply",
        hasActionButton = true,
        withdrawAfter = 10,
    })
    n:send()
end

-- ---------------------------------------------------------------------------
-- Click-outside dismiss
-- ---------------------------------------------------------------------------

function KatePanel:_startClickWatcher()
    self:_stopClickWatcher()
    self.clickWatcher = hs.eventtap.new(
        { hs.eventtap.event.types.leftMouseDown },
        function(event)
            if not self.visible or not self.webview then return false end
            local pos = event:location()
            local frame = self.webview:frame()
            if not frame then return false end
            if pos.x < frame.x or pos.x > frame.x + frame.w
                or pos.y < frame.y or pos.y > frame.y + frame.h then
                self:hide()
            end
            return false
        end
    )
    self.clickWatcher:start()
end

function KatePanel:_stopClickWatcher()
    if self.clickWatcher then
        self.clickWatcher:stop()
        self.clickWatcher = nil
    end
end

-- ---------------------------------------------------------------------------
-- Menu bar
-- ---------------------------------------------------------------------------

function KatePanel:_setupMenubar()
    if not self.menubar then return end
    self.menubar:setTitle("K")
    self:_updateMenubar(false)
end

function KatePanel:_updateMenubar(unread)
    if not self.menubar then return end

    local title
    if unread then
        -- Use styled text for unread indicator
        title = hs.styledtext.new("K", {
            font = { name = ".AppleSystemUIFont", size = 14 },
            color = { hex = "#cba6f7" },
        })
    else
        title = hs.styledtext.new("K", {
            font = { name = ".AppleSystemUIFont", size = 14 },
            color = self.connected and { hex = "#a6adc8" } or { hex = "#585b70" },
        })
    end
    self.menubar:setTitle(title)

    self.menubar:setMenu(function()
        local items = {}

        -- Last proactive message preview
        if self.lastProactive then
            local preview = self.lastProactive:sub(1, 80)
            if #self.lastProactive > 80 then preview = preview .. "..." end
            table.insert(items, { title = preview, disabled = true })
            table.insert(items, { title = "-" })
        end

        table.insert(items, {
            title = "Talk to Kate...",
            fn = function() self:show() end,
        })
        table.insert(items, { title = "-" })
        table.insert(items, {
            title = self.connected and "Connected" or "Disconnected",
            disabled = true,
        })

        return items
    end)
end

-- ---------------------------------------------------------------------------
-- Health check
-- ---------------------------------------------------------------------------

function KatePanel:_checkHealth()
    local url = self.kate_url .. "/api/health"
    hs.http.asyncGet(url, nil, function(status, _body, _headers)
        local wasConnected = self.connected
        self.connected = (status >= 200 and status < 400)
        if self.connected ~= wasConnected then
            self:_updateMenubar(self.lastProactive ~= nil and not self.visible)
        end
    end)
end

return KatePanel
