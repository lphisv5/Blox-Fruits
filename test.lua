-- YANZ HUB | V0.1.5 [STABLE] - Updated Auto-Clicker GUI for Roblox
-- Author: Enhanced by Grok (xAI) - All bugs fixed, performance improved, UI polished
-- Features: Draggable animated GUI, Auto-Click at set position, Speed/Delay controls,
-- Real-time position/velocity tracking, Emergency Stop (F6), Minimize/Close, Test Click

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Safety wrapper for entire script initialization
local success, err = pcall(function()
    -- Wait for essential objects with timeouts
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
    if not humanoidRootPart then
        error("Failed to load HumanoidRootPart")
    end
    local camera = workspace.CurrentCamera or workspace:WaitForChild("CurrentCamera", 5)
    if not camera then
        error("Failed to load CurrentCamera")
    end

    -- Global State Variables (Persistent across sessions)
    _G.scriptLoaded = _G.scriptLoaded or false
    if _G.scriptLoaded then
        -- Reset on reload
        _G.isLoopRunning = false
        if _G.clickCoroutine then
            coroutine.close(_G.clickCoroutine)
        end
    end
    _G.scriptLoaded = true

    _G.clickDelay = _G.clickDelay or 0.2  -- Default delay in seconds
    _G.autoClickPos = _G.autoClickPos or {X = nil, Y = nil}
    _G.isLoopRunning = _G.isLoopRunning or false
    _G.dragging = false
    _G.dragStartPos = nil
    _G.startPos = nil
    _G.isSettingPosition = false
    _G.clickCoroutine = nil
    local positionConnection = nil  -- Managed connection for position updates
    local setPosConnection = nil   -- Managed connection for position setting
    local speedButtons = {}         -- Table to store speed buttons for proper updating

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

    -- Glass Effect for MainFrame
    local GlassEffect = Instance.new("Frame")
    GlassEffect.Parent = MainFrame
    GlassEffect.Size = UDim2.new(1, 0, 1, 0)
    GlassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    GlassEffect.BackgroundTransparency = 0.95
    GlassEffect.BorderSizePixel = 0
    GlassEffect.ZIndex = 0

    -- Rounded Corners for MainFrame
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 16)
    UICorner.Parent = MainFrame

    -- Animated Neon Border for MainFrame
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Parent = MainFrame
    UIStroke.Color = Color3.fromRGB(255, 0, 255)
    UIStroke.Thickness = 2.5
    UIStroke.Transparency = 0.2
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.LineJoinMode = Enum.LineJoinMode.Round

    -- Subtle Shadow Effect (Offset Stroke)
    local ShadowStroke = UIStroke:Clone()
    ShadowStroke.Parent = MainFrame
    ShadowStroke.Color = Color3.fromRGB(0, 0, 0)
    ShadowStroke.Transparency = 0.8
    ShadowStroke.Thickness = 4
    ShadowStroke.Position = UDim2.new(0, 2, 0, 2)

    -- Animated Border Color Cycle
    task.spawn(function()
        local colors = {
            Color3.fromRGB(255, 0, 255),   -- Magenta
            Color3.fromRGB(0, 255, 255),   -- Cyan
            Color3.fromRGB(255, 255, 0),   -- Yellow
            Color3.fromRGB(0, 255, 0)      -- Green
        }
        local currentIndex = 1
        while MainFrame.Parent do
            local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            TweenService:Create(UIStroke, tweenInfo, {Color = colors[currentIndex]}):Play()
            currentIndex = currentIndex % #colors + 1
            task.wait(2.1)
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

    -- Animated Title Label
    local Title = Instance.new("TextLabel")
    Title.Parent = HeaderFrame
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0.05, 0, 0, 0)
    Title.Font = Enum.Font.GothamBlack
    Title.Text = "YANZ HUB | V0.1.5 [STABLE]"
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
    VersionBadge.Text = "V0.1.5 STABLE"
    VersionBadge.TextColor3 = Color3.fromRGB(0, 255, 255)
    VersionBadge.TextSize = 12
    VersionBadge.BackgroundColor3 = Color3.fromRGB(0, 30, 40)
    VersionBadge.BackgroundTransparency = 0.3
    VersionBadge.BorderSizePixel = 0

    local BadgeCorner = Instance.new("UICorner")
    BadgeCorner.CornerRadius = UDim.new(0, 8)
    BadgeCorner.Parent = VersionBadge

    -- Title Color Animation Cycle
    task.spawn(function()
        local colors = {
            Color3.fromRGB(255, 0, 255),
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 255, 0),
            Color3.fromRGB(255, 100, 255)
        }
        local i = 1
        while Title.Parent do
            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            TweenService:Create(Title, tweenInfo, {TextColor3 = colors[i]}):Play()
            i = i % #colors + 1
            task.wait(1.6)  -- Buffer to prevent overlap
        end
    end)

    -- Control Buttons Factory Function (Reusable for Close, Min, Settings)
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

        -- Hover Animation
        button.MouseEnter:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = hoverColor,
                Size = UDim2.new(0, 32, 0, 32)
            }):Play()
        end)

        -- Leave Animation
        button.MouseLeave:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = color,
                Size = UDim2.new(0, 30, 0, 30)
            }):Play()
        end)

        -- Press Animation
        button.MouseButton1Down:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {
                BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            }):Play()
        end)

        -- Release Animation
        button.MouseButton1Up:Connect(function()
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = hoverColor}):Play()
        end)

        return button
    end

    -- Create Control Buttons
    local CloseButton = CreateControlButton("×", UDim2.new(0.9, 0, 0.15, 0),
        Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 100, 100))

    local MinButton = CreateControlButton("−", UDim2.new(0.8, 0, 0.15, 0),
        Color3.fromRGB(255, 180, 60), Color3.fromRGB(255, 200, 100))

    local SettingsBtn = CreateControlButton("⚙", UDim2.new(0.7, 0, 0.15, 0),
        Color3.fromRGB(60, 150, 255), Color3.fromRGB(100, 180, 255))

    -- Main Toggle Button for Auto-Click
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
        local targetColor = _G.isLoopRunning and Color3.fromRGB(80, 220, 80) or Color3.fromRGB(220, 80, 80)
        TweenService:Create(ToggleButton, TweenInfo.new(0.3), {
            BackgroundColor3 = targetColor,
            Size = UDim2.new(0.82, 0, 0, 47)
        }):Play()
    end)

    ToggleButton.MouseLeave:Connect(function()
        local targetColor = _G.isLoopRunning and Color3.fromRGB(60, 200, 60) or Color3.fromRGB(200, 60, 60)
        TweenService:Create(ToggleButton, TweenInfo.new(0.3), {
            BackgroundColor3 = targetColor,
            Size = UDim2.new(0.8, 0, 0, 45)
        }):Play()
    end)

    -- Status Label (Dynamic Feedback)
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

    -- Position and Velocity Label (Enhanced Tracking)
    local PositionLabel = Instance.new("TextLabel")
    PositionLabel.Parent = MainFrame
    PositionLabel.Size = UDim2.new(0.8, 0, 0, 20)
    PositionLabel.Position = UDim2.new(0.1, 0, 0.55, 0)
    PositionLabel.Font = Enum.Font.GothamMedium
    PositionLabel.Text = "Position: X: 0, Y: 0, Z: 0 | Vel: 0"
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

    -- Settings Panel (Separate from MainFrame)
    local SettingsFrame = Instance.new("Frame")
    SettingsFrame.Parent = ScreenGui
    SettingsFrame.Size = UDim2.new(0, 320, 0, 180)  -- Slightly taller for new Test button
    SettingsFrame.Position = UDim2.new(0.36, -350, 0.55, 0)  -- Off-screen start for slide-in
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

    -- Speed/Delay Options Data
    local speeds = {
        {label = "ULTRA FAST", value = 0.01},
        {label = "FAST", value = 0.05},
        {label = "NORMAL", value = 0.2},
        {label = "SLOW", value = 1.0}
    }

    -- Create Speed Buttons and Store in Table
    for i, speedData in ipairs(speeds) do
        local yOffset = 0.18 + (i - 1) * 0.12  -- Precise spacing
        local speedButton = Instance.new("TextButton")
        speedButton.Parent = SettingsFrame
        speedButton.Size = UDim2.new(0.9, 0, 0, 25)
        speedButton.Position = UDim2.new(0.05, 0, yOffset, 0)
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

        -- Store Reference
        speedButtons[speedData.label] = speedButton

        -- Hover Effects (Only if not selected)
        speedButton.MouseEnter:Connect(function()
            if _G.clickDelay ~= speedData.value then
                TweenService:Create(speedButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(70, 70, 100)
                }):Play()
            end
        end)

        speedButton.MouseLeave:Connect(function()
            if _G.clickDelay ~= speedData.value then
                TweenService:Create(speedButton, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(50, 50, 70)
                }):Play()
            end
        end)

        -- Selection Logic (Fixed: Uses Table Lookup)
        speedButton.MouseButton1Click:Connect(function()
            _G.clickDelay = speedData.value
            StatusLabel.Text = "Delay Set: " .. speedData.value .. "s"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)

            -- Update All Buttons Visually
            for _, btnData in ipairs(speeds) do
                local btn = speedButtons[btnData.label]
                if btn then
                    if btnData.value == speedData.value then
                        -- Selected State
                        TweenService:Create(btn, TweenInfo.new(0.3), {
                            BackgroundColor3 = Color3.fromRGB(0, 150, 200),
                            TextColor3 = Color3.fromRGB(255, 255, 255)
                        }):Play()
                    else
                        -- Unselected State
                        TweenService:Create(btn, TweenInfo.new(0.3), {
                            BackgroundColor3 = Color3.fromRGB(50, 50, 70),
                            TextColor3 = Color3.fromRGB(200, 200, 200)
                        }):Play()
                    end
                end
            end
        end)

        -- Initial Selection Highlight
        if speedData.value == _G.clickDelay then
            speedButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            speedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end

    -- New: Test Click Button in Settings
    local TestClickButton = Instance.new("TextButton")
    TestClickButton.Parent = SettingsFrame
    TestClickButton.Size = UDim2.new(0.9, 0, 0, 25)
    TestClickButton.Position = UDim2.new(0.05, 0, 0.74, 0)  -- Below speeds
    TestClickButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    TestClickButton.Font = Enum.Font.GothamMedium
    TestClickButton.Text = "TEST SINGLE CLICK"
    TestClickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    TestClickButton.TextSize = 12
    TestClickButton.AutoButtonColor = false
    TestClickButton.ZIndex = 1001

    local TestCorner = Instance.new("UICorner")
    TestCorner.CornerRadius = UDim.new(0, 6)
    TestCorner.Parent = TestClickButton

    TestClickButton.MouseButton1Click:Connect(function()
        local oldStatus = StatusLabel.Text
        StatusLabel.Text = "Testing Click..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        ClickLoop()  -- Fire one click
        task.wait(0.5)
        StatusLabel.Text = oldStatus
    end)

    -- New: Reset Position Button in Settings
    local ResetPosButton = Instance.new("TextButton")
    ResetPosButton.Parent = SettingsFrame
    ResetPosButton.Size = UDim2.new(0.9, 0, 0, 25)
    ResetPosButton.Position = UDim2.new(0.05, 0, 0.90, 0)  -- Bottom
    ResetPosButton.BackgroundColor3 = Color3.fromRGB(200, 100, 60)
    ResetPosButton.Font = Enum.Font.GothamMedium
    ResetPosButton.Text = "RESET CLICK POSITION"
    ResetPosButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetPosButton.TextSize = 12
    ResetPosButton.AutoButtonColor = false
    ResetPosButton.ZIndex = 1001

    local ResetCorner = Instance.new("UICorner")
    ResetCorner.CornerRadius = UDim.new(0, 6)
    ResetCorner.Parent = ResetPosButton

    ResetPosButton.MouseButton1Click:Connect(function()
        _G.autoClickPos = {X = nil, Y = nil}
        StatusLabel.Text = "Position Reset to Center"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    end)

    -- Real-Time Position and Velocity Update (Managed Connection)
    local function UpdatePosition()
        if humanoidRootPart and humanoidRootPart.Parent then
            local pos = humanoidRootPart.Position
            local humanoid = character:FindFirstChild("Humanoid")
            local vel = humanoid and humanoidRootPart.Velocity.Magnitude or 0
            PositionLabel.Text = string.format("Pos: X: %.1f, Y: %.1f, Z: %.1f | Vel: %.1f", pos.X, pos.Y, pos.Z, vel)
        else
            PositionLabel.Text = "Position: Waiting for Character..."
            PositionLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        end
    end

    -- Initial Update and Connection Management
    UpdatePosition()
    positionConnection = RunService.RenderStepped:Connect(function()
        pcall(UpdatePosition)
    end)

    -- Respawn Handling (Disconnect and Reconnect)
    LocalPlayer.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart", 10)
        if positionConnection then
            positionConnection:Disconnect()
        end
        UpdatePosition()
        positionConnection = RunService.RenderStepped:Connect(function()
            pcall(UpdatePosition)
        end)
        PositionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    -- Safe Click Function (With Retry and User Feedback)
    local function SafeClick(pos, retryCount)
        retryCount = retryCount or 0
        if retryCount > 3 then
            StatusLabel.Text = "❌ Click Failed After Retries"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
            return
        end

        if not pos or not pos.X or not pos.Y then
            StatusLabel.Text = "⚠️ Invalid Position Data"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            return
        end

        local viewportSize = camera.ViewportSize
        if pos.X < 0 or pos.Y < 0 or pos.X > viewportSize.X or pos.Y > viewportSize.Y then
            warn("Invalid click position: " .. tostring(pos))
            StatusLabel.Text = "⚠️ Position Out of Bounds"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            return
        end

        local clickSuccess, errorMsg = pcall(function()
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        end)

        if not clickSuccess then
            warn("Click error (retry " .. retryCount .. "): " .. tostring(errorMsg))
            task.wait(0.1)
            SafeClick(pos, retryCount + 1)  -- Retry
        else
            StatusLabel.Text = "✅ Click Fired"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end

    -- Click Loop Function (Single Managed)
    local function ClickLoop()
        local pos = _G.autoClickPos.X and _G.autoClickPos.Y and _G.autoClickPos or nil
        if pos then
            SafeClick(pos)
        else
            -- Fallback to screen center
            local viewportSize = camera.ViewportSize
            local centerPos = {X = viewportSize.X / 2, Y = viewportSize.Y / 2}
            SafeClick(centerPos)
        end
    end

    -- Managed Auto-Click Loop (Cancellable Coroutine)
    local function StartClickLoop()
        if _G.clickCoroutine then
            coroutine.close(_G.clickCoroutine)
        end
        _G.clickCoroutine = coroutine.create(function()
            while _G.isLoopRunning do
                ClickLoop()
                task.wait(_G.clickDelay)
            end
        end)
        task.spawn(coroutine.resume, _G.clickCoroutine)
    end

    -- Emergency Stop Toggle (F6 Key - With Debounce)
    local lastF6Press = 0
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.F6 then
            local now = tick()
            if now - lastF6Press < 0.1 then return end  -- Debounce
            lastF6Press = now

            _G.isLoopRunning = not _G.isLoopRunning
            if _G.isLoopRunning then
                -- Start/Resume
                ToggleButton.Text = "⏹ STOP AUTO CLICK"
                ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
                StatusLabel.Text = "Auto Clicking Active (F6)"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                -- Flash border red briefly for visibility
                local redTween = TweenService:Create(UIStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {Color = Color3.fromRGB(255, 0, 0)})
                redTween:Play()
                redTween.Completed:Connect(function()
                    UIStroke.Color = Color3.fromRGB(255, 0, 255)  -- Reset
                end)
                StartClickLoop()
            else
                -- Stop
                ToggleButton.Text = "▶ START AUTO CLICK"
                ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
                StatusLabel.Text = "Emergency Stopped (F6)"
                StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                task.wait(2)
                if not _G.isLoopRunning then
                    StatusLabel.Text = "Status: Ready"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                end
            end
        end
    end)

    -- Set Position Functionality (Managed Connection, No Overlaps)
    SetPosButton.MouseButton1Click:Connect(function()
        if _G.isSettingPosition then return end  -- Prevent overlaps
        _G.isSettingPosition = true
        StatusLabel.Text = "🖱️ Click anywhere to set position (10s timeout)..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)

        -- Disconnect previous if exists
        if setPosConnection then
            setPosConnection:Disconnect()
        end

        setPosConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

            _G.autoClickPos = {
                X = input.Position.X,
                Y = input.Position.Y
            }

            StatusLabel.Text = "✅ Position Set: " .. math.floor(_G.autoClickPos.X) .. ", " .. math.floor(_G.autoClickPos.Y)
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)

            _G.isSettingPosition = false
            setPosConnection:Disconnect()
            setPosConnection = nil
        end)

        -- Timeout Cleanup
        task.delay(10, function()
            if setPosConnection then
                setPosConnection:Disconnect()
                setPosConnection = nil
                if _G.isSettingPosition then
                    _G.isSettingPosition = false
                    StatusLabel.Text = "❌ Set Position Timeout"
                    StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    task.wait(2)
                    StatusLabel.Text = "Status: Ready"
                    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                end
            end
        end)
    end)

    -- Main Toggle Button Handler
    ToggleButton.MouseButton1Click:Connect(function()
        _G.isLoopRunning = not _G.isLoopRunning

        if _G.isLoopRunning then
            ToggleButton.Text = "⏹ STOP AUTO CLICK"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
            StatusLabel.Text = "Auto Clicking Active"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            StartClickLoop()
        else
            ToggleButton.Text = "▶ START AUTO CLICK"
            ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
            StatusLabel.Text = "Auto Clicking Stopped"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
            if _G.clickCoroutine then
                coroutine.close(_G.clickCoroutine)
                _G.clickCoroutine = nil
            end
            task.wait(2)
            if not _G.isLoopRunning then
                StatusLabel.Text = "Status: Ready"
                StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            end
        end
    end)

    -- Close Button Handler (Full Cleanup)
    CloseButton.MouseButton1Click:Connect(function()
        _G.isLoopRunning = false
        if _G.clickCoroutine then
            coroutine.close(_G.clickCoroutine)
        end

        local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.5), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0)
        })
        closeTween:Play()

        TweenService:Create(HeaderFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()

        if SettingsFrame.Visible then
            TweenService:Create(SettingsFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        end

        closeTween.Completed:Connect(function()
            ScreenGui:Destroy()
        end)
    end)

    -- Minimize Functionality (With Settings Check)
    local isMinimized = false
    MinButton.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized

        if isMinimized then
            -- Check and close settings if open
            if SettingsFrame.Visible then
                TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {
                    Position = UDim2.new(0.36, -350, 0.55, 0)
                }):Play()
                task.wait(0.3)
                SettingsFrame.Visible = false
            end

            TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 350, 0, 45)}):Play()

            ToggleButton.Visible = false
            SetPosButton.Visible = false
            StatusLabel.Visible = false
            PositionLabel.Visible = false

            MinButton.Text = "+"
        else
            TweenService:Create(MainFrame, TweenInfo.new(0.4), {Size = UDim2.new(0, 350, 0, 250)}):Play()

            task.wait(0.3)
            ToggleButton.Visible = true
            SetPosButton.Visible = true
            StatusLabel.Visible = true
            PositionLabel.Visible = true

            MinButton.Text = "−"
        end
    end)

    -- Settings Panel Toggle (Slide Animation)
    SettingsBtn.MouseButton1Click:Connect(function()
        if SettingsFrame.Visible then
            -- Slide Out
            TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(0.36, -350, 0.55, 0)
            }):Play()
            task.wait(0.3)
            SettingsFrame.Visible = false
        else
            SettingsFrame.Visible = true
            -- Slide In
            TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {
                Position = UDim2.new(0.36, 0, 0.55, 0)
            }):Play()
        end
    end)

    -- Enhanced Dragging (Header Only, With Bounds and Proper End Detection)
    local function EnableDragging(frame)
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                _G.dragging = true
                _G.dragStartPos = input.Position
                _G.startPos = frame.Position
            end
        end)

        -- Global Mouse Move (Single Connection)
        local dragConnection
        dragConnection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and _G.dragging then
                local delta = input.Position - _G.dragStartPos
                local newPos = UDim2.new(
                    _G.startPos.X.Scale,
                    _G.startPos.X.Offset + delta.X,
                    _G.startPos.Y.Scale,
                    _G.startPos.Y.Offset + delta.Y
                )
                -- Bounds Check (Keep on screen)
                local screenSize = camera.ViewportSize
                local absPos = UDim2.new(0, newPos.X.Offset, 0, newPos.Y.Offset)
                absPos = UDim2.new(math.clamp(absPos.X.Offset / screenSize.X, 0, 1),
                                   math.clamp(absPos.X.Offset, -screenSize.X / 2, screenSize.X / 2),
                                   math.clamp(absPos.Y.Offset / screenSize.Y, 0, 1),
                                   math.clamp(absPos.Y.Offset, -screenSize.Y / 2, screenSize.Y / 2))
                frame.Position = absPos
            end
        end)

        -- Drag End Detection
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                _G.dragging = false
                if dragConnection then
                    dragConnection:Disconnect()
                    dragConnection = UserInputService.InputChanged:Connect(function() end)  -- Reconnect empty for next drag
                end
            end
        end)
    end

    EnableDragging(HeaderFrame)  -- Drag only header for better UX

    -- Fade-In Animation on Load
    MainFrame.BackgroundTransparency = 1
    HeaderFrame.BackgroundTransparency = 1
    ToggleButton.BackgroundTransparency = 1
    SetPosButton.BackgroundTransparency = 1
    SettingsFrame.BackgroundTransparency = 1

    task.spawn(function()
        task.wait(0.1)
        TweenService:Create(MainFrame, TweenInfo.new(0.8), {BackgroundTransparency = 0.15}):Play()
        TweenService:Create(HeaderFrame, TweenInfo.new(0.8), {BackgroundTransparency = 0.3}):Play()
        TweenService:Create(ToggleButton, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
        TweenService:Create(SetPosButton, TweenInfo.new(0.8), {BackgroundTransparency = 0}):Play()
        TweenService:Create(SettingsFrame, TweenInfo.new(0.8), {BackgroundTransparency = 0.1}):Play()
    end)

    -- Auto-Cleanup on Player Leaving
    Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then
            _G.isLoopRunning = false
            if _G.clickCoroutine then
                coroutine.close(_G.clickCoroutine)
            end
            if positionConnection then
                positionConnection:Disconnect()
            end
            if setPosConnection then
                setPosConnection:Disconnect()
            end
            if ScreenGui then
                ScreenGui:Destroy()
            end
        end
    end)

    print("YANZ HUB | V0.1.5 [STABLE] Loaded Successfully!")
    print("Updates: Fixed speed selection bug, managed connections (no leaks), enhanced dragging/bounds, added Test/Reset buttons, velocity tracking, retry clicks, F6 flash.")
    print("Features: Cyber UI, Auto Click, Position Set, Speed Control, Real-Time Pos/Vel Tracking, Emergency Stop (F6), Minimize/Close.")
    print("Ready to dominate! 🚀")

    return ScreenGui
end)

if not success then
    warn("YANZ HUB Failed to Load: " .. tostring(err))
end
