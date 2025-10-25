local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Positions
local spawnPos = Vector3.new(-36.94, 71.09, -17.08)
local entrancePos = Vector3.new(-37.22, 175.62, 2062.80)
local endPos = Vector3.new(-37.36, 179.46, 2243.46)

local autoFarmEnabled = false
local speedEnabled = false
local connection, speedConnection, warningConnection

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "YANZHub"
screenGui.Parent = playerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = screenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
mainFrame.Size = UDim2.new(0, 300, 0, 200)
mainFrame.Active = true
mainFrame.Draggable = true

-- Add shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Parent = mainFrame
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://131604521"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.6
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.ZIndex = -1

-- Corner rounding
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Parent = mainFrame
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.new(0, 0, 0, 10)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "YANZ Hub"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Minimize button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Parent = mainFrame
minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
minimizeButton.Position = UDim2.new(1, -40, 0, 10)
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Font = Enum.Font.Gotham
minimizeButton.Text = "-"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextScaled = true
corner:Clone().Parent = minimizeButton

-- Auto Farm Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Parent = mainFrame
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 60)
toggleButton.Size = UDim2.new(0, 260, 0, 50)
toggleButton.Font = Enum.Font.Gotham
toggleButton.Text = "Auto Farm Wins [OFF]"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
corner:Clone().Parent = toggleButton

-- Speed Booster Button
local speedButton = Instance.new("TextButton")
speedButton.Name = "SpeedButton"
speedButton.Parent = mainFrame
speedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedButton.Position = UDim2.new(0, 20, 0, 120)
speedButton.Size = UDim2.new(0, 260, 0, 50)
speedButton.Font = Enum.Font.Gotham
speedButton.Text = "Speed Booster [OFF]"
speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
speedButton.TextScaled = true
corner:Clone().Parent = speedButton

-- Hover effect for buttons
local function addHoverEffect(button)
    local originalColor = button.BackgroundColor3
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(originalColor.R * 255 + 20, originalColor.G * 255 + 20, originalColor.B * 255 + 20)}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = originalColor}):Play()
    end)
end

addHoverEffect(toggleButton)
addHoverEffect(speedButton)
addHoverEffect(minimizeButton)

-- Minimize functionality
local minimized = false
minimizeButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        mainFrame:TweenSize(UDim2.new(0, 300, 0, 50), "Out", "Quad", 0.3, true)
        minimizeButton.Text = "+"
        toggleButton.Visible = false
        speedButton.Visible = false
    else
        mainFrame:TweenSize(UDim2.new(0, 300, 0, 200), "Out", "Quad", 0.3, true)
        minimizeButton.Text = "-"
        toggleButton.Visible = true
        speedButton.Visible = true
    end
end)

-- Toggle GUI visibility with keybind (e.g., 'T')
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.T then
        screenGui.Enabled = not screenGui.Enabled
    end
end)

-- Helper Functions
local function getCharacter()
    return player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function teleportTo(pos)
    local humanoidRootPart = getCharacter() and getCharacter():FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        humanoidRootPart.CFrame = CFrame.new(pos)
    end
end

-- Speed Booster Loop
local function startSpeedBooster()
    if speedConnection then
        speedConnection:Disconnect()
        speedConnection = nil
    end
    speedConnection = RunService.Heartbeat:Connect(function()
        if not speedEnabled then
            if speedConnection then
                speedConnection:Disconnect()
                speedConnection = nil
            end
            return
        end
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 50
        end
    end)
end

-- Auto Farm Loop (includes Noclip, God Mode, Anti-Shake)
local function startAutoFarm()
    if connection then
        connection:Disconnect()
        connection = nil
    end
    connection = RunService.Heartbeat:Connect(function()
        if not autoFarmEnabled then
            if connection then
                connection:Disconnect()
                connection = nil
            end
            return
        end
        
        local char = getCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            wait(1)
            return
        end
        
        -- Noclip
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        
        -- God Mode
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.MaxHealth = math.huge
            humanoid.Health = math.huge
        end
        
        local camera = workspace.CurrentCamera
        if camera then
            local cf = camera.CFrame
            camera.CFrame = cf:Lerp(cf, 0.95)
        end
        
        -- Teleport sequence
        teleportTo(spawnPos)
        wait(2)
        teleportTo(entrancePos)
        wait(2)
        teleportTo(endPos)
        wait(5)
    end)
end

-- Warning Detection
local function startWarningDetection()
    if warningConnection then
        warningConnection:Disconnect()
    end
    warningConnection = RunService.Heartbeat:Connect(function()
        local rock = workspace:FindFirstChild("Rock") or workspace:FindFirstChild("GiantRock")
        if rock and not autoFarmEnabled then
            autoFarmEnabled = true
            toggleButton.Text = "Auto Farm Wins [ON]"
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            startAutoFarm()
        end
    end)
end

-- Toggle Auto Farm
toggleButton.MouseButton1Click:Connect(function()
    autoFarmEnabled = not autoFarmEnabled
    toggleButton.Text = autoFarmEnabled and "Auto Farm Wins [ON]" or "Auto Farm Wins [OFF]"
    toggleButton.BackgroundColor3 = autoFarmEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 50, 50)
    
    if autoFarmEnabled then
        startAutoFarm()
    else
        if connection then
            connection:Disconnect()
            connection = nil
        end
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.MaxHealth = 100
            humanoid.Health = 100
        end
        local char = getCharacter()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end)

-- Toggle Speed Booster
speedButton.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedButton.Text = speedEnabled and "Speed Booster [ON]" or "Speed Booster [OFF]"
    speedButton.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(50, 50, 50)
    
    if speedEnabled then
        startSpeedBooster()
    else
        if speedConnection then
            speedConnection:Disconnect()
            speedConnection = nil
        end
        local humanoid = getHumanoid()
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end)

player.CharacterAdded:Connect(function()
    wait(1)
    if autoFarmEnabled then
        startAutoFarm()
    end
    if speedEnabled then
        startSpeedBooster()
    end
end)

startWarningDetection()

print("YANZ Hub loaded")
