local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Enhanced safety check for LocalPlayer with error handling
if not LocalPlayer then
    local playerAddedSuccess, playerAddedError = pcall(function()
        LocalPlayer = Players.PlayerAdded:Wait()
    end)
    if not playerAddedSuccess then
        error("Failed to get LocalPlayer: " .. tostring(playerAddedError))
        return
    end
end

-- Wait for character with enhanced error handling
local character
local humanoidRootPart

local characterSuccess, characterError = pcall(function()
    character = LocalPlayer.Character
    if not character then
        character = LocalPlayer.CharacterAdded:Wait()
    end
    humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
end)

if not characterSuccess then
    warn("Character initialization warning: " .. tostring(characterError))
    -- Continue execution but set up character monitoring
end

-- Load Nothing UI Library with enhanced error handling and fallback
local NothingLibrary
local libraryLoadSuccess, libraryLoadError = pcall(function()
    NothingLibrary = loadstring(game:HttpGetAsync('https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'))()
end)

if not libraryLoadSuccess then
    warn("Failed to load Nothing UI Library: " .. tostring(libraryLoadError))
    -- Create a simple fallback UI system
    NothingLibrary = {
        new = function(self, config)
            return {
                NewTab = function(self, tabConfig)
                    return {
                        NewSection = function(self, sectionConfig)
                            return {
                                NewLabel = function(self, text)
                                    local label = {text = text}
                                    function label:Set(newText)
                                        label.text = newText
                                        print("Label updated:", newText)
                                    end
                                    function label:Get()
                                        return label.text
                                    end
                                    return label
                                end,
                                NewToggle = function(self, toggleConfig)
                                    print("Toggle created:", toggleConfig.Title)
                                    return {}
                                end,
                                NewButton = function(self, buttonConfig)
                                    print("Button created:", buttonConfig.Title)
                                    return {}
                                end,
                                NewDropdown = function(self, dropdownConfig)
                                    print("Dropdown created:", dropdownConfig.Title)
                                    return {}
                                end
                            }
                        end
                    }
                end,
                Notification = function(self)
                    return {
                        new = function(self, notifConfig)
                            print("Notification:", notifConfig.Title, "-", notifConfig.Description)
                        end
                    }
                end
            }
        end
    }
end

-- Create Window with error handling
local Window
local windowSuccess, windowError = pcall(function()
    Window = NothingLibrary:new({
        Title = "YANZ HUB | V0.1.5 [STABLE]",
        Description = "Advanced Auto Clicker with Enhanced Cyber UI",
        Keybind = Enum.KeyCode.RightShift,
        Logo = 'http://www.roblox.com/asset/?id=125456335927282'
    })
end)

if not windowSuccess then
    error("Failed to create window: " .. tostring(windowError))
    return
end

-- Create Tab with error handling
local Tab
local tabSuccess, tabError = pcall(function()
    Tab = Window:NewTab({
        Title = "Auto Clicker",
        Description = "Enhanced Auto Click Features with Bug Fixes",
        Icon = "rbxassetid://7733960981"
    })
end)

if not tabSuccess then
    error("Failed to create tab: " .. tostring(tabError))
    return
end

-- Create Sections with proper error handling
local ControlsSection, DisplaySection, SettingsSection

local sectionsSuccess, sectionsError = pcall(function()
    -- Controls Section (Left)
    ControlsSection = Tab:NewSection({
        Title = "Controls",
        Icon = "rbxassetid://7733916988",
        Position = "Left"
    })

    -- Display Section (Right)
    DisplaySection = Tab:NewSection({
        Title = "Display",
        Icon = "rbxassetid://7733916988",
        Position = "Right"
    })

    -- Settings Section (Left, below Controls)
    SettingsSection = Tab:NewSection({
        Title = "Speed Settings",
        Icon = "rbxassetid://7743869054",
        Position = "Left"
    })
end)

if not sectionsSuccess then
    error("Failed to create sections: " .. tostring(sectionsError))
    return
end

-- Enhanced Global Variables with type safety
_G.clickDelay = _G.clickDelay or 1  -- Default to NORMAL
_G.autoClickPos = _G.autoClickPos or {X = nil, Y = nil}
_G.isLoopRunning = _G.isLoopRunning or false
_G.emergencyStop = _G.emergencyStop or false

-- Enhanced loop management
local loopConnection = nil
local positionUpdateConnection = nil
local inputConnections = {}

