-- =========================================
-- YANZ HUB | Auto Click Only | Updated Version
-- Full working GUI, SafeClick, and Speed Settings
-- =========================================

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then LocalPlayer = Players.PlayerAdded:Wait() end

-- Character
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- VirtualInputManager (Safe Clicks)
local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

-- Load Nothing UI Library
local NothingLibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
if not NothingLibrary then
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
local AutoClickTab = Window:NewTab({Title = "Auto Clicker", Description = "Auto Click Features"})
local AutoClickSection = AutoClickTab:NewSection({Title = "Controls", Position = "Left"})
local SettingsSection = AutoClickTab:NewSection({Title = "Speed Settings", Position = "Right"})

-- Status Label
local StatusLabel = AutoClickSection:NewTitle("Status: Ready")

-- =========================================
-- Global Variables
-- =========================================
_G.clickDelay = 0.1
_G.autoClickPos = {X = nil, Y = nil}
_G.isLoopRunning = false

-- =========================================
-- SafeClick function (clicks without interfering with GUI)
-- =========================================
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    if not VirtualInputManager then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    pcall(function()
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, cam, 1)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, cam, 1)
    end)
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
        conn = UserInputService.InputBegan:Connect(function(input, processed)
            if processed or not setting then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                _G.autoClickPos = {X = mousePos.X, Y = mousePos.Y}
                StatusLabel:SetTitle("✅ Position set: " .. math.floor(mousePos.X) .. ", " .. math.floor(mousePos.Y))
                setting = false
                if conn then conn:Disconnect() end
            end
        end)
        task.delay(10, function()
            if setting then
                setting = false
                if conn then conn:Disconnect() end
                StatusLabel:SetTitle("❌ Position set cancelled")
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
        StatusLabel:SetTitle("Delay: " .. value)
    end
})

-- =========================================
-- Position Updater (Optional, shows player position)
-- =========================================
local function startPositionUpdater(character)
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    RunService.RenderStepped:Connect(function()
        pcall(function()
            if humanoidRootPart and humanoidRootPart.Parent then
                local pos = humanoidRootPart.Position
                StatusLabel:SetTitle(string.format("Player Pos: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z))
            end
        end)
    end)
end
if LocalPlayer.Character then startPositionUpdater(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(function(char) startPositionUpdater(char) end)

print("YANZ HUB | Auto Click Only (GUI loaded) successfully!")
