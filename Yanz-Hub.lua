local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = nil
if character then
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
end

local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local ok_lib, NothingLibrary = pcall(function()
    return loadstring(game:HttpGetAsync(libURL))()
end)
if not ok_lib or not NothingLibrary then
    warn("YANZ HUB: cannot load Nothing UI Library from URL:", libURL)
    return
end

local Window = nil
local ok_window, res_window = pcall(function()
    return NothingLibrary.new({
        Title = "YANZ HUB | V0.1.5",
        Description = "By lphisv5",
        Keybind = Enum.KeyCode.RightShift,
        Logo = 'http://www.roblox.com/asset/?id=125456335927282'
    })
end)
if ok_window then Window = res_window else
    warn("YANZ HUB: cannot create window from NothingLibrary")
    return
end

local Tab = Window:NewTab({
    Title = "Auto Clicker",
    Description = "Auto Click Features",
    Icon = "rbxassetid://7733960981"
})

local Section = Tab:NewSection({
    Title = "Controls",
    Icon = "rbxassetid://7733916988",
    Position = "Left"
})

local SettingsSection = Tab:NewSection({
    Title = "Speed Settings",
    Icon = "rbxassetid://7743869054",
    Position = "Right"
})

_G.clickDelay = _G.clickDelay or 0.1
_G.autoClickPos = _G.autoClickPos or {X = nil, Y = nil}
_G.isLoopRunning = _G.isLoopRunning or false

-- Helper: updateLabel tries multiple APIs (robust to different library implementations)
local function updateLabel(lbl, text)
    if not lbl then return end
    -- If it's a Roblox Instance (TextLabel/TextButton)
    local ok = pcall(function()
        if typeof(lbl) == "Instance" then
            if lbl.Text ~= nil then lbl.Text = tostring(text) end
            return
        end
    end)
    if ok then return end
    -- Try common methods
    pcall(function() if lbl.Set then lbl:Set(tostring(text)) end end)
    pcall(function() if lbl.SetText then lbl:SetText(tostring(text)) end end)
    pcall(function() if lbl.SetTitle then lbl:SetTitle(tostring(text)) end end)
    -- Fallback assign
    pcall(function() lbl.Text = tostring(text) end)
end

-- Create Status & Position labels (keep returned refs)
local StatusLabel = Section:NewTitle("Status: Ready")
local PositionLabel = Section:NewTitle("Position: X: 0, Y: 0, Z: 0")

-- Keep references to created UI controls that we might change programmatically
local autoToggle = nil

-- Connection management for cleanup
local connections = {}
local function addConn(conn)
    if conn then table.insert(connections, conn) end
    return conn
end

-- Safe Click function with multiple attempt signatures
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    if pos.X < 0 or pos.Y < 0 or pos.X > viewport.X or pos.Y > viewport.Y then
        warn("⚠️ Invalid click position", pos.X, pos.Y, "Viewport:", viewport)
        return
    end

    if not VirtualInputManager then
        warn("⚠️ VirtualInputManager not available on this executor — auto-click may not work.")
        return
    end

    -- Try common signatures (pcall to avoid runtime error)
    local tried = {}
    local function trySig(target)
        local ok, err = pcall(function()
            -- common: (x,y,buttonDown,gameOrCamera,instanceId)
            if target == "workspace" then
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, workspace, 1)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, workspace, 1)
            elseif target == "game" then
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
            else
                -- fallback try with camera
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, cam, 1)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, cam, 1)
            end
        end)
        if not ok then table.insert(tried, err) end
        return ok
    end

    if trySig("workspace") then return end
    if trySig("game") then return end
    if trySig("camera") then return end

    -- If all fail, print collected errors (debug)
    warn("❌ SafeClick: all attempts failed. Errors:", tried)
end

-- Click Loop (safe)
local function ClickLoop()
    if _G.autoClickPos and _G.autoClickPos.X and _G.autoClickPos.Y then
        SafeClick(_G.autoClickPos)
    else
        local cam = workspace.CurrentCamera
        if not cam then return end
        local viewportSize = cam.ViewportSize
        local centerPos = { X = viewportSize.X / 2, Y = viewportSize.Y / 2 }
        SafeClick(centerPos)
    end
end

-- Auto Click toggle (use NewToggle and capture reference)
autoToggle = Section:NewToggle({
    Title = "Auto Click",
    Default = _G.isLoopRunning or false,
    Callback = function(value)
        _G.isLoopRunning = value
        if value then
            updateLabel(StatusLabel, "Auto Clicking Active")
            task.spawn(function()
                while _G.isLoopRunning do
                    pcall(ClickLoop)
                    task.wait(_G.clickDelay or 0.2)
                end
            end)
        else
            updateLabel(StatusLabel, "Status: Ready")
        end
    end
})

