-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Player
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

-- Virtual Input
local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

-- Load Nothing Library
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local ok_lib, NothingLibrary = pcall(function()
    local code = game:HttpGetAsync(libURL)
    if code then
        local func, err = loadstring(code)
        if not func then warn("Loadstring error:", err) return nil end
        return func()
    end
end)
if not ok_lib or not NothingLibrary then
    warn("YANZ HUB: Failed to load Nothing UI Library")
    return
end

-- Window
local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.2.1",
    Description = "By lphisv5 | Game : +1 Blocks Every Second",
    Keybind = Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282'
})

-- Tabs
local HomeTab = Window:NewTab({Title = "HOME", Description = "Home Features", Icon = "rbxassetid://7733960981"})
local MainTab = Window:NewTab({Title = "MAIN", Description = "Auto Click Features", Icon = "rbxassetid://7733960981"})

-- Sections
local HomeSection = HomeTab:NewSection({Title = "Home", Icon = "rbxassetid://7733916988", Position = "Left"})
local MainControlsSection = MainTab:NewSection({Title = "Controls", Icon = "rbxassetid://7733916988", Position = "Left"})
local MainSettingsSection = MainTab:NewSection({Title = "Speed Settings", Icon = "rbxassetid://7743869054", Position = "Right"})

-- UI Labels
local posLabel = MainControlsSection:NewTitle("Player Pos: Waiting...")
local heightLabel = HomeSection:NewTitle("Height: Waiting...")
local StatusLabel = MainControlsSection:NewTitle("Status: Initializing...")

-- Globals / Config
local clickDelay = 0.1
local humanizeClicks = false
local autoClickPos = {X = nil, Y = nil}
local lastClickPos = nil
local isLoopRunning = false
local clickCount = 0
local loopThread = nil

-- Connections
local connections = {}
local function addConn(conn) if conn then table.insert(connections, conn) end return conn end

-- Helpers
local function updateLabel(lbl, text)
    if not lbl then return end
    pcall(function()
        if typeof(lbl) == "Instance" and lbl.Text ~= nil then lbl.Text = tostring(text) end
        if lbl.Set then lbl:Set(tostring(text)) end
        if lbl.SetText then lbl:SetText(tostring(text)) end
        if lbl.SetTitle then lbl:SetTitle(tostring(text)) end
    end)
end

local function updateStatusLabel()
    local statusText = "Status: " .. (isLoopRunning and "Running" or "Ready")
    statusText = statusText .. " | Delay: " .. string.format("%.2f", clickDelay) .. "s"
    statusText = statusText .. " | Humanization: " .. (humanizeClicks and "ON" or "OFF")
    statusText = statusText .. " | Clicks: " .. clickCount
    statusText = statusText .. " | Last Pos: " .. (lastClickPos and string.format("(%.0f, %.0f)", lastClickPos.X, lastClickPos.Y) or "N/A")
    updateLabel(StatusLabel, statusText)
end

-- Safe Click
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    if pos.X < 0 or pos.Y < 0 or pos.X > viewport.X or pos.Y > viewport.Y then return end
    if not VirtualInputManager then return end
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, cam, 1)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, cam, 1)
    end)
end

-- Click Loop
local function ClickLoop()
    local posToClick = autoClickPos.X and autoClickPos.Y and autoClickPos or {X = workspace.CurrentCamera.ViewportSize.X/2, Y = workspace.CurrentCamera.ViewportSize.Y/2}
    SafeClick(posToClick)
    clickCount = clickCount + 1
    lastClickPos = posToClick
    updateStatusLabel()
end

-- Start / Stop AutoClicker
local function startAutoClicker()
    if loopThread then return end
    loopThread = task.spawn(function()
        while isLoopRunning do
            pcall(ClickLoop)
            local delayTime = humanizeClicks and clickDelay * (0.8 + math.random() * 0.4) or clickDelay
            task.wait(delayTime)
        end
        loopThread = nil
    end)
end

-- Home Button
HomeSection:NewButton({
    Title = "Join Discord",
    Icon = "rbxassetid://7733960981",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/DfVuhsZb")
            NothingLibrary:Notify({Title = "Copied!", Content = "Successfully copied the link", Duration = 5})
        end)
    end
})

