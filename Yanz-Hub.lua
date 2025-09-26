local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Safety check for LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- Wait for character and humanoidRootPart
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

-- Load Nothing UI Library (corrected URL without /refs/heads/)
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

-- Controls Section (Left)
local ControlsSection = Tab:NewSection({
    Title = "Controls",
    Icon = "rbxassetid://7733916988",
    Position = "Left"
})

-- Display Section (Right)
local DisplaySection = Tab:NewSection({
    Title = "Display",
    Icon = "rbxassetid://7733916988",
    Position = "Right"
})

-- Settings Section (Left, below Controls)
local SettingsSection = Tab:NewSection({
    Title = "Speed Settings",
    Icon = "rbxassetid://7743869054",
    Position = "Left"
})

-- Global Variables
_G.clickDelay = _G.clickDelay or 1  -- Default to NORMAL
_G.autoClickPos = _G.autoClickPos or {X = nil, Y = nil}
_G.isLoopRunning = false
local loopConnection = nil  -- To manage the loop

-- Speed Options for Dropdown
local speedOptions = {
    ["ULTRA FAST (0.01s)"] = 0.01,
    ["FAST (0.6s)"] = 0.6,
    ["NORMAL (1s)"] = 1,
    ["SLOW (1.5s)"] = 1.5
}
local speedLabels = {"ULTRA FAST (0.01s)", "FAST (0.6s)", "NORMAL (1s)", "SLOW (1.5s)"}

-- Labels for Status and Position (assuming NewLabel exists and returns object with :Set method)
local StatusLabel = DisplaySection:NewLabel("Status: Ready")
local PositionLabel = DisplaySection:NewLabel("Position: X: 0, Y: 0, Z: 0")

-- Main Auto Click Toggle
ControlsSection:NewToggle({
    Title = "Auto Click",
    Default = false,
    Callback = function(value)
        _G.isLoopRunning = value
        if value then
            StatusLabel:Set("Auto Clicking Active")
            NothingLibrary.Notification().new({
                Title = "Started",
                Description = "Auto Clicker is now running!",
                Duration = 2,
                Icon = "rbxassetid://4483345998"
            })
            StartClickLoop()
        else
            StopClickLoop()
            StatusLabel:Set("Auto Clicking Stopped")
            NothingLibrary.Notification().new({
                Title = "Stopped",
                Description = "Auto Clicker has been stopped.",
                Duration = 2,
                Icon = "rbxassetid://4483345998"
            })
        end
    end
})

-- Set Position Button
ControlsSection:NewButton({
    Title = "Set Click Position",
    Callback = function()
        StatusLabel:Set("🖱️ Click anywhere to set position... (10s timeout)")
        NothingLibrary.Notification().new({
            Title = "Setting Position",
            Description = "Click on screen to set auto-click position.",
            Duration = 3,
            Icon = "rbxassetid://4483345998"
        })
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                _G.autoClickPos = {
                    X = input.Position.X,
                    Y = input.Position.Y
                }
                StatusLabel:Set("✅ Position set: " .. math.floor(_G.autoClickPos.X) .. ", " .. math.floor(_G.autoClickPos.Y))
                NothingLibrary.Notification().new({
                    Title = "Position Set",
                    Description = "Auto-click will now target: " .. math.floor(_G.autoClickPos.X) .. ", " .. math.floor(_G.autoClickPos.Y),
                    Duration = 3,
                    Icon = "rbxassetid://4483345998"
                })
                if connection then
                    connection:Disconnect()
                end
            end
        end)
        
        -- Timeout after 10 seconds
        game:GetService("Debris"):AddItem(connection, 10)  -- Better than delay for cleanup
        spawn(function()
            wait(10)
            if connection and connection.Connected then
                connection:Disconnect()
                if StatusLabel:Get():find("Click anywhere") then  -- Assuming :Get() exists, or check text somehow; fallback
                    StatusLabel:Set("❌ Position set cancelled")
                    NothingLibrary.Notification().new({
                        Title = "Cancelled",
                        Description = "Position setting timed out.",
                        Duration = 2,
                        Icon = "rbxassetid://4483345998"
                    })
                    wait(2)
                    StatusLabel:Set("Status: Ready")
                end
            end
        end)
    end
})

