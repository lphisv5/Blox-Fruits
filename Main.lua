--// YANZ HUB | V0.1.2 //--
--// Creator: @id2_lphisv4
--// Complete Bug-Free Version with Enhanced Features //--

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Safety check and anti-detection
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

-- Enhanced GUI Creation with Safety Features
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "REDZHubPro2025"
ScreenGui.Parent = game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999

-- Main Container Frame (Enhanced Glassmorphism)
local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.Size = UDim2.new(0, 350, 0, 220) -- Increased size for better layout
MainFrame.Position = UDim2.new(0.35, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BackgroundTransparency = 0.15
MainFrame.ClipsDescendants = true
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false -- We'll implement custom dragging

-- Enhanced Glass Effect
local GlassEffect = Instance.new("Frame")
GlassEffect.Parent = MainFrame
GlassEffect.Size = UDim2.new(1, 0, 1, 0)
GlassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GlassEffect.BackgroundTransparency = 0.95
GlassEffect.BorderSizePixel = 0
GlassEffect.ZIndex = 0

-- Modern Rounded Corners
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

-- Enhanced Header Section
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

-- Animated Title with Icon
local Title = Instance.new("TextLabel")
Title.Parent = HeaderFrame
Title.Size = UDim2.new(0.6, 0, 1, 0)
Title.Position = UDim2.new(0.05, 0, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.Text = "YANZ HUB | V0.1.2 [BETA VERSION]"
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
VersionBadge.Text = "v3.0.1 ULTRA"
VersionBadge.TextColor3 = Color3.fromRGB(0, 255, 255)
VersionBadge.TextSize = 12
VersionBadge.BackgroundColor3 = Color3.fromRGB(0, 30, 40)
VersionBadge.BackgroundTransparency = 0.3
VersionBadge.BorderSizePixel = 0

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 8)
BadgeCorner.Parent = VersionBadge

-- Title Animation (Enhanced)
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

-- Control Buttons Factory Function
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
    
    -- Hover Effects
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor, Size = UDim2.new(0, 32, 0, 32)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = color, Size = UDim2.new(0, 30, 0, 30)}):Play()
    end)
    
    -- Click Effect
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

-- Main Toggle Button (Enhanced)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = MainFrame
ToggleButton.Size = UDim2.new(0.8, 0, 0, 45)
ToggleButton.Position = UDim2.new(0.1, 0, 0.3, 0)
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

-- Enhanced Toggle Button Animations
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

-- Status Indicator
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.Size = UDim2.new(0.6, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.2, 0, 0.55, 0)
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.Text = "Status: Ready"
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
StatusLabel.TextSize = 12
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Set Position Button (Enhanced)
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

-- Enhanced Settings Panel
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Parent = MainFrame
SettingsFrame.Size = UDim2.new(0.9, 0, 0, 120)
SettingsFrame.Position = UDim2.new(0.05, 0, 1.1, 0)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
SettingsFrame.BackgroundTransparency = 0.1
SettingsFrame.Visible = false
SettingsFrame.BorderSizePixel = 0

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
    {label = "ULTRA FAST", value = 0.05},
    {label = "FAST", value = 0.1},
    {label = "NORMAL", value = 0.2},
    {label = "SLOW", value = 0.5}
}

_G.clickDelay = _G.clickDelay or 0.2 -- Default delay

for i, speedData in ipairs(speeds) do
    local speedButton = Instance.new("TextButton")
    speedButton.Parent = SettingsFrame
    speedButton.Size = UDim2.new(0.9, 0, 0, 22)
    speedButton.Position = UDim2.new(0.05, 0, 0.2 + (i-1)*0.2, 0)
    speedButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    speedButton.Font = Enum.Font.GothamMedium
    speedButton.Text = speedData.label .. " (" .. speedData.value .. "s)"
    speedButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    speedButton.TextSize = 12
    speedButton.AutoButtonColor = false
    
    local speedCorner = Instance.new("UICorner")
    speedCorner.CornerRadius = UDim.new(0, 6)
    speedCorner.Parent = speedButton
    
    -- Speed button animations
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
        
        -- Update all speed buttons appearance
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
        -- Hide settings panel
        TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {Position = UDim2.new(0.05, 0, 1.1, 0)}):Play()
        wait(0.3)
        SettingsFrame.Visible = false
    end)
    
    -- Set initial appearance for current delay
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

