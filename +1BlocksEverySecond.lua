-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then LocalPlayer = Players.PlayerAdded:Wait() end

-- Character
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Load Nothing UI Library
local NothingLibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()

-- Create Window
local Window = NothingLibrary.new({
    Title = "YANZ HUB | Auto Click Only",
    Description = "By lphisv5",
    Keybind = Enum.KeyCode.RightShift
})
Window:Show()

-- Auto Click Tab
local AutoClickTab = Window:NewTab({Title = "Auto Clicker", Description = "Auto Click Features"})
local AutoClickSection = AutoClickTab:NewSection({Title = "Controls", Position = "Left"})
local SettingsSection = AutoClickTab:NewSection({Title = "Speed Settings", Position = "Right"})

-- Status Label
local StatusLabel = AutoClickSection:NewTitle("Status: Ready")

-- Globals
_G.clickDelay = 0.1
_G.autoClickPos = {X = nil, Y = nil}
_G.isLoopRunning = false

-- ------------------------------
-- Helper: SafeClick (ไม่กระทบ GUI)
-- ------------------------------
local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    local cam = workspace.CurrentCamera
    if not cam then return end
    if not VirtualInputManager then return end
    pcall(function()
        -- คลิกลงบน world camera โดยตรง ไม่กระทบ GUI
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, cam, 1)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, cam, 1)
    end)
end

-- ------------------------------
-- Click Loop
-- ------------------------------
local function ClickLoop()
    if _G.autoClickPos.X and _G.autoClickPos.Y then
        SafeClick(_G.autoClickPos)
    else
        local cam = workspace.CurrentCamera
        if not cam then return end
        local viewportSize = cam.ViewportSize
        SafeClick({X = viewportSize.X/2, Y = viewportSize.Y/2})
    end
end

-- ------------------------------
-- Auto Click Toggle
-- ------------------------------
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

-- ------------------------------
-- Set Click Position Button
-- ------------------------------
AutoClickSection:NewButton({
    Title = "SET CLICK POSITION",
    Callback = function()
        StatusLabel:SetTitle("🖱️ Click anywhere to set position...")
        local conn
        local setting = true
        conn = UserInputService.InputBegan:Connect(function(input, gp)
            if gp or not setting then return end
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

-- ------------------------------
-- Speed Settings Dropdown
-- ------------------------------
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
