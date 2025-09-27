-- ===============================
-- โหลด Darius UI
-- ===============================
local Darius = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2Swiftz/UI-Library/refs/heads/main/Libraries/Darius%20-%20Example%20.lua"))()

-- สร้าง UI
local UI = Darius.new("Darius UI Example")

-- ===============================
-- สร้างหน้าหลักและ Section
-- ===============================
local Page = UI:addPage("Main Page")
local Section = Page:addSection("Controls")

-- ปุ่มตัวอย่าง
Section:addButton("Click Me!", function()
    print("Button clicked!")
end)

-- Slider WalkSpeed พร้อมป้องกัน error
Section:addSlider("WalkSpeed", 16, 0, 500, function(value)
    local character = game.Players.LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        character.Humanoid.WalkSpeed = value
    end
    return tostring(value) -- ปลอดภัยสำหรับ UI
end)

-- ===============================
-- ปุ่มลอยแบบลากได้ + toggle UI
-- ===============================
local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local FloatingGui = Instance.new("ScreenGui")
FloatingGui.Name = "FloatingToggleUI"
FloatingGui.ResetOnSpawn = false
FloatingGui.Parent = PlayerGui

local DragButton = Instance.new("TextButton")
DragButton.Size = UDim2.new(0, 50, 0, 50)
DragButton.Position = UDim2.new(1, -60, 1, -60)
DragButton.AnchorPoint = Vector2.new(0, 0)
DragButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
DragButton.BackgroundTransparency = 0.1
DragButton.TextColor3 = Color3.fromRGB(255, 255, 255)
DragButton.Text = "+"
DragButton.Font = Enum.Font.GothamBold
DragButton.TextSize = 30
DragButton.Parent = FloatingGui

-- Hover effect
DragButton.MouseEnter:Connect(function()
    DragButton.BackgroundTransparency = 0
end)
DragButton.MouseLeave:Connect(function()
    DragButton.BackgroundTransparency = 0.1
end)

-- Toggle UI ปลอดภัย
local uiOpen = false
DragButton.MouseButton1Click:Connect(function()
    uiOpen = not uiOpen
    if uiOpen then
        UI:show()
        DragButton.Text = "×"
        DragButton.Size = UDim2.new(0, 60, 0, 60)
    else
        UI:hide()
        DragButton.Text = "+"
        DragButton.Size = UDim2.new(0, 50, 0, 50)
    end
end)

-- ===============================
-- Drag ปุ่มได้
-- ===============================
local dragging = false
local dragInput, mousePos, framePos

local function update(input)
    local delta = input.Position - mousePos
    DragButton.Position = UDim2.new(
        0, math.clamp(framePos.X + delta.X, 0, workspace.CurrentCamera.ViewportSize.X - DragButton.AbsoluteSize.X),
        0, math.clamp(framePos.Y + delta.Y, 0, workspace.CurrentCamera.ViewportSize.Y - DragButton.AbsoluteSize.Y)
    )
end

DragButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = DragButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

DragButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)