-- Enhanced Speed Options with validation
local speedOptions = {
    ["ULTRA FAST (0.01s)"] = 0.01,
    ["FAST (0.6s)"] = 0.6,
    ["NORMAL (1s)"] = 1,
    ["SLOW (1.5s)"] = 1.5,
    ["VERY SLOW (3s)"] = 3
}

local speedLabels = {"ULTRA FAST (0.01s)", "FAST (0.6s)", "NORMAL (1s)", "SLOW (1.5s)", "VERY SLOW (3s)"}

-- Enhanced UI Elements with error handling
local StatusLabel, PositionLabel, ClickCounterLabel

local labelsSuccess, labelsError = pcall(function()
    StatusLabel = DisplaySection:NewLabel("Status: Ready")
    PositionLabel = DisplaySection:NewLabel("Position: X: 0, Y: 0, Z: 0")
    ClickCounterLabel = DisplaySection:NewLabel("Clicks: 0")
end)

if not labelsSuccess then
    warn("Failed to create labels: " .. tostring(labelsError))
    -- Create fallback labels
    StatusLabel = {Set = function(self, text) print("Status:", text) end}
    PositionLabel = {Set = function(self, text) print("Position:", text) end}
    ClickCounterLabel = {Set = function(self, text) print("Clicks:", text) end}
end

-- Enhanced click counter
local clickCount = 0
local lastClickTime = 0
local clicksPerSecond = 0

-- Enhanced Auto Click Toggle with better state management
local autoClickToggle
local toggleSuccess, toggleError = pcall(function()
    autoClickToggle = ControlsSection:NewToggle({
        Title = "Auto Click",
        Default = false,
        Callback = function(value)
            if _G.emergencyStop and value then
                NothingLibrary.Notification().new({
                    Title = "Emergency Stop Active",
                    Description = "Press F6 to resume auto clicking",
                    Duration = 3,
                    Icon = "rbxassetid://4483345998"
                })
                return
            end
            
            _G.isLoopRunning = value
            if value then
                StatusLabel:Set("🟢 Auto Clicking Active")
                NothingLibrary.Notification().new({
                    Title = "Started",
                    Description = "Auto Clicker is now running!",
                    Duration = 2,
                    Icon = "rbxassetid://4483345998"
                })
                StartClickLoop()
            else
                StopClickLoop()
                StatusLabel:Set("🔴 Auto Clicking Stopped")
                NothingLibrary.Notification().new({
                    Title = "Stopped",
                    Description = "Auto Clicker has been stopped.",
                    Duration = 2,
                    Icon = "rbxassetid://4483345998"
                })
            end
        end
    })
end)

if not toggleSuccess then
    warn("Failed to create toggle: " .. tostring(toggleError))
end

-- Enhanced Set Position Button with timeout improvements
local setPositionSuccess, setPositionError = pcall(function()
    ControlsSection:NewButton({
        Title = "Set Click Position",
        Callback = function()
            if _G.isLoopRunning then
                NothingLibrary.Notification().new({
                    Title = "Warning",
                    Description = "Stop auto clicking before setting position",
                    Duration = 3,
                    Icon = "rbxassetid://4483345998"
                })
                return
            end
            
            StatusLabel:Set("🖱️ Click anywhere to set position... (10s timeout)")
            NothingLibrary.Notification().new({
                Title = "Setting Position",
                Description = "Click on screen to set auto-click position.",
                Duration = 3,
                Icon = "rbxassetid://4483345998"
            })
            
            local connection
            local timeoutConnection
            local cleanupCalled = false
            
            local function cleanup()
                if cleanupCalled then return end
                cleanupCalled = true
                if connection then connection:Disconnect() end
                if timeoutConnection then timeoutConnection:Disconnect() end
            end
            
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
                    cleanup()
                end
            end)
            
            -- Enhanced timeout handling
            timeoutConnection = game:GetService("Debris"):AddItem(connection, 10)
            
            task.spawn(function()
                task.wait(10)
                if not cleanupCalled then
                    cleanup()
                    StatusLabel:Set("❌ Position set cancelled")
                    NothingLibrary.Notification().new({
                        Title = "Cancelled",
                        Description = "Position setting timed out.",
                        Duration = 2,
                        Icon = "rbxassetid://4483345998"
                    })
                    task.wait(2)
                    StatusLabel:Set("Status: Ready")
                end
            end)
        end
    })
end)

if not setPositionSuccess then
    warn("Failed to create set position button: " .. tostring(setPositionError))
end

