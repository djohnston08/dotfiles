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
  .response .user-msg {
    text-align: right;
    color: #bac2de;
    padding: 6px 10px;
    margin-bottom: 8px;
    background: #313244;
    border-radius: 10px;
    display: inline-block;
    float: right;
    clear: both;
    max-width: 85%;
    font-size: 12px;
  }
  .response .kate-msg {
    clear: both;
    padding: 6px 0;
    margin-bottom: 4px;
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
    try {
      webkit.messageHandlers.kate.postMessage({ action: action, data: data || '' });
    } catch(e) {
      console.log('sendAction failed: ' + e);
    }
  }

  var lastUserMessage = '';

  function submitMessage() {
    var text = input.value.trim();
    if (!text) return;
    lastUserMessage = text;
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
      // Show user message + thinking indicator
      var userHtml = '<div class="user-msg">' + lastUserMessage + '</div>';
      responseEl.innerHTML += userHtml + '<p class="thinking">Thinking</p>';
      responseEl.scrollTop = responseEl.scrollHeight;
    }
  }

  function setResponse(text) {
    input.disabled = false;
    sendBtn.disabled = false;
    // Remove thinking indicator, keep history
    var thinking = responseEl.querySelector('.thinking');
    if (thinking) thinking.remove();
    // Convert newlines to paragraphs
    var paragraphs = text.split(/\n\n+/);
    var html = '<div class="kate-msg">' + paragraphs.map(function(p) {
      return '<p>' + p.replace(/\n/g, '<br>') + '</p>';
    }).join('') + '</div>';
    responseEl.innerHTML += html;
    responseEl.scrollTop = responseEl.scrollHeight;
  }

  function setProactiveMessage(text) {
    if (!text) return;
    // Insert into conversation history as a Kate message
    var paragraphs = text.split(/\n\n+/);
    var html = '<div class="kate-msg">' + paragraphs.map(function(p) {
      return '<p>' + p.replace(/\n/g, '<br>') + '</p>';
    }).join('') + '</div>';
    responseEl.innerHTML += html;
    responseEl.scrollTop = responseEl.scrollHeight;
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
    self.kate_url = config.kate_url or "https://studio.hedgehog-chuckwalla.ts.net"
    self.agent_url = config.agent_url or "http://127.0.0.1:7770"
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
        self.webview:show():bringToFront()
        hs.timer.doAfter(0.1, function()
            if self.webview then
                self.webview:hswindow():focus()
                self.webview:evaluateJavaScript("focusInput()")
            end
        end)
        return
    end

    -- Create webview centered on screen
    local screen = hs.screen.mainScreen():frame()
    local w, h = 500, 550
    local x = screen.x + (screen.w - w) / 2
    local y = screen.y + (screen.h - h) / 3  -- upper third

    local rect = hs.geometry.rect(x, y, w, h)

    -- Set up JS→Lua message channel via usercontent
    local uc = hs.webview.usercontent.new("kate")
    uc:setCallback(function(msg)
        local body = msg.body
        if type(body) ~= "table" then return end
        local action = body.action
        local data = body.data

        if action == "hide" then
            self:hide()
        elseif action == "send" and data and data ~= "" then
            self:sendMessage(data)
        end
    end)

    self.webview = hs.webview.new(rect, { developerExtrasEnabled = false }, uc)

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

    self.webview:html(PANEL_HTML)
    self.webview:show()
    self.visible = true

    -- Focus input after a short delay for rendering
    hs.timer.doAfter(0.15, function()
        if self.webview then
            self.webview:hswindow():focus()
            self.webview:evaluateJavaScript("focusInput()")
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

    local url = self.agent_url .. "/chat"
    local body = hs.json.encode({
        message = text,
        platform = "hammerspoon",
    })

    -- Use curl via hs.task for proper timeout control (120s).
    -- hs.http.asyncPost has a short default timeout that Kate's
    -- 30-50 second LLM responses exceed.
    local task = hs.task.new(
        "/usr/bin/curl",
        function(_exitCode, stdOut, _stdErr)
            local responseBody = stdOut or ""
            print("[kate] Chat response: exitCode=" .. tostring(_exitCode)
                .. " bodyLen=" .. #responseBody)

            local finalText = self:_parseSSE(responseBody)
            if finalText == "" then
                if _exitCode ~= 0 then
                    finalText = "Sorry, I could not reach Kate."
                else
                    finalText = "(No response)"
                end
            end

            -- If panel is still visible, show in webview
            if self.visible and self.webview then
                local escaped = finalText:gsub("\\", "\\\\"):gsub("'", "\\'"):gsub("\n", "\\n")
                self.webview:evaluateJavaScript("setResponse('" .. escaped .. "')")
            else
                -- Panel was closed while thinking — deliver as notification
                self:setProactiveMessage(finalText)
            end
        end,
        {
            "-s",
            "--max-time", "120",
            "-X", "POST",
            "-H", "Content-Type: application/json",
            "-d", body,
            url,
        }
    )
    task:start()
end

function KatePanel:_parseSSE(body)
    -- Parse SSE events, handling multi-line data fields.
    -- Prefer the "done" event (full response), fall back to
    -- concatenating all paragraph events.
    local doneText = nil
    local paragraphs = {}
    local currentEvent = nil
    local currentData = {}

    for line in (body .. "\n\n"):gmatch("([^\n]*)\n") do
        if line:find("^event: ") then
            currentEvent = line:sub(8)
            currentData = {}
        elseif line:find("^data: ") then
            table.insert(currentData, line:sub(7))
        elseif line == "" and currentEvent then
            -- End of SSE block
            local text = table.concat(currentData, "\n")
            if currentEvent == "done" then
                doneText = text
            elseif currentEvent == "paragraph" and text ~= "" then
                table.insert(paragraphs, text)
            end
            currentEvent = nil
            currentData = {}
        end
    end

    if doneText and doneText ~= "" then
        return doneText
    end
    if #paragraphs > 0 then
        return table.concat(paragraphs, "\n\n")
    end
    return ""
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
        withdrawAfter = 0,
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
    local url = self.agent_url .. "/v1/health"
    hs.http.asyncGet(url, nil, function(status, _body, _headers)
        local wasConnected = self.connected
        self.connected = (status >= 200 and status < 400)
        if self.connected ~= wasConnected then
            self:_updateMenubar(self.lastProactive ~= nil and not self.visible)
        end
    end)
end

return KatePanel
