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

-- Enhanced GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "REDZHubPro2025"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 350, 0, 250)
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.ClipsDescendants = true
MainFrame.BorderSizePixel = 0
MainFrame.Active = true

-- Glass Effect
local GlassEffect = Instance.new("Frame")
GlassEffect.Parent = MainFrame
GlassEffect.Size = UDim2.new(1, 0, 1, 0)
GlassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlassEffect.BackgroundTransparency = 0.95
GlassEffect.BorderSizePixel = 0
GlassEffect.ZIndex = 0

-- Rounded Corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16)
UICorner.Parent = MainFrame

-- Animated Neon Border
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(255, 0, 255)
UIStroke.Thickness = 2.5
UIStroke.Transparency = 0.2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.LineJoinMode = Enum.LineJoinMode.Round

-- Animated Border Effect
spawn(function()
    local colors = {
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0)
    }
    local currentIndex = 1
    
    while true do
        local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        TweenService:Create(UIStroke, tweenInfo, {Color = colors[currentIndex]}):Play()
        currentIndex = currentIndex % #colors + 1
        wait(2.1)
    end
end)

-- Header Section
local HeaderFrame = Instance.new("Frame")
HeaderFrame.Parent = MainFrame
HeaderFrame.Size = UDim2.new(1, 0, 0, 45)
HeaderFrame.Position = UDim2.new(0, 0, 0, 0)
HeaderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
HeaderFrame.BackgroundTransparency = 0.3
HeaderFrame.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 16)
HeaderCorner.Parent = HeaderFrame

-- Animated Title
local Title = Instance.new("TextLabel")
Title.Parent = HeaderFrame
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.Text = "YANZ HUB | V0.1.4 [BETA]"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.TextStrokeTransparency = 0.8
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Version Badge
local VersionBadge = Instance.new("TextLabel")
VersionBadge.Parent = HeaderFrame
VersionBadge.Size = UDim2.new(0.3, 0, 0.5, 0)
VersionBadge.Position = UDim2.new(0.65, 0, 0.25, 0)
VersionBadge.Font = Enum.Font.GothamMedium
VersionBadge.Text = "v3.0.3 ULTRA"
VersionBadge.TextColor3 = Color3.fromRGB(0, 255, 255)
VersionBadge.TextSize = 12
VersionBadge.BackgroundColor3 = Color3.fromRGB(0, 30, 40)
VersionBadge.BackgroundTransparency = 0.3
VersionBadge.BorderSizePixel = 0

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 8)
BadgeCorner.Parent = VersionBadge

-- Title Animation
spawn(function()
    local colors = {
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 100, 255)
    }
    local i = 1
    
    while true do
        local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        TweenService:Create(Title, tweenInfo, {TextColor3 = colors[i]}):Play()
        i = i % #colors + 1
        wait(1.5)
    end
end)

-- Control Buttons Factory
local function CreateControlButton(text, position, color, hoverColor)
    local button = Instance.new("TextButton")
    button.Parent = HeaderFrame
    button.Size = UDim2.new(0, 30, 0, 30)
    button.Position = position
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.BackgroundColor3 = color
    button.AutoButtonColor = false
    button.BorderSizePixel = 0
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button
    
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor, Size = UDim2.new(0, 32, 0, 32)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color, Size = UDim2.new(0, 30, 0, 30)}):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 100, 100)}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = hoverColor}):Play()
    end)
    
    return button
end

-- Control Buttons
local CloseButton = CreateControlButton("×", UDim2.new(0.9, 0, 0.15, 0), 
    Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 100, 100))

local MinButton = CreateControlButton("−", UDim2.new(0.8, 0, 0.15, 0), 
    Color3.fromRGB(255, 180, 60), Color3.fromRGB(255, 200, 100))

local SettingsBtn = CreateControlButton("⚙", UDim2.new(0.7, 0, 0.15, 0), 
    Color3.fromRGB(60, 150, 255), Color3.fromRGB(100, 180, 255))

