-- Blox Fruits Advanced Auto Farm Script 2025 (Exploit Compatible)
-- Features: Auto Farm Level (Kill nearest enemy in range 10), Fast Attack (0.001s cooldown), Fly (350 speed with CFrame), ESP Names Above Heads (Enemies & Players)
-- Usage: Paste in your exploit executor (e.g., Synapse, Krnl). Toggle with keys: F=Fly, G=Auto Farm, H=ESP
-- Warning: Use at your own risk, may get banned. Not for Studio, for live game only.
-- Advanced: Uses CFrame teleport for fly (bypass anti-fly), Raycast LOS for attacks, No-clip on fly.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

-- Settings
local attackRange = 10
local attackCooldown = 0.001 -- Super fast attack
local flySpeed = 350
local autoFarmEnabled = false
local flying = false
local espEnabled = false
local lastAttack = 0
local flyConnection
local espConnections = {}

-- Tool for attack (assume you have a sword equipped, or equip one)
local tool = character:FindFirstChildOfClass("Tool") or nil
if not tool then
    -- Auto equip first tool if none
    for _, t in pairs(character:GetChildren()) do
        if t:IsA("Tool") then
            tool = t
            humanoid:EquipTool(tool)
            break
        end
    end
end

-- ESP Function: Names above heads for enemies and players
local function createESP(target)
    if espConnections[target] then return end -- Already has ESP
    
    local head = target:FindFirstChild("Head")
    if not head then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = head
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = target.Name .. (target:FindFirstChild("Humanoid") and " (Lv. " .. target.Humanoid.DisplayDistanceType.Value .. ")" or "")
    label.TextColor3 = Color3.new(1, 0, 0) -- Red for enemies, change for players
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard
    
    -- Update color: Red for enemies, Blue for players
    if target:FindFirstChild("HumanoidRootPart") and target ~= character then
        local isEnemy = target.Parent == Workspace.Enemies or target.Parent == Workspace.Boss
        label.TextColor3 = isEnemy and Color3.new(1, 0, 0) or Color3.new(0, 0, 1)
    end
    
    espConnections[target] = billboard
end

local function removeESP(target)
    if espConnections[target] then
        espConnections[target]:Destroy()
        espConnections[target] = nil
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        -- Add ESP to all enemies and players
        for _, enemy in pairs(Workspace:GetChildren()) do
            if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy ~= character.Parent then
                createESP(enemy)
            end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character ~= character then
                createESP(plr.Character)
            end
        end
        print("ESP เปิด (ชื่อเหนือหัว)")
    else
        -- Remove all
        for target, _ in pairs(espConnections) do
            removeESP(target)
        end
        print("ESP ปิด")
    end
end

-- Get nearest enemy (from Enemies and Boss folders)
local function getNearestEnemy()
    local nearest, dist = nil, math.huge
    local rayOrigin = hrp.Position
    
    -- Check Enemies folder
    for _, folder in pairs({Workspace.Enemies, Workspace.Boss}) do
        if folder then
            for _, enemy in pairs(folder:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                    local enemyHrp = enemy.HumanoidRootPart
                    local direction = (enemyHrp.Position - rayOrigin)
                    local d = direction.Magnitude
                    if d <= attackRange then
                        -- Advanced: Raycast for line-of-sight
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {character}
                        local ray = Workspace:Raycast(rayOrigin, direction, raycastParams)
                        if not ray or ray.Instance:IsDescendantOf(enemy) then
                            if d < dist then
                                dist = d
                                nearest = enemy
                            end
                        end
                    end
                end
            end
        end
    end
    return nearest
end

-- Auto Farm Loop
local farmConnection
local function toggleAutoFarm()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        farmConnection = RunService.Heartbeat:Connect(function()
            if not autoFarmEnabled then return end
            local enemy = getNearestEnemy()
            if enemy and tick() - lastAttack > attackCooldown then
                lastAttack = tick()
                -- Advanced attack: Teleport close and activate tool (fast damage)
                local oldPos = hrp.CFrame
                hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5) -- Close behind
                if tool then
                    tool:Activate() -- Fire attack
                else
                    -- Fallback: Direct damage simulation (may not work, use remote in real)
                    enemy.Humanoid:TakeDamage(999999) -- God damage if allowed
                end
                wait(0.001) -- Micro delay
                hrp.CFrame = oldPos -- Tele back
                print("ตี " .. enemy.Name)
            elseif not enemy then
                -- If no enemy nearby, fly to random spawn or something (advanced farm)
                -- For now, just wait
            end
        end)
        print("Auto Farm เปิด (ฟาร์มเลเวล)")
    else
        if farmConnection then farmConnection:Disconnect() end
        print("Auto Farm ปิด")
    end
end

-- Advanced Fly: CFrame based, no-clip, speed 350
local function toggleFly()
    flying = not flying
    if flying then
        -- No-clip
        local noClipConnection
        noClipConnection = RunService.Stepped:Connect(function()
            if not flying then noClipConnection:Disconnect() return end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
        
        flyConnection = RunService.Heartbeat:Connect(function(delta)
            if not flying then 
                flyConnection:Disconnect()
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
                return 
            end
            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                local cam = Workspace.CurrentCamera
                local moveCFrame = cam.CFrame * CFrame.new(moveDir * flySpeed * delta)
                hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + (moveCFrame.Position - hrp.Position))
                hrp.CFrame = hrp.CFrame + (moveCFrame.LookVector * flySpeed * delta)
            end
        end)
        print("บินเปิด (ความเร็ว 350)")
    else
        if flyConnection then flyConnection:Disconnect() end
        print("บินปิด")
    end
end

-- Input Toggles
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then
        toggleFly()
    elseif input.KeyCode == Enum.KeyCode.G then
        toggleAutoFarm()
    elseif input.KeyCode == Enum.KeyCode.H then
        toggleESP()
    end
end)

-- Respawn Handler
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
    -- Re-equip tool
    tool = character:FindFirstChildOfClass("Tool")
    if not tool and #character:GetChildren() > 0 then
        for _, t in pairs(character:GetChildren()) do
            if t:IsA("Tool") then tool = t; humanoid:EquipTool(t); break end
        end
    end
end)

-- Initial ESP if enabled (off by default)
print("สคริปต์โหลดเสร็จ! กด F=บิน (350), G=Auto Farm (ตีระยะ 10, 0.001s), H=ESP ชื่อเหนือหัว")
print("สำหรับ Blox Fruits: Enemies ใน Workspace.Enemies/Boss, ใช้ tool ตีหรือ damage direct.")
