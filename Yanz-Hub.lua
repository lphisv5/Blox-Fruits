local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- Safety check for LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- Wait for character and humanoidRootPart
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

-- Load Nothing UI Library
local NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()

-- Create Window
local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.1.4 [BETA]",
    Description = "Advanced Auto Clicker with Cyber UI",
    Keybind = Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282'
})

-- Create Tab
local Tab = Window:NewTab({
    Title = "Auto Clicker",
    Description = "Auto Click Features",
    Icon = "rbxassetid://7733960981"
})

-- Main Controls Section
local Section = Tab:NewSection({
    Title = "Controls",
    Icon = "rbxassetid://7733916988",
    Position = "Left"
})

-- Settings Section
local SettingsSection = Tab:NewSection({
    Title = "Speed Settings",
    Icon = "rbxassetid://7743869054",
    Position = "Right"
})

-- Global Variables
_G.clickDelay = _G.clickDelay or 0.2
_G.autoClickPos = _G.autoClickPos or {X = nil, Y = nil}
_G.isLoopRunning = false

-- Status and Position Labels (NewTitle returns TextLabel for .Text update)
local StatusLabel = Section:NewTitle("Status: Ready")
local PositionLabel = Section:NewTitle("Position: X: 0, Y: 0, Z: 0")

-- Auto Click Toggle (use NewToggle instead of Button for safe state management)
Section:NewToggle({
    Title = "Auto Click",
    Default = false,
    Callback = function(value)
        _G.isLoopRunning = value
        if value then
            StatusLabel.Text = "Auto Clicking Active"
            spawn(function()
                while _G.isLoopRunning do
                    ClickLoop()
                    wait(_G.clickDelay)
                end
            end)
        else
            StatusLabel.Text = "Status: Ready"
        end
    end
})

-- Set Position Button
Section:NewButton({
    Title = "SET CLICK POSITION",
    Callback = function()
        local settingPosition = true
        StatusLabel.Text = "🖱️ Click anywhere to set position..."
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not settingPosition then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                _G.autoClickPos = {
                    X = mousePos.X,
                    Y = mousePos.Y
                }
                StatusLabel.Text = "✅ Position set: " .. math.floor(_G.autoClickPos.X) .. ", " .. math.floor(_G.autoClickPos.Y)
                settingPosition = false
                if connection then
                    connection:Disconnect()
                end
            end
        end)
        
        delay(10, function()
            if connection and settingPosition then
                connection:Disconnect()
                StatusLabel.Text = "❌ Position set cancelled"
                wait(2)
                if not _G.isLoopRunning then
                    StatusLabel.Text = "Status: Ready"
                end
            end
        end)
    end
})

-- Speed Buttons
local speeds = {
    {label = "ULTRA FAST", value = 0.01},
    {label = "FAST", value = 0.6},
    {label = "NORMAL", value = 1},
    {label = "SLOW", value = 1.5}
}

for _, speedData in ipairs(speeds) do
    SettingsSection:NewButton({
        Title = speedData.label .. " (" .. speedData.value .. "s)",
        Callback = function()
            _G.clickDelay = speedData.value
            StatusLabel.Text = "Delay: " .. speedData.value .. "s"
            -- Optionally notify
            NothingLibrary:Notify({
                Title = "Speed Updated",
                Content = "Click delay set to " .. speedData.value .. "s",
                Duration = 2
            })
        end
    })
end

-- Real-Time Position Update (use .Text)
if humanoidRootPart then
    RunService.RenderStepped:Connect(function()
        local pos = humanoidRootPart.Position
        PositionLabel.Text = string.format("Position: X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
    end)
else
    PositionLabel.Text = "Position: Waiting for character..."
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart", 10)
        if humanoidRootPart then
            RunService.RenderStepped:Connect(function()
                local pos = humanoidRootPart.Position
                PositionLabel.Text = string.format("Position: X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
            end)
        end
    end)
end

-- Safe Click Function
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    
    local viewportSize = workspace.CurrentCamera.ViewportSize
    if pos.X < 0 or pos.Y < 0 or pos.X > viewportSize.X or pos.Y > viewportSize.Y then
        warn("⚠️ Invalid click position")
        return
    end
    
    local success, errorMsg = pcall(function()
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
    end)
    
    if not success then
        warn("❌ Click error: " .. tostring(errorMsg))
    end
end

-- Click Loop
function ClickLoop()
    if _G.autoClickPos and _G.autoClickPos.X and _G.autoClickPos.Y then
        SafeClick(_G.autoClickPos)
    else
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local centerPos = {
            X = viewportSize.X / 2,
            Y = viewportSize.Y / 2
        }
        SafeClick(centerPos)
    end
end

-- Emergency Stop Toggle (F6) - Update flag and status only
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.isLoopRunning = not _G.isLoopRunning
        if _G.isLoopRunning then
            StatusLabel.Text = "Auto Clicking Active (F6)"
            spawn(function()
                while _G.isLoopRunning do
                    ClickLoop()
                    wait(_G.clickDelay)
                end
            end)
        else
            StatusLabel.Text = "Emergency Stopped (F6)"
            wait(2)
            if not _G.isLoopRunning then
                StatusLabel.Text = "Status: Ready"
            end
        end
    end
end)

-- Auto-cleanup
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        _G.isLoopRunning = false
    end
end)

print("YANZ HUB | V0.1.4 [BETA] Loaded Successfully with Nothing UI Library (Fixed Version)!")
print("Features: Auto Click Toggle, Position Set, Speed Control, Real-Time Position Tracking, Emergency Stop (F6)")
print("Toggle GUI with RightShift!")

return Window
