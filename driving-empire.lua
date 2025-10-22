local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local AutoFarm = false
local AutoFarmRunning = false
local TouchTheRoad = false
local AntiAFK = true
local TeleportSpeed = 600
local FarmDelay = 0.1 -- New: Adjustable delay between farm cycles
local LastNotif = 0
local PauseFarm = false
local StartPosition = CFrame.new(Vector3.new(4940.19775, 66.0195084, -1933.99927, 0.343969434, -0.00796990748, -0.938947022, 0.00281227613, 0.999968231, -0.00745762791, 0.938976645, -7.53822824e-05, 0.343980938))
local EndPosition = CFrame.new(Vector3.new(1827.3407, 66.0150146, -658.946655, -0.366112858, 0.00818905979, 0.930534422, 0.00240773871, 0.999966264, -0.00785277691, -0.930567324, -0.000634518801, -0.366120219))

-- Utility Functions
local function GetCurrentVehicle()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.SeatPart then
        local vehicle = LocalPlayer.Character.Humanoid.SeatPart.Parent
        if vehicle and vehicle:FindFirstChild("PrimaryPart") then
            return vehicle
        end
    end
    return nil
end

local function GetRoadHeight(pos)
    local rayOrigin = pos + Vector3.new(0, 50, 0)
    local rayDirection = Vector3.new(0, -100, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, GetCurrentVehicle()}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    local result = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return result and result.Position.Y + 2 or pos.Y -- Add slight offset to avoid clipping
end

local function TP(cframe)
    local vehicle = GetCurrentVehicle()
    if not (vehicle and vehicle.PrimaryPart) then
        Notify("No vehicle found! Please enter a vehicle.", 3)
        return false
    end
    local targetPos = cframe.Position
    if TouchTheRoad then
        targetPos = Vector3.new(targetPos.X, GetRoadHeight(targetPos), targetPos.Z)
    end
    vehicle:SetPrimaryPartCFrame(CFrame.new(targetPos) * cframe.Rotation)
    return true
end

local function VelocityTP(cframe)
    local vehicle = GetCurrentVehicle()
    if not (vehicle and vehicle.PrimaryPart) then
        Notify("No vehicle found! Please enter a vehicle.", 3)
        return false
    end
    
    local targetPos = cframe.Position
    if TouchTheRoad then
        targetPos = Vector3.new(targetPos.X, GetRoadHeight(targetPos), targetPos.Z)
    end
    
    local BodyGyro = Instance.new("BodyGyro")
    BodyGyro.P = 5000
    BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    BodyGyro.CFrame = vehicle.PrimaryPart.CFrame
    BodyGyro.Parent = vehicle.PrimaryPart

    local BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    BodyVelocity.Velocity = CFrame.new(vehicle.PrimaryPart.Position, targetPos).LookVector * TeleportSpeed
    BodyVelocity.Parent = vehicle.PrimaryPart

    local distance = (vehicle.PrimaryPart.Position - targetPos).Magnitude
    local travelTime = distance / TeleportSpeed
    local startTime = tick()
    
    while tick() - startTime < travelTime and AutoFarm and not PauseFarm do
        if not vehicle or not vehicle.Parent then
            Notify("Vehicle lost! Stopping teleport.", 3)
            BodyVelocity:Destroy()
            BodyGyro:Destroy()
            return false
        end
        RunService.Heartbeat:Wait()
    end
    
    BodyVelocity.Velocity = Vector3.new(0, 0, 0)
    task.wait(0.1)
    BodyVelocity:Destroy()
    BodyGyro:Destroy()
    return true
end

local function Notify(message, duration)
    if tick() - LastNotif < 2 then return end
    LastNotif = tick()
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 70)
    frame.Position = UDim2.new(0.5, -150, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.2
    frame.Parent = screenGui
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 1, -20)
    text.Position = UDim2.new(0, 10, 0, 10)
    text.BackgroundTransparency = 1
    text.Text = message
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextScaled = true
    text.Font = Enum.Font.GothamBold
    text.TextWrapped = true
    text.Parent = frame
    
    Debris:AddItem(screenGui, duration or 3)
end

-- AutoFarm Coroutine
local AutoFarmFunc = coroutine.create(function()
    while true do
        if not AutoFarm or PauseFarm or not LocalPlayer.Character then
            AutoFarmRunning = false
            coroutine.yield()
        end
        AutoFarmRunning = true
        local success, err = pcall(function()
            local vehicle = GetCurrentVehicle()
            if not vehicle then
                Notify("Please enter a vehicle to start farming!", 3)
                return
            end
            if TP(StartPosition) then
                task.wait(FarmDelay)
                if VelocityTP(EndPosition) then
                    task.wait(FarmDelay)
                    if TP(EndPosition) then
                        task.wait(FarmDelay)
                        VelocityTP(StartPosition)
                    end
                end
            end
        end)
        if not success then
            warn("AutoFarm Error: " .. tostring(err))
            Notify("AutoFarm Error: Check console for details!", 3)
        end
        task.wait(FarmDelay)
    end
end)