-- Toggle Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = MainFrame
ToggleButton.Size = UDim2.new(0.8, 0, 0, 45)
ToggleButton.Position = UDim2.new(0.1, 0, 0.25, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "▶ START AUTO CLICK"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.AutoButtonColor = false
ToggleButton.BorderSizePixel = 0

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 12)
ToggleCorner.Parent = ToggleButton

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Parent = ToggleButton
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 1.5
ToggleStroke.Transparency = 0.3

-- Toggle Button Animations
ToggleButton.MouseEnter:Connect(function()
    TweenService:Create(ToggleButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(220, 80, 80),
        Size = UDim2.new(0.82, 0, 0, 47)
    }):Play()
end)

ToggleButton.MouseLeave:Connect(function()
    TweenService:Create(ToggleButton, TweenInfo.new(0.3), {
        BackgroundColor3 = Color3.fromRGB(200, 60, 60),
        Size = UDim2.new(0.8, 0, 0, 45)
    }):Play()
end)

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Size = UDim2.new(0.6, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.2, 0, 0.45, 0)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Text = "Status: Ready"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.TextSize = 12
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Position Label
local PositionLabel = Instance.new("TextLabel")
PositionLabel.Parent = MainFrame
PositionLabel.Size = UDim2.new(0.8, 0, 0, 20)
PositionLabel.Position = UDim2.new(0.1, 0, 0.55, 0)
PositionLabel.Font = Enum.Font.GothamMedium
PositionLabel.Text = "Position: X: 0, Y: 0, Z: 0"
PositionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PositionLabel.TextSize = 12
PositionLabel.BackgroundTransparency = 1
PositionLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Set Position Button
local SetPosButton = Instance.new("TextButton")
SetPosButton.Parent = MainFrame
SetPosButton.Size = UDim2.new(0.6, 0, 0, 35)
SetPosButton.Position = UDim2.new(0.2, 0, 0.7, 0)
SetPosButton.BackgroundColor3 = Color3.fromRGB(80, 80, 200)
SetPosButton.Font = Enum.Font.GothamBold
SetPosButton.Text = "SET CLICK POSITION"
SetPosButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SetPosButton.TextSize = 14
SetPosButton.AutoButtonColor = false

local SetPosCorner = Instance.new("UICorner")
SetPosCorner.CornerRadius = UDim.new(0, 10)
SetPosCorner.Parent = SetPosButton

-- Set Position Button Animations
SetPosButton.MouseEnter:Connect(function()
    TweenService:Create(SetPosButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(100, 100, 220),
        Size = UDim2.new(0.62, 0, 0, 37)
    }):Play()
end)

SetPosButton.MouseLeave:Connect(function()
    TweenService:Create(SetPosButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(80, 80, 200),
        Size = UDim2.new(0.6, 0, 0, 35)
    }):Play()
end)

-- Settings Panel
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Parent = ScreenGui
SettingsFrame.Size = UDim2.new(0, 320, 0, 150)
SettingsFrame.Position = UDim2.new(0.36, 0, 0.55, 0)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SettingsFrame.BackgroundTransparency = 0.1
SettingsFrame.Visible = false
SettingsFrame.BorderSizePixel = 0
SettingsFrame.ZIndex = 1000

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 12)
SettingsCorner.Parent = SettingsFrame

local SettingsStroke = Instance.new("UIStroke")
SettingsStroke.Parent = SettingsFrame
SettingsStroke.Color = Color3.fromRGB(0, 255, 255)
SettingsStroke.Thickness = 1.5
SettingsStroke.Transparency = 0.2

-- Settings Title
local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Parent = SettingsFrame
SettingsTitle.Size = UDim2.new(1, 0, 0, 25)
SettingsTitle.Position = UDim2.new(0, 0, 0, 5)
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.Text = "CLICK SETTINGS"
SettingsTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
SettingsTitle.TextSize = 14
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Center

-- Speed/Delay Settings
local speeds = {
    {label = "ULTRA FAST", value = 0.01},
    {label = "FAST", value = 0.6},
    {label = "NORMAL", value = 1},
    {label = "SLOW", value = 1.5}
}

_G.clickDelay = _G.clickDelay or 0.2

