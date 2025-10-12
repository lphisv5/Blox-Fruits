-- Modern Lua ESP + Lock + HP for Blox Fruits
-- รองรับมือถือ และแสดง HP แบบขั้นสูง

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 150)
Frame.Position = UDim2.new(0, 30, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "👁 ESP & Lock"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Frame

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -30, 0, 0)
MinimizeButton.Text = "-"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 16
MinimizeButton.Parent = Frame

local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(1, -20, 0, 30)
ESPButton.Position = UDim2.new(0, 10, 0, 40)
ESPButton.Text = "ESP: OFF"
ESPButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ESPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ESPButton.Font = Enum.Font.GothamBold
ESPButton.TextSize = 14
ESPButton.Parent = Frame

local LockButton = Instance.new("TextButton")
LockButton.Size = UDim2.new(1, -20, 0, 30)
LockButton.Position = UDim2.new(0, 10, 0, 80)
LockButton.Text = "Lock: OFF"
LockButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
LockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
LockButton.Font = Enum.Font.GothamBold
LockButton.TextSize = 14
LockButton.Parent = Frame

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -20, 0, 20)
InfoLabel.Position = UDim2.new(0, 10, 0, 120)
InfoLabel.Text = "Target: None"
InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
InfoLabel.BackgroundTransparency = 1
InfoLabel.Font = Enum.Font.GothamBold
InfoLabel.TextSize = 12
InfoLabel.Parent = Frame

local isMinimized = false
local ESP_ENABLED = false
local isLocked = false
local target = nil
local connections = {}

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        Frame.Size = UDim2.new(0, 200, 0, 30)
        MinimizeButton.Text = "+"
    else
        Frame.Size = UDim2.new(0, 200, 0, 150)
        MinimizeButton.Text = "-"
    end
end)

local function GetNearestPlayer()
    local closestTarget = nil
    local shortestDistance = math.huge

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer and plr.Team ~= Players.LocalPlayer.Team and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (Players.LocalPlayer.Character and Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position or Players.LocalPlayer.Position) - 
                            (plr.Character.HumanoidRootPart.Position)
            distance = distance.Magnitude

            if distance < shortestDistance then
                shortestDistance = distance
                closestTarget = plr
            end
        end
    end

    return closestTarget
end

local function IsTargetAlive()
    if not target then return false end
    if not target.Character or not target.Character:FindFirstChild("Humanoid") or target.Character.Humanoid.Health <= 0 then
        return false
    end
    return true
end

local function createESP(player)
    if player == Players.LocalPlayer then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
    highlight.Parent = player.Character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.AlwaysOnTop = true
    billboard.Parent = player.Character:FindFirstChild("Head")

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard

    local hpLabel = Instance.new("TextLabel")
    hpLabel.Size = UDim2.new(1, 0, 0, 20)
    hpLabel.Position = UDim2.new(0, 0, 0, 20)
    hpLabel.BackgroundTransparency = 1
    hpLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.TextSize = 14
    hpLabel.Parent = billboard

    local barFrame = Instance.new("Frame")
    barFrame.Size = UDim2.new(1, 0, 0, 5)
    barFrame.Position = UDim2.new(0, 0, 0, 40)
    barFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    barFrame.Parent = billboard

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.Parent = barFrame

    connections[player] = RunService.Heartbeat:Connect(function()
        if ESP_ENABLED and player.Character and player.Character:FindFirstChild("Head") then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then
                local currentHP = hum.Health
                local maxHP = hum.MaxHealth
                local distance = (Players.LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude

                nameLabel.Text = player.Name .. " [" .. math.floor(distance) .. "m]"
                hpLabel.Text = "HP: " .. math.floor(currentHP) .. "/" .. math.floor(maxHP)
                healthBar.Size = UDim2.new(currentHP / maxHP, 0, 1, 0)
                healthBar.BackgroundColor3 = Color3.fromRGB(0, 255 * (currentHP / maxHP), 255 * (1 - (currentHP / maxHP)))
            end
        else
            nameLabel.Text = ""
            hpLabel.Text = ""
        end
    end)
end

local function removeESP(player)
    if connections[player] then
        connections[player]:Disconnect()
        connections[player] = nil
    end
    if player.Character then
        if player.Character:FindFirstChild("ESP_Highlight") then
            player.Character.ESP_Highlight:Destroy()
        end
        if player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("ESP_Billboard") then
            player.Character.Head.ESP_Billboard:Destroy()
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if ESP_ENABLED then
            task.wait(1)
            createESP(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

ESPButton.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    ESPButton.Text = ESP_ENABLED and "ESP: ON" or "ESP: OFF"
    ESPButton.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0, 190, 0) or Color3.fromRGB(255, 50, 50)

    for _, player in pairs(Players:GetPlayers()) do
        if ESP_ENABLED then
            createESP(player)
        else
            removeESP(player)
        end
    end
end)

LockButton.MouseButton1Click:Connect(function()
    if not isLocked then
        target = GetNearestPlayer()
        if target then
            isLocked = true
            LockButton.Text = "Lock: ON"
            LockButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
            InfoLabel.Text = "Target: " .. target.Name
        end
    else
        isLocked = false
        target = nil
        LockButton.Text = "Lock: OFF"
        LockButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        InfoLabel.Text = "Target: None"
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.F then
        if not isLocked then
            target = GetNearestPlayer()
            if target then
                isLocked = true
                LockButton.Text = "Lock: ON"
                LockButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                InfoLabel.Text = "Target: " .. target.Name
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if isLocked then
        if not IsTargetAlive() then
            isLocked = false
            target = nil
            LockButton.Text = "Lock: OFF"
            LockButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            InfoLabel.Text = "Target: None"
        else
            if Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetPos = target.Character.HumanoidRootPart.Position
                local rootPart = Players.LocalPlayer.Character.HumanoidRootPart

                local lookAt = CFrame.lookAt(rootPart.Position, Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z))
                rootPart.CFrame = CFrame.new(rootPart.CFrame.Position, lookAt.LookVector + rootPart.Position)
            end
        end
    end
end)

local mt = getrawmetatable(game)
local oldNameCall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    if method == "InvokeServer" and self.Name == "CommF_" then
        local index = args[1]
        if index == "1" or index == "2" or index == "3" or index == "4" then
            if isLocked and target and IsTargetAlive() then
                args[2] = target.Character.HumanoidRootPart.Position
                args[3] = target.Character.HumanoidRootPart
            end
        end
    end

    return oldNameCall(self, unpack(args))
end)