-- Enhanced Speed Dropdown with validation
local dropdownSuccess, dropdownError = pcall(function()
    SettingsSection:NewDropdown({
        Title = "Click Delay",
        Data = speedLabels,
        Default = "NORMAL (1s)",
        Callback = function(selected)
            if not speedOptions[selected] then
                warn("Invalid speed option selected: " .. tostring(selected))
                return
            end
            
            _G.clickDelay = speedOptions[selected]
            StatusLabel:Set("⏱️ Delay: " .. selected)
            NothingLibrary.Notification().new({
                Title = "Speed Updated",
                Description = "Click delay set to " .. selected,
                Duration = 2,
                Icon = "rbxassetid://4483345998"
            })
            
            -- Enhanced loop restart with state preservation
            if _G.isLoopRunning then
                local wasRunning = _G.isLoopRunning
                StopClickLoop()
                if wasRunning then
                    StartClickLoop()
                end
            end
        end
    })
end)

if not dropdownSuccess then
    warn("Failed to create dropdown: " .. tostring(dropdownError))
end

-- Enhanced Real-Time Position Update with character monitoring
local function SetupPositionUpdates()
    if positionUpdateConnection then
        positionUpdateConnection:Disconnect()
    end
    
    local function updatePosition()
        if humanoidRootPart and humanoidRootPart.Parent then
            local pos = humanoidRootPart.Position
            PositionLabel:Set(string.format("📍 Position: X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z))
        else
            PositionLabel:Set("📍 Position: Character not available")
        end
    end
    
    positionUpdateConnection = RunService.RenderStepped:Connect(updatePosition)
    
    -- Monitor for character changes
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        local success, err = pcall(function()
            humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart", 10)
            if humanoidRootPart then
                updatePosition()
            end
        end)
        if not success then
            warn("Character added handler error: " .. tostring(err))
        end
    end)
    
    LocalPlayer.CharacterRemoving:Connect(function()
        PositionLabel:Set("📍 Position: Character removed")
    end)
end

-- Setup position updates
SetupPositionUpdates()

-- Enhanced Safe Click Function with comprehensive error handling
local function SafeClick(pos)
    if not pos or type(pos) ~= "table" or not pos.X or not pos.Y then 
        NothingLibrary.Notification().new({
            Title = "Error",
            Description = "Invalid position provided for clicking.",
            Duration = 2
        })
        return false
    end
    
    -- Validate position values
    if type(pos.X) ~= "number" or type(pos.Y) ~= "number" then
        warn("Invalid position coordinates: X=" .. tostring(pos.X) .. ", Y=" .. tostring(pos.Y))
        return false
    end
    
    local viewportSize
    local cameraSuccess, cameraError = pcall(function()
        viewportSize = workspace.CurrentCamera.ViewportSize
    end)
    
    if not cameraSuccess then
        warn("Failed to get camera viewport: " .. tostring(cameraError))
        return false
    end
    
    -- Enhanced bounds checking
    if pos.X < 0 or pos.Y < 0 or pos.X > viewportSize.X or pos.Y > viewportSize.Y then
        warn("⚠️ Click position out of bounds: " .. tostring(pos.X) .. ", " .. tostring(pos.Y))
        NothingLibrary.Notification().new({
            Title = "Warning",
            Description = "Click position is outside screen bounds.",
            Duration = 2
        })
        return false
    end
    
    local success, errorMsg = pcall(function()
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
    end)
    
    if success then
        -- Update click statistics
        clickCount = clickCount + 1
        local currentTime = tick()
        clicksPerSecond = 1 / (currentTime - lastClickTime)
        lastClickTime = currentTime
        
        ClickCounterLabel:Set(string.format("🖱️ Clicks: %d | CPS: %.1f", clickCount, clicksPerSecond))
        return true
    else
        warn("❌ Click error: " .. tostring(errorMsg))
        NothingLibrary.Notification().new({
            Title = "Click Error",
            Description = tostring(errorMsg),
            Duration = 3
        })
        return false
    end
end

-- Enhanced Click Loop Function with state validation
local function ClickLoop()
    if not _G.isLoopRunning or _G.emergencyStop then
        return
    end
    
    if _G.autoClickPos and _G.autoClickPos.X and _G.autoClickPos.Y then
        SafeClick(_G.autoClickPos)
    else
        local viewportSize
        local cameraSuccess = pcall(function()
            viewportSize = workspace.CurrentCamera.ViewportSize
        end)
        
        if cameraSuccess and viewportSize then
            local centerPos = {
                X = viewportSize.X / 2,
                Y = viewportSize.Y / 2
            }
            SafeClick(centerPos)
        else
            warn("Failed to get viewport size for center click")
        end
    end
end

-- Enhanced Start Loop with connection management
function StartClickLoop()
    StopClickLoop() -- Ensure any existing loop is stopped
    
    if _G.emergencyStop then
        NothingLibrary.Notification().new({
            Title = "Emergency Stop Active",
            Description = "Press F6 to resume",
            Duration = 2
        })
        return
    end
    
    local loopSuccess, loopError = pcall(function()
        loopConnection = RunService.Heartbeat:Connect(function()
            if _G.isLoopRunning and not _G.emergencyStop then
                ClickLoop()
                -- Use task.wait for better performance
                task.wait(_G.clickDelay)
            end
        end)
    end)
    
    if not loopSuccess then
        warn("Failed to start click loop: " .. tostring(loopError))
        StatusLabel:Set("❌ Failed to start click loop")
    end
end

-- Enhanced Stop Loop with proper cleanup
function StopClickLoop()
    if loopConnection then
        local success, errorMsg = pcall(function()
            loopConnection:Disconnect()
        end)
        if not success then
            warn("Error disconnecting loop: " .. tostring(errorMsg))
        end
        loopConnection = nil
    end
end

-- Enhanced Emergency Stop System with toggle state synchronization
local emergencyStopConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.emergencyStop = not _G.emergencyStop
        
        if _G.emergencyStop then
            StopClickLoop()
            StatusLabel:Set("🛑 Emergency Stopped (F6)")
            NothingLibrary.Notification().new({
                Title = "Emergency Stop",
                Description = "Auto Clicker stopped via F6.",
                Duration = 2
            })
            
            -- Sync UI toggle state
            if autoClickToggle and autoClickToggle.Set then
                pcall(function() autoClickToggle:Set(false) end)
            end
            _G.isLoopRunning = false
        else
            StatusLabel:Set("🔵 Ready to Resume")
            NothingLibrary.Notification().new({
                Title = "Emergency Stop Released",
                Description = "Press the Auto Click toggle to resume.",
                Duration = 2
            })
        end
    end
end)

