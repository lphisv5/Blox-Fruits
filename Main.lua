--// REDZ HUB - Pro UI Animated + Safe Auto Click | 2025
--// Creator: You :)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

-- Main Frame
local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Position = UDim2.new(0.35, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 260, 0, 160)
Frame.BackgroundTransparency = 1
Frame.ClipsDescendants = true

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = Frame

-- Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Parent = Frame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Image = "rbxassetid://5028857084"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ZIndex = -1

-- Title
local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, -120, 0, 40)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "🔴 REDZ HUB"
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Control Buttons
local function createBtn(txt, pos, color)
    local btn = Instance.new("TextButton")
    btn.Parent = Frame
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.new(0, 30, 0, 30)
    btn.Position = pos
    btn.Font = Enum.Font.GothamBold
    btn.Text = txt
    btn.TextColor3 = color
    btn.TextSize = 18
    return btn
end

local CloseButton = createBtn("X", UDim2.new(1, -35, 0, 5), Color3.fromRGB(255, 90, 90))
local MinButton   = createBtn("-", UDim2.new(1, -65, 0, 5), Color3.fromRGB(255, 200, 90))
local SettingsBtn = createBtn("⚙️", UDim2.new(1, -95, 0, 5), Color3.fromRGB(90, 200, 255))

-- Toggle Loop Button
local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Frame
ToggleButton.Size = UDim2.new(0.7, 0, 0, 40)
ToggleButton.Position = UDim2.new(0.15, 0, 0.55, -15)
ToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "▶ Start Loop"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16

local UICorner2 = Instance.new("UICorner")
UICorner2.CornerRadius = UDim.new(0, 10)
UICorner2.Parent = ToggleButton

-- Hover effect for buttons
local function addHover(btn, baseColor, hoverColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = baseColor}):Play()
    end)
end
addHover(ToggleButton, Color3.fromRGB(200,60,60), Color3.fromRGB(255,80,80))

-- Settings Panel
local SettingsFrame = Instance.new("Frame")
SettingsFrame.Parent = Frame
SettingsFrame.Size = UDim2.new(1, -20, 0, 90)
SettingsFrame.Position = UDim2.new(0, 10, 1, 5)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
SettingsFrame.Visible = false
local UICorner3 = Instance.new("UICorner")
UICorner3.CornerRadius = UDim.new(0, 10)
UICorner3.Parent = SettingsFrame

-- Speed buttons
local speeds = {0.1, 0.2, 0.5}
_G.clickDelay = 0.2

for i, v in ipairs(speeds) do
    local btn = Instance.new("TextButton")
    btn.Parent = SettingsFrame
    btn.Size = UDim2.new(1, -20, 0, 25)
    btn.Position = UDim2.new(0, 10, 0, (i - 1) * 30 + 5)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = tostring(v).."s Delay"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 6)
    addHover(btn, Color3.fromRGB(60,60,60), Color3.fromRGB(100,100,100))
    btn.MouseButton1Click:Connect(function()
        _G.clickDelay = v
        TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {Position = UDim2.new(0,10,1,5)}):Play()
        wait(0.3)
        SettingsFrame.Visible = false
    end)
end

-- Set Auto Click Position Button
local SetPosButton = Instance.new("TextButton")
SetPosButton.Parent = Frame
SetPosButton.Size = UDim2.new(0, 100, 0, 30)
SetPosButton.Position = UDim2.new(0.05, 0, 0.85, 0)
SetPosButton.BackgroundColor3 = Color3.fromRGB(80,80,200)
SetPosButton.Text = "Set Click Pos"
SetPosButton.TextColor3 = Color3.fromRGB(255,255,255)
SetPosButton.Font = Enum.Font.GothamBold
SetPosButton.TextSize = 14
local UICorner4 = Instance.new("UICorner")
UICorner4.CornerRadius = UDim.new(0,6)
UICorner4.Parent = SetPosButton
addHover(SetPosButton, Color3.fromRGB(80,80,200), Color3.fromRGB(120,120,255))

-- ตัวแปรตำแหน่ง Auto Click
_G.autoClickPos = _G.autoClickPos or {X = nil, Y = nil}

SetPosButton.MouseButton1Click:Connect(function()
    print("🖱️ คลิกตำแหน่งที่ต้องการในหน้าจอตอนนี้...")
    local conn
    conn = UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            _G.autoClickPos.X = input.Position.X
            _G.autoClickPos.Y = input.Position.Y
            print("✅ ตำแหน่งคลิกบันทึกแล้ว:", _G.autoClickPos.X, _G.autoClickPos.Y)
            conn:Disconnect()
        end
    end)
end)

-- Fade In Animation
TweenService:Create(Frame, TweenInfo.new(0.4), {BackgroundTransparency = 0}):Play()

-- Loop System
local loopRunning = false

local function safeClick(pos)
    if pos and pos.X and pos.Y then
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
        VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
    end
end

local function clickLoop()
    if _G.autoClickPos.X and _G.autoClickPos.Y then
        safeClick(_G.autoClickPos)
    else
        local cam = workspace.CurrentCamera
        local view = cam.ViewportSize
        safeClick({X=view.X/2, Y=view.Y/2})
    end
end

ToggleButton.MouseButton1Click:Connect(function()
    loopRunning = not loopRunning
    if loopRunning then
        ToggleButton.Text = "⏹ Stop Loop"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(60,200,60)
        spawn(function()
            while loopRunning do
                clickLoop()
                wait(_G.clickDelay)
            end
        end)
    else
        ToggleButton.Text = "▶ Start Loop"
        ToggleButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
    end
end)

-- Close
CloseButton.MouseButton1Click:Connect(function()
    loopRunning = false
    TweenService:Create(Frame, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    wait(0.3)
    ScreenGui:Destroy()
end)

-- Minimize
local minimized = false
MinButton.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(0,260,0,40)}):Play()
        ToggleButton.Visible = false
        SettingsFrame.Visible = false
        SetPosButton.Visible = false
    else
        TweenService:Create(Frame, TweenInfo.new(0.3), {Size = UDim2.new(0,260,0,160)}):Play()
        wait(0.2)
        ToggleButton.Visible = true
        SetPosButton.Visible = true
    end
end)

-- Settings slide
SettingsBtn.MouseButton1Click:Connect(function()
    if SettingsFrame.Visible then
        TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {Position = UDim2.new(0,10,1,5)}):Play()
        wait(0.3)
        SettingsFrame.Visible = false
    else
        SettingsFrame.Visible = true
        SettingsFrame.Position = UDim2.new(0,10,1,100)
        TweenService:Create(SettingsFrame, TweenInfo.new(0.3), {Position = UDim2.new(0,10,1,5)}):Play()
    end
end)

-- Drag GUI
local dragging, dragStart, startPos
Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