-- Auto Click Toggle
MainControlsSection:NewToggle({
    Title = "Auto Click",
    Default = isLoopRunning,
    Callback = function(value)
        isLoopRunning = value
        updateStatusLabel()
        if isLoopRunning then startAutoClicker() end
    end
})

-- Set Click Position
MainControlsSection:NewButton({
    Title = "SET CLICK POSITION",
    Callback = function()
        local settingPosition = true
        updateLabel(StatusLabel, "🖱️ Click anywhere to set position...")
        local conn
        conn = addConn(UserInputService.InputBegan:Connect(function(input, processed)
            if processed or not settingPosition then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                autoClickPos = {X = mousePos.X, Y = mousePos.Y}
                updateLabel(StatusLabel, "✅ Position set: " .. math.floor(mousePos.X) .. ", " .. math.floor(mousePos.Y))
                settingPosition = false
                if conn then conn:Disconnect() end
                task.wait(1)
                updateStatusLabel()
            end
        end))
        task.delay(10, function()
            if settingPosition then
                settingPosition = false
                if conn then conn:Disconnect() end
                updateLabel(StatusLabel, "❌ Position set cancelled")
                task.wait(2)
                updateStatusLabel()
            end
        end)
    end
})

-- Speed Slider
MainSettingsSection:NewSlider({
    Title = "Click Delay (seconds)",
    Min = 0.01,
    Max = 2,
    Default = clickDelay,
    Callback = function(value)
        clickDelay = value
        updateStatusLabel()
        pcall(function()
            NothingLibrary:Notify({Title = "Speed Updated", Content = "Click delay set to " .. string.format("%.2f", value) .. "s", Duration = 2})
        end)
    end
})

-- Humanization Toggle
MainSettingsSection:NewToggle({
    Title = "Enable Humanization",
    Default = humanizeClicks,
    Callback = function(value)
        humanizeClicks = value
        updateStatusLabel()
        pcall(function()
            NothingLibrary:Notify({Title = "Humanization " .. (value and "Enabled" or "Disabled"), Content = value and "Click timing randomized" or "Click timing consistent", Duration = 2})
        end)
    end
})

-- Position Updater
local function startPositionUpdater(char)
    if humanoidRootPart and humanoidRootPart.Parent then
        humanoidRootPart = char:WaitForChild("HumanoidRootPart")
    end
    -- Disconnect old RenderStepped
    for i=#connections,1,-1 do
        local c = connections[i]
        if c and c.Name == "RenderStepped" then
            c:Disconnect()
            table.remove(connections, i)
        end
    end
    local renderConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            if humanoidRootPart and humanoidRootPart.Parent then
                local pos = humanoidRootPart.Position
                updateLabel(posLabel, string.format("Player Pos: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z))
                updateLabel(heightLabel, string.format("Height: Y=%.2f", pos.Y))
            else
                updateLabel(posLabel, "Player Pos: Waiting...")
                updateLabel(heightLabel, "Height: Waiting...")
            end
        end)
    end)
    renderConn.Name = "RenderStepped"
    addConn(renderConn)
end

-- Init Position Updater
if LocalPlayer.Character then startPositionUpdater(LocalPlayer.Character) end
addConn(LocalPlayer.CharacterAdded:Connect(startPositionUpdater))

-- Emergency Stop F6/F7
addConn(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        isLoopRunning = not isLoopRunning
        updateStatusLabel()
        if isLoopRunning then startAutoClicker() end
    elseif input.KeyCode == Enum.KeyCode.F7 then
        isLoopRunning = false
        updateStatusLabel()
        pcall(function()
            NothingLibrary:Notify({Title = "FORCE STOPPED", Content = "Auto Clicker stopped by F7", Duration = 2})
        end)
    end
end))

-- Cleanup
local function cleanup()
    isLoopRunning = false
    for _, c in ipairs(connections) do
        pcall(function() if c and c.Disconnect then c:Disconnect() end end)
    end
    connections = {}
    pcall(function()
        if Window and Window.Destroy then Window:Destroy() end
        if Window and Window.Close then Window:Close() end
    end)
end

addConn(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then cleanup() end
end))

-- Initial Status
updateStatusLabel()
print("YANZ HUB - Loaded Successfully")