table.insert(inputConnections, emergencyStopConnection)

-- Enhanced Auto-cleanup system
local cleanupFunction = function(player)
    if player == LocalPlayer then
        -- Cleanup all connections
        StopClickLoop()
        
        if positionUpdateConnection then
            positionUpdateConnection:Disconnect()
        end
        
        for _, connection in ipairs(inputConnections) do
            if connection then
                connection:Disconnect()
            end
        end
        
        -- Clear global variables
        _G.clickDelay = nil
        _G.autoClickPos = nil
        _G.isLoopRunning = nil
        _G.emergencyStop = nil
    end
end

local playerRemovingConnection = Players.PlayerRemoving:Connect(cleanupFunction)
table.insert(inputConnections, playerRemovingConnection)

-- Game close cleanup
game:BindToClose(function()
    cleanupFunction(LocalPlayer)
end)

-- Enhanced Initial Notification with version info
local notificationSuccess, notificationError = pcall(function()
    NothingLibrary.Notification().new({
        Title = "YANZ HUB Loaded Successfully",
        Description = "V0.1.5 [STABLE] - Enhanced with bug fixes and improvements\n• RightShift: Toggle GUI\n• F6: Emergency Stop\n• Improved error handling",
        Duration = 5,
        Icon = "rbxassetid://4483345998"
    })
end)

if not notificationSuccess then
    warn("Failed to show initial notification: " .. tostring(notificationError))
end

-- Enhanced logging
print("==========================================")
print("YANZ HUB | V0.1.5 [STABLE] Loaded Successfully")
print("==========================================")
print("Features:")
print("• Enhanced Cyber UI with error handling")
print("• Advanced Auto Click Toggle with state management")
print("• Position Setting with timeout protection")
print("• Speed Dropdown with validation")
print("• Real-Time Position Tracking with character monitoring")
print("• Emergency Stop System (F6) with UI sync")
print("• Click Statistics (Count & CPS)")
print("• Comprehensive error handling and fallbacks")
print("==========================================")
print("Toggle GUI with RightShift!")
print("Emergency Stop with F6!")

-- Return the Window for external access with error handling
local returnSuccess, returnError = pcall(function()
    return Window
end)

if not returnSuccess then
    warn("Failed to return window: " .. tostring(returnError))
    return {Version = "V0.1.5 [STABLE]",
            Status = "Loaded with minor issues"}
end