for i, speedData in ipairs(speeds) do
    local speedButton = Instance.new("TextButton")
    speedButton.Parent = SettingsFrame
    speedButton.Size = UDim2.new(0.9, 0, 0, 25)
    speedButton.Position = UDim2.new(0.05, 0, 0.15 + (i-1)*0.22, 0)
    speedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    speedButton.Font = Enum.Font.GothamMedium
    speedButton.Text = speedData.label .. " (" .. speedData.value .. "s)"
    speedButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedButton.TextSize = 12
    speedButton.AutoButtonColor = false
    speedButton.ZIndex = 1001
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 6)
    speedCorner.Parent = speedButton
    
    speedButton.MouseEnter:Connect(function()
        if _G.clickDelay ~= speedData.value then
            TweenService:Create(speedButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 70, 100)}):Play()
        end
    end)
    
    speedButton.MouseLeave:Connect(function()
        if _G.clickDelay ~= speedData.value then
            TweenService:Create(speedButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 70)}):Play()
        end
    end)
    
    speedButton.MouseButton1Click:Connect(function()
        _G.clickDelay = speedData.value
        StatusLabel.Text = "Delay: " .. speedData.value .. "s"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
        
        for j, btnData in ipairs(speeds) do
            local btn = SettingsFrame:FindFirstChildWhichIsA("TextButton", true)
            if btn and btn.Text:find(btnData.label) then
                if btnData.value == speedData.value then
                    TweenService:Create(btn, TweenInfo.new(0.3), {
                        BackgroundColor3 = Color3.fromRGB(0, 150, 200),
                        TextColor3 = Color3.fromRGB(255, 255, 255)
                    }):Play()
                else
                    TweenService:Create(btn, TweenInfo.new(0.3), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 70),
                        TextColor3 = Color3.fromRGB(200, 200, 200)
                    }):Play()
                end
            end
        end
        
        wait(0.5)
        TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.36, 0, 0.55, 0)}):Play()
        wait(0.3)
        SettingsFrame.Visible = false
    end)
    
    if speedData.value == _G.clickDelay then
        speedButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
        speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end

-- Global Variables
_G.autoClickPos = _G.autoClickPos or {X = nil, Y = nil}
_G.isLoopRunning = false
_G.dragging = false
_G.dragStartPos = nil
_G.startPos = nil

-- Real-Time Position Update
if humanoidRootPart then
    RunService.RenderStepped:Connect(function()
        local pos = humanoidRootPart.Position
        PositionLabel.Text = string.format("Position: X: %.2f, Y: %.2f, Z: %.2f", pos.X, pos.Y, pos.Z)
    end)
else
    PositionLabel.Text = "Position: Waiting for character..."
    PositionLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart", 10)
        if humanoidRootPart then
            PositionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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

-- Emergency Stop Toggle (F6)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.isLoopRunning = not _G.isLoopRunning
        if _G.isLoopRunning then
            -- Resume auto-clicking
            ToggleButton.Text = "STOP AUTO CLICK"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
            StatusLabel.Text = "Auto Clicking Active"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            spawn(function()
                while _G.isLoopRunning do
                    if _G.isLoopRunning then
                        ClickLoop()
                    end
                    wait(_G.clickDelay)
                end
            end)
        else
            -- Stop auto-clicking
            ToggleButton.Text = "START AUTO CLICK"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            StatusLabel.Text = "Emergency Stopped (F6)"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            
            wait(2)
            if not _G.isLoopRunning then
                StatusLabel.Text = "Status: Ready"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end


        end
    end
end)

-- Set Position Function
SetPosButton.MouseButton1Click:Connect(function()
    StatusLabel.Text = "🖱️ Click anywhere to set position..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            _G.autoClickPos = {
                X = input.Position.X,
                Y = input.Position.Y
            }
            
            StatusLabel.Text = "✅ Position set: " .. math.floor(_G.autoClickPos.X) .. ", " .. math.floor(_G.autoClickPos.Y)
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            
            if connection then
                connection:Disconnect()
            end
        end
    end)
    
    delay(10, function()
        if connection then
            connection:Disconnect()
            if StatusLabel.Text:find("Click anywhere") then
                StatusLabel.Text = "❌ Position set cancelled"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                wait(2)
                StatusLabel.Text = "Status: Ready"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
    end)
