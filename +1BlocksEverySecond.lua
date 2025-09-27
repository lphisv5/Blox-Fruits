-- =========================================
-- YANZ HUB | Auto Click Only | v0.2
-- Fully Updated & Debugged
-- =========================================

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Local Player
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- Character & HumanoidRootPart
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Attempt to get VirtualInputManager (for safe clicks)
local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then
    VirtualInputManager = nil
end

-- Load NOTHING UI Library
local NothingLibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
if not NothingLibrary then
    warn("YANZ HUB: Failed to load NOTHING UI Library!")
    return
end

-- =========================================
-- Create Window
-- =========================================
local Window = NothingLibrary.new({
    Title = "YANZ HUB | Auto Click Only",
    Description = "By lphisv5",
    Keybind = Enum.KeyCode.RightShift
})

-- Make GUI visible immediately
Window:Show()

-- =========================================
-- Create Tabs & Sections
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

-- Status Label
local StatusLabel = AutoClickSection:NewTitle("Status: Ready")

-- =========================================
-- Global Variables
-- =========================================
_G.clickDelay = 0.1
_G.autoClickPos = {X = nil, Y = nil}
_G.isLoopRunning = false

-- =========================================
-- Helper: SafeClick
-- Clicks without interfering with GUI
-- =========================================
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    if not VirtualInputManager then return end
    local cam = workspace.CurrentCamera
    if not cam then return end

    -- Use pcall for safety
    pcall(function()
        -- Send mouse click events directly to camera (world)
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
        -- Default to center of viewport
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
        -- Timeout for 10 seconds
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
-- Only numbers, simplified display
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
-- Notes & Bug Fixes Implemented
-- =========================================
-- 1. Window:Show() added to ensure GUI appears immediately.
-- 2. Removed all unnecessary functions (Discord, emergency stop, player pos).
-- 3. SafeClick now clicks directly on Camera, preventing GUI interference.
-- 4. Auto Click loop uses task.spawn + pcall for stability.
-- 5. Speed Settings Dropdown simplified to numeric display only.
-- 6. Auto Click will not block dragging GUI or interacting with other UI elements.
-- 7. Input detection for setting click position uses timeout to avoid stuck states.

print("YANZ HUB | Auto Click Only v0.2 loaded successfully!")