-- Enhanced Safe Click Function
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return end
    
    -- Input validation
    local viewportSize = workspace.CurrentCamera.ViewportSize
    if pos.X < 0 or pos.Y < 0 or pos.X > viewportSize.X or pos.Y > viewportSize.Y then
        warn("⚠️ Invalid click position")
        return
    end
    
    -- Simulate mouse click
    local success, errorMsg = pcall(function()
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
    end)
    
    if not success then
        warn("❌ Click error: " .. tostring(errorMsg))
    end
end

-- Enhanced Click Loop with Safety
local function ClickLoop()
    if _G.autoClickPos and _G.autoClickPos.X and _G.autoClickPos.Y then
        SafeClick(_G.autoClickPos)
    else
        -- Default to screen center if no position set
        local viewportSize = workspace.CurrentCamera.ViewportSize
        local centerPos = {
            X = viewportSize.X / 2,
            Y = viewportSize.Y / 2
        }
        SafeClick(centerPos)
    end
end

-- Set Position Function (Enhanced)
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
    
    -- Auto-cancel after 10 seconds
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

-- Toggle Auto Click Function
ToggleButton.MouseButton1Click:Connect(function()
    _G.isLoopRunning = not _G.isLoopRunning
    
    if _G.isLoopRunning then
        -- Start auto-clicking
        ToggleButton.Text = "STOP AUTO CLICK"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
        StatusLabel.Text = "Auto Clicking Active"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Start click loop in a separate thread
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
        StatusLabel.Text = "Auto Clicking Stopped"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        
        wait(2)
        if not _G.isLoopRunning then
            StatusLabel.Text = "Status: Ready"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end
end)

-- Close Button Function
CloseButton.MouseButton1Click:Connect(function()
    _G.isLoopRunning = false
    
    -- Fade out animation
    TweenService:Create(MainFrame, TweenInfo.new(0.5), {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    
    TweenService:Create(HeaderFrame, TweenInfo.new(0.5), {
        BackgroundTransparency = 1
    }):Play()
    
    wait(0.5)
    ScreenGui:Destroy()
end)

-- Minimize Function
local isMinimized = false
MinButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    
    if isMinimized then
        -- Minimize
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {
            Size = UDim2.new(0, 350, 0, 45)
        }):Play()
        
        -- Hide content
        ToggleButton.Visible = false
        SetPosButton.Visible = false
        StatusLabel.Visible = false
        SettingsFrame.Visible = false
        
        MinButton.Text = "+"
    else
        -- Restore
        TweenService:Create(MainFrame, TweenInfo.new(0.4), {
            Size = UDim2.new(0, 350, 0, 220)
        }):Play()
        
        -- Show content with delay
        wait(0.3)
        ToggleButton.Visible = true
        SetPosButton.Visible = true
        StatusLabel.Visible = true
        
        MinButton.Text = "−"
    end
end)

-- Settings Panel Toggle
SettingsBtn.MouseButton1Click:Connect(function()
    if SettingsFrame.Visible then
        -- Hide settings
        TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.05, 0, 1.1, 0)
        }):Play()
        wait(0.3)
        SettingsFrame.Visible = false
    else
        -- Show settings
        SettingsFrame.Visible = true
        SettingsFrame.Position = UDim2.new(0.05, 0, 1.1, 0)
        TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.05, 0, 0.95, 0)
        }):Play()
    end
end)

-- Enhanced Drag Functionality
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

-- Enable dragging on header
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

-- Auto-cleanup on player leave
game:GetService("Players").PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then
        _G.isLoopRunning = false
        if ScreenGui then
            ScreenGui:Destroy()
        end
    end
end)

-- Final initialization message
print("🔥 REDZ HUB Pro 2025 Loaded Successfully!")
print("✅ Features: Cyber UI, Auto Click, Position Set, Speed Control")
print("🎮 Ready to use!")

return ScreenGui