end)

-- Toggle Auto Click
ToggleButton.MouseButton1Click:Connect(function()
    _G.isLoopRunning = not _G.isLoopRunning
    
    if _G.isLoopRunning then
        ToggleButton.Text = "STOP AUTO CLICK"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        StatusLabel.Text = "Auto Clicking Active"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        spawn(function()
            while _G.isLoopRunning do
                if _G.isLoopRunning then
                    ClickLoop()
                end
                wait(_G.clickDelay)
            end
        end)
    else
        ToggleButton.Text = "START AUTO CLICK"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
        StatusLabel.Text = "Auto Clicking Stopped"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        wait(2)
        if not _G.isLoopRunning then
            StatusLabel.Text = "Status: Ready"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end
end)

-- Close Button
CloseButton.MouseButton1Click:Connect(function()
    _G.isLoopRunning = false
    
    TweenService:Create(MainFrame, TweenInfo.new(0.5), {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    TweenService:Create(HeaderFrame, TweenInfo.new(0.5), {
        BackgroundTransparency = 1
    }):Play()
    
    if SettingsFrame then
        TweenService:Create(SettingsFrame, TweenInfo.new(0.5), {
            BackgroundTransparency = 1
        }):Play()
    end
    
    wait(0.5)
    ScreenGui:Destroy()
end)

-- Minimize Function
local isMinimized = false
MinButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {
            Size = UDim2.new(0, 350, 0, 45)
        }):Play()
        
        ToggleButton.Visible = false
        SetPosButton.Visible = false
        StatusLabel.Visible = false
        PositionLabel.Visible = false
        SettingsFrame.Visible = false
        
        MinButton.Text = "+"
    else
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {
            Size = UDim2.new(0, 350, 0, 250)
        }):Play()
        
        wait(0.3)
        ToggleButton.Visible = true
        SetPosButton.Visible = true
        StatusLabel.Visible = true
        PositionLabel.Visible = true
        
        MinButton.Text = "−"
    end
end)

-- Settings Panel Toggle
SettingsBtn.MouseButton1Click:Connect(function()
    if SettingsFrame.Visible then
        TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.36, 0, 0.55, 0)
        }):Play()
        wait(0.3)
        SettingsFrame.Visible = false
    else
        SettingsFrame.Visible = true
        SettingsFrame.Position = UDim2.new(0.36, 0, 0.55, 0)
        TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.36, 0, 0.52, 0)
        }):Play()
    end
end)

-- Drag Functionality
local function EnableDragging(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            _G.dragging = true
            _G.dragStartPos = input.Position
            _G.startPos = frame.Position
            
            local connection
            connection = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    _G.dragging = false
                    if connection then
                        connection:Disconnect()
                    end
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and _G.dragging then
            local delta = input.Position - _G.dragStartPos
            frame.Position = UDim2.new(
                _G.startPos.X.Scale, 
                _G.startPos.X.Offset + delta.X,
                _G.startPos.Y.Scale, 
                _G.startPos.Y.Offset + delta.Y
            )
        end
    end)
end

EnableDragging(MainFrame)

-- Fade In Animation
MainFrame.BackgroundTransparency = 1
HeaderFrame.BackgroundTransparency = 1
ToggleButton.BackgroundTransparency = 1
SetPosButton.BackgroundTransparency = 1

spawn(function()
    wait(0.1)
    TweenService:Create(MainFrame, TweenInfo.new(0.8), {BackgroundTransparency = 0.15}):Play()
    TweenService:Create(HeaderFrame, TweenInfo.new(0.8), {BackgroundTransparency = 0.3}):Play()
    TweenService:Create(ToggleButton, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
    TweenService:Create(SetPosButton, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
end)

-- Auto-cleanup
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        _G.isLoopRunning = false
        if ScreenGui then
            ScreenGui:Destroy()
        end
    end
end)

print("YANZ HUB | V0.1.4 [BETA] Loaded Successfully!")
print("Features: Cyber UI, Auto Click, Position Set, Speed Control, Real-Time Position Tracking, Emergency Stop (F6)")
print("Ready to use!")

return ScreenGui