-- Anti-AFK System
LocalPlayer.Idled:Connect(function()
    if AntiAFK then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(math.random(0, Camera.ViewportSize.X), math.random(0, Camera.ViewportSize.Y)), Camera.CFrame)
        VirtualUser:SetKeyDown("w")
        task.wait(math.random(0.05, 0.15))
        VirtualUser:SetKeyUp("w")
    end
end)

-- GUI (Using a modern UI library)
local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Main.lua"))()
local Interface = Fluent:CreateInterface("Yanzz Hub", {
    Title = "Yanzz Hub - Driving Empire",
    SubTitle = "Advanced Auto Farm",
    Theme = "Dark",
    Keybind = Enum.KeyCode.RightControl
})

local AutoFarmTab = Interface:CreateTab("Auto Farm", "rbxassetid://6023426915")
AutoFarmTab:CreateSection("Auto Farm Controls")

local StatusLabel = AutoFarmTab:CreateLabel("Status: Idle")

AutoFarmTab:CreateToggle({
    Name = "Auto Farm",
    Description = "Enable auto farming (enter vehicle to start)",
    Default = false,
    Callback = function(value)
        AutoFarm = value
        StatusLabel:SetText(AutoFarm and "Status: Running" or "Status: Idle")
        if value and not AutoFarmRunning then
            coroutine.resume(AutoFarmFunc)
        end
    end
})

AutoFarmTab:CreateToggle({
    Name = "Pause Farm",
    Description = "Pause auto farming without disabling",
    Default = false,
    Callback = function(value)
        PauseFarm = value
        StatusLabel:SetText(PauseFarm and "Status: Paused" or (AutoFarm and "Status: Running" or "Status: Idle"))
    end
})

AutoFarmTab:CreateToggle({
    Name = "Touch The Road",
    Description = "Adjusts vehicle to road height",
    Default = false,
    Callback = function(value)
        TouchTheRoad = value
    end
})

AutoFarmTab:CreateToggle({
    Name = "Anti-AFK",
    Description = "Simulates input to prevent AFK kick",
    Default = true,
    Callback = function(value)
        AntiAFK = value
    end
})

AutoFarmTab:CreateSlider({
    Name = "Teleport Speed",
    Description = "Adjust velocity teleport speed",
    Min = 100,
    Max = 1000,
    Default = 600,
    Callback = function(value)
        TeleportSpeed = value
    end
})

AutoFarmTab:CreateSlider({
    Name = "Farm Delay",
    Description = "Delay between farm cycles (seconds)",
    Min = 0,
    Max = 1,
    Default = 0.1,
    Increment = 0.05,
    Callback = function(value)
        FarmDelay = value
    end
})

AutoFarmTab:CreateButton({
    Name = "Set Start Position",
    Description = "Save current position as Start",
    Callback = function()
        local vehicle = GetCurrentVehicle()
        if vehicle and vehicle.PrimaryPart then
            StartPosition = vehicle.PrimaryPart.CFrame
            Notify("Start Position saved!", 3)
        else
            Notify("Please enter a vehicle to save position!", 3)
        end
    end
})

AutoFarmTab:CreateButton({
    Name = "Set End Position",
    Description = "Save current position as End",
    Callback = function()
        local vehicle = GetCurrentVehicle()
        if vehicle and vehicle.PrimaryPart then
            EndPosition = vehicle.PrimaryPart.CFrame
            Notify("End Position saved!", 3)
        else
            Notify("Please enter a vehicle to save position!", 3)
        end
    end
})

AutoFarmTab:CreateButton({
    Name = "Reset Positions",
    Description = "Reset to default Start/End positions",
    Callback = function()
        StartPosition = CFrame.new(Vector3.new(4940.19775, 66.0195084, -1933.99927, 0.343969434, -0.00796990748, -0.938947022, 0.00281227613, 0.999968231, -0.00745762791, 0.938976645, -7.53822824e-05, 0.343980938))
        EndPosition = CFrame.new(Vector3.new(1827.3407, 66.0150146, -658.946655, -0.366112858, 0.00818905979, 0.930534422, 0.00240773871, 0.999966264, -0.00785277691, -0.930567324, -0.000634518801, -0.366120219))
        Notify("Positions reset to default!", 3)
    end
})

-- Initial Notification
Notify("Yanzz Hub v2.0 loaded successfully!", 3)