-- Speed Dropdown
SettingsSection:NewDropdown({
    Title = "Click Delay",
    Data = speedLabels,
    Default = "NORMAL (1s)",
    Callback = function(selected)
        _G.clickDelay = speedOptions[selected]
        StatusLabel:Set("Delay: " .. selected)
        NothingLibrary.Notification().new({
            Title = "Speed Updated",
            Description = "Click delay set to " .. selected,
            Duration = 2,
            Icon = "rbxassetid://4483345998"
        })
        -- If running, restart loop with new delay
        if _G.isLoopRunning then
            StopClickLoop()
            StartClickLoop()
        end
    end
})

-- Real-Time Position Update
local posConnection
if humanoidRootPart then
    posConnection = RunService.RenderStepped:Connect(function()
        local pos = humanoidRootPart.Position
        PositionLabel:Set(string.format("Position: X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z))
    end)
else
    PositionLabel:Set("Position: Waiting for character...")
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart", 10)
        if humanoidRootPart and posConnection then
            posConnection:Disconnect()
            posConnection = RunService.RenderStepped:Connect(function()
                local pos = humanoidRootPart.Position
                PositionLabel:Set(string.format("Position: X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z))
            end)
        end
    end)
end

-- Safe Click Function (unchanged)
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then 
        NothingLibrary.Notification().new({
            Title = "Error",
            Description = "Invalid position provided.",
            Duration = 2
        })
        return 
    end
    
    local viewportSize = workspace.CurrentCamera.ViewportSize
    if pos.X < 0 or pos.Y < 0 or pos.X > viewportSize.X or pos.Y > viewportSize.Y then
        warn("⚠️ Invalid click position")
        NothingLibrary.Notification().new({
            Title = "Warning",
            Description = "Click position out of screen bounds.",
            Duration = 2
        })
        return
    end
    
    local success, errorMsg = pcall(function()
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
    end)
    
    if not success then
        warn("❌ Click error: " .. tostring(errorMsg))
        NothingLibrary.Notification().new({
            Title = "Click Error",
            Description = tostring(errorMsg),
            Duration = 3
        })
    end
end

-- Click Loop Function
local function ClickLoop()
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

-- Start Loop
function StartClickLoop()
    if loopConnection then loopConnection:Disconnect() end
    loopConnection = RunService.Heartbeat:Connect(function()
        if _G.isLoopRunning then
            ClickLoop()
            wait(_G.clickDelay)
        end
    end)
end

-- Stop Loop
function StopClickLoop()
    if loopConnection then
        loopConnection:Disconnect()
        loopConnection = nil
    end
end

-- Emergency Stop Toggle (F6) - Updates toggle state assuming toggle object is accessible; here we simulate by toggling flag and notifying
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.isLoopRunning = not _G.isLoopRunning
        if _G.isLoopRunning then
            StatusLabel:Set("Auto Clicking Active (F6)")
            NothingLibrary.Notification().new({
                Title = "Resumed",
                Description = "Auto Clicker resumed via F6.",
                Duration = 2
            })
            StartClickLoop()
        else
            StopClickLoop()
            StatusLabel:Set("Emergency Stopped (F6)")
            NothingLibrary.Notification().new({
                Title = "Emergency Stop",
                Description = "Auto Clicker stopped via F6.",
                Duration = 2
            })
            wait(2)
            StatusLabel:Set("Status: Ready")
        end
        -- Note: To sync with UI toggle, you would need to reference the toggle object and call :Set(_G.isLoopRunning)
        -- For now, it toggles the flag and loop independently
    end
end)

-- Auto-cleanup on player leaving
Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        StopClickLoop()
        if posConnection then posConnection:Disconnect() end
    end
end)

-- Initial Notification
NothingLibrary.Notification().new({
    Title = "YANZ HUB Loaded",
    Description = "V0.1.4 [BETA] - Use RightShift to toggle GUI. F6 for emergency stop.",
    Duration = 4,
    Icon = "rbxassetid://4483345998"
})

print("YANZ HUB | V0.1.4 [BETA] Loaded Successfully")
print("Features: Cyber UI, Auto Click Toggle, Position Set, Speed Dropdown, Real-Time Position Tracking, Emergency Stop (F6)")
print("Toggle GUI with RightShift!")

-- Return the Window for potential external access
return Window
