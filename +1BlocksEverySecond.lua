-- =========================================
-- YANZ HUB | Auto Click Only | Updated Version
-- Ensures GUI loads and includes essential features
-- =========================================

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- Character
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Load VirtualInputManager (for safe clicks)
local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

-- Load NOTHING UI Library
local ok_lib, NothingLibrary = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
end)
if not ok_lib or not NothingLibrary then
    warn("YANZ HUB: Failed to load NOTHING UI Library!")
    return
end

-- =========================================
-- Create GUI Window
-- =========================================
local Window = NothingLibrary:CreateWindow({
    Title = "YANZ HUB | Auto Click Only",
    Description = "By lphisv5",
    Keybind = Enum.KeyCode.RightShift
})

if not Window then
    warn("YANZ HUB: Window creation failed!")
    return
end

-- =========================================
-- Tabs & Sections
-- =========================================
local AutoClickTab = Window:NewTab({
    Title = "Auto Clicker",
    Description = "Auto Click Features"
})
local AutoClickSection = AutoClickTab:NewSection({
    Title = "Controls",
    Position = "Left"
})
local SettingsSection = AutoClickTab:NewSection({
    Title = "Speed Settings",
    Position = "Right"
})
local PositionSection = AutoClickTab:NewSection({
    Title = "Player Position",
    Position = "Right"
})

-- Labels
local StatusLabel = AutoClickSection:NewTitle("Status: Ready")
local PosLabel = PositionSection:NewTitle("Player Pos: Waiting...")

-- =========================================
-- Global Variables
-- =========================================
_G.clickDelay = 0.1
_G.autoClickPos = {X = nil, Y = nil}
_G.isLoopRunning = false

-- Connections manager
local connections = {}
local function addConn(conn) if conn then table.insert(connections, conn) end return conn end

-- =========================================
-- SafeClick function
-- =========================================
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    if not VirtualInputManager then
        warn("⚠️ VirtualInputManager not available")
        return
    end
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    if pos.X < 0 or pos.Y < 0 or pos.X > viewport.X or pos.Y > viewport.Y then
        warn("⚠️ Invalid click position", pos.X, pos.Y, "Viewport:", viewport)
        return
    end
    local tried = {}
    local function trySig(target)
        local ok, err = pcall(function()
            if target == "workspace" then
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, workspace, 1)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, workspace, 1)
            elseif target == "game" then
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
            else
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
    warn("❌ SafeClick: all attempts failed. Errors:", tried)
end

-- =========================================
-- Click Loop
-- =========================================
local function ClickLoop()
    if _G.autoClickPos.X and _G.autoClickPos.Y then
        SafeClick(_G.autoClickPos)
    else
        local cam = workspace.CurrentCamera
        if not cam then return end
        local viewport = cam.ViewportSize
        SafeClick({X = viewport.X / 2, Y = viewport.Y / 2})
    end
end

-- =========================================
-- Auto Click Toggle
-- =========================================
AutoClickSection:NewToggle({
    Title = "Auto Click",
    Default = _G.isLoopRunning,
    Callback = function(value)
        _G.isLoopRunning = value
        StatusLabel:SetTitle(value and "Auto Clicking Active" or "Status: Ready")
        if value then
            task.spawn(function()
                while _G.isLoopRunning do
                    pcall(ClickLoop)
                    task.wait(_G.clickDelay)
                end
            end)
        end
    end
})

-- =========================================
-- Set Click Position Button
-- =========================================
AutoClickSection:NewButton({
    Title = "SET CLICK POSITION",
    Callback = function()
        StatusLabel:SetTitle("🖱️ Click anywhere to set position...")
        local setting = true
        local conn
        conn = addConn(UserInputService.InputBegan:Connect(function(input, processed)
            if processed or not setting then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                _G.autoClickPos = {X = mousePos.X, Y = mousePos.Y}
                StatusLabel:SetTitle("✅ Position set: " .. math.floor(mousePos.X) .. ", " .. math.floor(mousePos.Y))
                NothingLibrary:Notify({
                    Title = "Position Set",
                    Content = "Click position set to X: " .. math.floor(mousePos.X) .. ", Y: " .. math.floor(mousePos.Y),
                    Duration = 3
                })
                setting = false
                if conn then conn:Disconnect() end
            end
        end))
        task.delay(10, function()
            if setting then
                setting = false
                if conn then conn:Disconnect() end
                StatusLabel:SetTitle("❌ Position set cancelled")
                NothingLibrary:Notify({
                    Title = "Position Set Cancelled",
                    Content = "Click position setting was cancelled",
                    Duration = 3
                })
            end
        end)
    end
})

-- =========================================
-- Speed Settings Dropdown
-- =========================================
local speedOptions = {0.01, 0.5, 1, 1.5}
SettingsSection:NewDropdown({
    Title = "Click Speed",
    Default = tostring(_G.clickDelay),
    Options = speedOptions,
    Callback = function(value)
        _G.clickDelay = tonumber(value)
        StatusLabel:SetTitle("Delay: " .. value .. "s")
        NothingLibrary:Notify({
            Title = "Speed Updated",
            Content = "Click delay set to " .. value .. "s",
            Duration = 2
        })
    end
})

-- =========================================
-- Player Position Updater
-- =========================================
local function startPositionUpdater(character)
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local renderConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            if humanoidRootPart and humanoidRootPart.Parent then
                local pos = humanoidRootPart.Position
                PosLabel:SetTitle(string.format("Player Pos: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z))
            else
                PosLabel:SetTitle("Player Pos: Waiting...")
            end
        end)
    end)
    addConn(renderConn)
end

if LocalPlayer.Character then
    startPositionUpdater(LocalPlayer.Character)
end
addConn(LocalPlayer.CharacterAdded:Connect(function(char)
    startPositionUpdater(char)
end))

-- =========================================
-- Emergency Stop (F6)
-- =========================================
addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.isLoopRunning = not _G.isLoopRunning
        pcall(function()
            local toggle = AutoClickSection:GetToggle("Auto Click") -- Assumes library supports GetToggle
            if toggle and toggle.Set then
                toggle:Set(_G.isLoopRunning)
            end
        end)
        StatusLabel:SetTitle(_G.isLoopRunning and "Auto Clicking Active (F6)" or "Emergency Stopped (F6)")
        NothingLibrary:Notify({
            Title = _G.isLoopRunning and "Auto Click Resumed" or "Emergency Stop",
            Content = _G.isLoopRunning and "Auto clicking resumed via F6" or "Auto clicking stopped via F6",
            Duration = 3
        })
        if _G.isLoopRunning then
            task.spawn(function()
                while _G.isLoopRunning do
                    pcall(ClickLoop)
                    task.wait(_G.clickDelay)
                end
            end)
        end
    end
end))

-- =========================================
-- Cleanup
-- =========================================
local function cleanup()
    _G.isLoopRunning = false
    for _, c in ipairs(connections) do
        pcall(function() if c and c.Disconnect then c:Disconnect() end end)
    end
    pcall(function()
        if Window and Window.Destroy then Window:Destroy() end
        if Window and Window.Close then Window:Close() end
    end)
end

addConn(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then cleanup() end
end))

print("YANZ HUB | Auto Click Only (Updated) loaded successfully!")
