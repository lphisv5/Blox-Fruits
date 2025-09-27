-- ===============================
-- โหลด Darius UI Library
-- ===============================
local Darius = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2Swiftz/UI-Library/refs/heads/main/Libraries/Darius%20-%20Example%20.lua"))()

-- สร้าง GUI
local UI = Darius.new("Darius UI Example")

-- ===============================
-- ปุ่มลอยสำหรับเปิด/ปิด UI
-- ===============================
local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "FloatingToggleUI"
FloatingGui.ResetOnSpawn = false
FloatingGui.Parent = PlayerGui

-- ปุ่มลอย
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(1, -60, 1, -60) -- มุมล่างขวา
ToggleButton.AnchorPoint = Vector2.new(0, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.Text = "+"
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextSize = 30
ToggleButton.Parent = FloatingGui

-- Hover effect
ToggleButton.MouseEnter:Connect(function()
    ToggleButton.BackgroundTransparency = 0
end)
ToggleButton.MouseLeave:Connect(function()
    ToggleButton.BackgroundTransparency = 0.1
end)

-- Toggle UI
local uiOpen = false
ToggleButton.MouseButton1Click:Connect(function()
    uiOpen = not uiOpen
    if uiOpen then
        UI:show()
        ToggleButton.Text = "×"
        ToggleButton.Size = UDim2.new(0, 60, 0, 60)
    else
        UI:hide()
        ToggleButton.Text = "+"
        ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    end
end)

-- ===============================
-- Drag ปุ่มลอยได้
-- ===============================
local dragging = false
local dragInput, mousePos, framePos

local function update(input)
    local delta = input.Position - mousePos
    ToggleButton.Position = UDim2.new(
        0, math.clamp(framePos.X + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - ToggleButton.AbsoluteSize.X),
        0, math.clamp(framePos.Y + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - ToggleButton.AbsoluteSize.Y)
    )
end

ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = ToggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

ToggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
