-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Player
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

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

-- Tabs & Sections
local MainTab = Window:NewTab({Title = "MAIN", Description = "Auto Farm Features", Icon = "rbxassetid://7733960981"})
local MainControlsSection = MainTab:NewSection({Title = "Controls", Icon = "rbxassetid://7733916988", Position = "Left"})
local MainSettingsSection = MainTab:NewSection({Title = "Speed Settings", Icon = "rbxassetid://7743869054", Position = "Right"})

-- Status Label
local StatusLabel = MainControlsSection:NewTitle("Status: Sleeping")

-- Globals / Config
local clickDelay = 0.1
local autoClickPos = {X = nil, Y = nil}
local isLoopRunning = false
local lastRun = false
local loopThread = nil
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

local function updateStatus()
    if isLoopRunning then
        lastRun = true
        updateLabel(StatusLabel, "Status: Working")
    elseif not isLoopRunning and lastRun then
        updateLabel(StatusLabel, "Status: Not Working")
    else
        updateLabel(StatusLabel, "Status: Sleeping")
    end
end

-- Safe Click (รองรับ background click บน Windows)
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    local cam = workspace.CurrentCamera
    if not cam then return end

    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, cam, 1)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, cam, 1)
        end)
    end
end

-- Click Loop
local function ClickLoop()
    local posToClick = autoClickPos.X and autoClickPos.Y and autoClickPos or {X = workspace.CurrentCamera.ViewportSize.X/2, Y = workspace.CurrentCamera.ViewportSize.Y/2}
    SafeClick(posToClick)
end

-- Start Auto Farm
local function startAutoFarm()
    if loopThread then return end
    loopThread = task.spawn(function()
        while isLoopRunning do
            pcall(ClickLoop)
            task.wait(clickDelay)
        end
        loopThread = nil
    end)
end

-- Auto Farm Toggle
MainControlsSection:NewToggle({
    Title = "Auto Farm Block",
    Default = false,
    Callback = function(value)
        isLoopRunning = value
        updateStatus()
        if isLoopRunning then startAutoFarm() end
    end
})

-- Set Click Position
MainControlsSection:NewButton({
    Title = "SET FARM POSITION",
    Callback = function()
        local settingPosition = true
        updateLabel(StatusLabel, "🖱️ Click anywhere to set farm position...")
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
                updateStatus()
            end
        end))
        task.delay(10, function()
            if settingPosition then
                settingPosition = false
                if conn then conn:Disconnect() end
                updateLabel(StatusLabel, "❌ Position set cancelled")
                task.wait(2)
                updateStatus()
            end
        end)
    end
})

-- Speed Slider
MainSettingsSection:NewSlider({
    Title = "Farm Delay (seconds)",
    Min = 0.01,
    Max = 2,
    Default = 0.1,
    Callback = function(value)
        clickDelay = value
        updateStatus()
    end
})

-- Emergency Stop F6/F7
addConn(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        isLoopRunning = not isLoopRunning
        updateStatus()
        if isLoopRunning then startAutoFarm() end
    elseif input.KeyCode == Enum.KeyCode.F7 then
        isLoopRunning = false
        updateStatus()
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
updateStatus()
print("YANZ HUB - Auto Farm Block Script Loaded Successfully")