-- Set Position Button (use GetMouseLocation and task.delay)
Section:NewButton({
    Title = "SET CLICK POSITION",
    Callback = function()
        local settingPosition = true
        updateLabel(StatusLabel, "🖱️ Click anywhere to set position...")
        local conn
        conn = addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not settingPosition then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation() -- Vector2
                -- Optional: if coords seem out of viewport, you may need to adjust by topbar height depending on executor/scale
                _G.autoClickPos = { X = mousePos.X, Y = mousePos.Y }
                updateLabel(StatusLabel, "✅ Position set: " .. math.floor(_G.autoClickPos.X) .. ", " .. math.floor(_G.autoClickPos.Y))
                settingPosition = false
                if conn then conn:Disconnect() end
            end
        end))

        task.delay(10, function()
            if settingPosition then
                settingPosition = false
                if conn then conn:Disconnect() end
                updateLabel(StatusLabel, "❌ Position set cancelled")
                task.wait(2)
                if not _G.isLoopRunning then
                    updateLabel(StatusLabel, "Status: Ready")
                end
            end
        end)
    end
})

-- Speed Buttons (with pcall on notify)
local speeds = {
    {label = "ULTRA FAST", value = 00.01},
    {label = "FAST", value = 0.5},
    {label = "NORMAL", value = 1},
    {label = "SLOW", value = 1.5}
}

for _, speedData in ipairs(speeds) do
    SettingsSection:NewButton({
        Title = speedData.label .. " (" .. speedData.value .. "s)",
        Callback = function()
            _G.clickDelay = speedData.value
            updateLabel(StatusLabel, "Delay: " .. speedData.value .. "s")
            pcall(function()
                if NothingLibrary.Notify then
                    NothingLibrary:Notify({
                        Title = "Speed Updated",
                        Content = "Click delay set to " .. speedData.value .. "s",
                        Duration = 2
                    })
                end
            end)
        end
    })
end

-- Real-Time Position Update (single managed connection)
local renderConn = nil
local function startPositionUpdater()
    if renderConn then
        pcall(function() renderConn:Disconnect() end)
        renderConn = nil
    end
    renderConn = addConn(RunService.RenderStepped:Connect(function()
        if humanoidRootPart and humanoidRootPart.Parent then
            local pos = humanoidRootPart.Position
            updateLabel(PositionLabel, string.format("Position: X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z))
        else
            updateLabel(PositionLabel, "Position: Waiting for character...")
        end
    end))
end

-- initial humanoidRootPart assignment + start updater
if not humanoidRootPart then
    -- try find if character loaded later
    if LocalPlayer.Character then
        humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
end
startPositionUpdater()

-- CharacterAdded handler (update humanoidRootPart & restart updater)
addConn(LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart", 10)
    startPositionUpdater()
end))

-- Emergency Stop Toggle (F6) - keep UI toggle in sync if possible
addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.isLoopRunning = not _G.isLoopRunning
        -- Update UI toggle if library supports it
        pcall(function()
            if autoToggle and autoToggle.Set then
                autoToggle:Set(_G.isLoopRunning)
            elseif autoToggle and autoToggle.SetValue then
                autoToggle:SetValue(_G.isLoopRunning)
            end
        end)
        if _G.isLoopRunning then
            updateLabel(StatusLabel, "Auto Clicking Active (F6)")
            task.spawn(function()
                while _G.isLoopRunning do
                    pcall(ClickLoop)
                    task.wait(_G.clickDelay or 0.2)
                end
            end)
        else
            updateLabel(StatusLabel, "Emergency Stopped (F6)")
            task.wait(2)
            if not _G.isLoopRunning then
                updateLabel(StatusLabel, "Status: Ready")
            end
        end
    end
end))

-- Cleanup routine: disconnect all stored connections and stop loop
local function cleanup()
    _G.isLoopRunning = false
    for _,c in ipairs(connections) do
        pcall(function()
            if c and c.Disconnect then c:Disconnect() end
        end)
    end
    -- Try to destroy window if lib exposes method
    pcall(function()
        if Window and Window.Destroy then Window:Destroy() end
        if Window and Window.Close then Window:Close() end
    end)
end

addConn(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        cleanup()
    end
end))

print("YANZ HUB | V0.1.5 Loaded Successfully")
