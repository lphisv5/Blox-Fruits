-- Blox Fruits Advanced Auto Farm & Quest GUI Script 2025 (Exploit Compatible) - Updated for Third Sea
-- Features: GUI with toggles for Auto Farm Level, Auto Quest (now supports First & Third Sea based on level), Fly (350 speed), ESP Names
-- Auto Quest: Detects sea by level (First: 0-699, Third: 1500+), teleports to NPC, starts quest, farms specific mob, claims when done.
-- Usage: Paste in executor. GUI top-left. Keys: F=Fly, G=Farm, Q=Auto Quest, H=ESP
-- Third Sea Data: Compiled from latest 2025 sources (Wiki, FruityBlox, Sportskeeda). CFrames approximate/common - adjust if needed.
-- Note: Special quests (e.g., Captain Elephant: +50 Forest Pirates) simplified to main mob. Use at own risk!

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
local attackCooldown = 0.001
local flySpeed = 350
local autoFarmEnabled = false
local autoQuestEnabled = false
local flying = false
local espEnabled = false
local lastAttack = 0
local flyConnection, farmConnection
local espConnections = {}
local currentQuestMob = nil
local killedCount = 0
local questAmount = 8 -- Default

-- Tool handling
local tool = character:FindFirstChildOfClass("Tool") or nil
if not tool then
    for _, t in pairs(character:GetChildren()) do
        if t:IsA("Tool") then
            tool = t
            humanoid:EquipTool(tool)
            break
        end
    end
end

-- Quest Data: First Sea (previous) + Third Sea (new)
local FirstSeaQuests = {
    [0] = {quest = "BanditQuest1", level = 0, npcCFrame = CFrame.new(1059.321, 16.876, 1547.953, 0.5, 0, 0.866, 0, 1, 0, -0.866, 0, 0.5), mob = "Bandit", amount = 6},
    [10] = {quest = "JungleQuest1", level = 10, npcCFrame = CFrame.new(-1604.168, 36.852, 149.649, 0.0645, 0, 0.9979, 0, 1, 0, -0.9979, 0, 0.0645), mob = "Monkey", amount = 5},
    [15] = {quest = "JungleQuest2", level = 15, npcCFrame = CFrame.new(-1604.168, 36.852, 149.649, 0.0645, 0, 0.9979, 0, 1, 0, -0.9979, 0, 0.0645), mob = "Gorilla", amount = 5},
    [20] = {quest = "JungleQuest3", level = 20, npcCFrame = CFrame.new(-1604.168, 36.852, 149.649, 0.0645, 0, 0.9979, 0, 1, 0, -0.9979, 0, 0.0645), mob = "GorillaKing", amount = 1}, -- Boss
    [30] = {quest = "PirateQuest1", level = 30, npcCFrame = CFrame.new(-288.074, 43.133, 5583.3, -0.965, 0, -0.262, 0, 1, 0, 0.262, 0, -0.965), mob = "Pirate", amount = 8},
    [40] = {quest = "PirateQuest2", level = 40, npcCFrame = CFrame.new(-288.074, 43.133, 5583.3, -0.965, 0, -0.262, 0, 1, 0, 0.262, 0, -0.965), mob = "Brute", amount = 8},
    [60] = {quest = "DesertQuest1", level = 60, npcCFrame = CFrame.new(897.031, 40.389, 4391.412, 0.310, 0, 0.950, 0, 1, 0, -0.950, 0, 0.310), mob = "DesertBandit", amount = 8},
    [75] = {quest = "DesertQuest2", level = 75, npcCFrame = CFrame.new(897.031, 40.389, 4391.412, 0.310, 0, 0.950, 0, 1, 0, -0.950, 0, 0.310), mob = "DesertOfficer", amount = 8},
    [90] = {quest = "FrozenQuest1", level = 90, npcCFrame = CFrame.new(1384.765, 87.272, -1298.114, 0.866, 0, -0.5, 0, 1, 0, 0.5, 0, 0.866), mob = "SnowBandit", amount = 8},
    [100] = {quest = "FrozenQuest2", level = 100, npcCFrame = CFrame.new(1384.765, 87.272, -1298.114, 0.866, 0, -0.5, 0, 1, 0, 0.5, 0, 0.866), mob = "Snowman", amount = 8},
    -- Add more First Sea as needed
}

local ThirdSeaQuests = {
    [1500] = {quest = "PortTownQuest1", level = 1500, npcCFrame = CFrame.new(515.7, 138.5, 90.5), mob = "PirateMillionaire", amount = 8},
    [1525] = {quest = "PortTownQuest2", level = 1525, npcCFrame = CFrame.new(515.7, 138.5, 90.5), mob = "PistolBillionaire", amount = 8},
    [1550] = {quest = "PortTownQuest3", level = 1550, npcCFrame = CFrame.new(515.7, 138.5, 90.5), mob = "Stone", amount = 1}, -- Boss
    [1575] = {quest = "HydraQuest1", level = 1575, npcCFrame = CFrame.new(5596.5, 51.8, 747.4), mob = "DragonCrewWarrior", amount = 8},
    [1600] = {quest = "HydraQuest2", level = 1600, npcCFrame = CFrame.new(5596.5, 51.8, 747.4), mob = "DragonCrewArcher", amount = 8},
    [1625] = {quest = "HydraQuest3", level = 1625, npcCFrame = CFrame.new(5700, 60, 800), mob = "HydraEnforcer", amount = 8},
    [1650] = {quest = "HydraQuest4", level = 1650, npcCFrame = CFrame.new(5700, 60, 800), mob = "VenomousAssailant", amount = 8},
    [1675] = {quest = "HydraQuest5", level = 1675, npcCFrame = CFrame.new(5700, 60, 800), mob = "HydraLeader", amount = 1}, -- Boss
    [1700] = {quest = "GreatTreeQuest1", level = 1700, npcCFrame = CFrame.new(2286.5, 16.1, 181.5), mob = "MarineCommodore", amount = 8},
    [1725] = {quest = "GreatTreeQuest2", level = 1725, npcCFrame = CFrame.new(2286.5, 16.1, 181.5), mob = "MarineRearAdmiral", amount = 8},
    [1750] = {quest = "GreatTreeQuest3", level = 1750, npcCFrame = CFrame.new(2286.5, 16.1, 181.5), mob = "KiloAdmiral", amount = 1}, -- Boss
    [1775] = {quest = "FloatingTurtleQuest1", level = 1775, npcCFrame = CFrame.new(-1320.4, 13.99, -7576.9), mob = "FishmanRaider", amount = 8},
    [1800] = {quest = "FloatingTurtleQuest2", level = 1800, npcCFrame = CFrame.new(-1320.4, 13.99, -7576.9), mob = "FishmanCaptain", amount = 8},
    [1825] = {quest = "FloatingTurtleQuest3", level = 1825, npcCFrame = CFrame.new(-1320.4, 13.99, -7576.9), mob = "ForestPirate", amount = 8},
    [1850] = {quest = "FloatingTurtleQuest4", level = 1850, npcCFrame = CFrame.new(-1320.4, 13.99, -7576.9), mob = "MythologicalPirate", amount = 8},
    [1875] = {quest = "FloatingTurtleQuest5", level = 1875, npcCFrame = CFrame.new(-1320.4, 13.99, -7576.9), mob = "CaptainElephant", amount = 1}, -- Special: +50 Forest Pirates ignored for simplicity
    [1900] = {quest = "FloatingTurtleQuest6", level = 1900, npcCFrame = CFrame.new(-1320.4, 13.99, -7576.9), mob = "JunglePirate", amount = 8},
    [1925] = {quest = "FloatingTurtleQuest7", level = 1925, npcCFrame = CFrame.new(-1320.4, 13.99, -7576.9), mob = "MusketeerPirate", amount = 8},
    [1950] = {quest = "FloatingTurtleQuest8", level = 1950, npcCFrame = CFrame.new(-1320.4, 13.99, -7576.9), mob = "BeautifulPirate", amount = 1}, -- Boss
    [1975] = {quest = "HauntedQuest1", level = 1975, npcCFrame = CFrame.new(-9500.5, 145.2, 5560.5), mob = "RebornSkeleton", amount = 8},
    [2000] = {quest = "HauntedQuest2", level = 2000, npcCFrame = CFrame.new(-9500.5, 145.2, 5560.5), mob = "LivingZombie", amount = 8},
    [2025] = {quest = "HauntedQuest3", level = 2025, npcCFrame = CFrame.new(-9500.5, 145.2, 5560.5), mob = "DemonicSoul", amount = 8},
    [2050] = {quest = "HauntedQuest4", level = 2050, npcCFrame = CFrame.new(-9500.5, 145.2, 5560.5), mob = "PossessedMummy", amount = 8},
    [2075] = {quest = "SeaOfTreatsQuest1", level = 2075, npcCFrame = CFrame.new(-2015.5, 37.8, -12000.5), mob = "PeanutScout", amount = 8},
    [2100] = {quest = "SeaOfTreatsQuest2", level = 2100, npcCFrame = CFrame.new(-2015.5, 37.8, -12000.5), mob = "IceCreamChef", amount = 8},
    [2125] = {quest = "SeaOfTreatsQuest3", level = 2125, npcCFrame = CFrame.new(-2015.5, 37.8, -12000.5), mob = "CakeGuard", amount = 8},
    [2150] = {quest = "SeaOfTreatsQuest4", level = 2150, npcCFrame = CFrame.new(-2015.5, 37.8, -12000.5), mob = "CocoaWarrior", amount = 8},
    [2175] = {quest = "SeaOfTreatsQuest5", level = 2175, npcCFrame = CFrame.new(-2015.5, 37.8, -12000.5), mob = "CakePrince", amount = 1}, -- Boss
    -- Tiki Outpost (approx levels 2200+)
    [2200] = {quest = "TikiQuest1", level = 2200, npcCFrame = CFrame.new(5500, 60, -6500), mob = "TikiWarrior", amount = 8},
    [2225] = {quest = "TikiQuest2", level = 2225, npcCFrame = CFrame.new(5500, 60, -6500), mob = "TikiShaman", amount = 8},
    -- Add more/variants like Barista Cousin, etc. as needed
}

-- Get current quest based on level and sea
local function getCurrentQuest(level)
    if level < 1500 then
        -- First Sea
        for l, q in pairs(FirstSeaQuests) do
            if level >= q.level and (not FirstSeaQuests[l+1] or level < FirstSeaQuests[l+1].level) then
                return q
            end
        end
    else
        -- Third Sea
        for l, q in pairs(ThirdSeaQuests) do
            if level >= q.level and (not ThirdSeaQuests[l+25] or level < ThirdSeaQuests[l+25].level) then -- Approx step 25
                return q
            end
        end
    end
    return nil
end

-- Start/Claim Quest (updated for sea detection)
local function handleQuest(quest, isClaim)
    if quest then
        local oldPos = hrp.CFrame
        hrp.CFrame = quest.npcCFrame * CFrame.new(0, 5, 0)
        wait(0.5)
        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest.quest, quest.level, isClaim and 1 or nil)
        wait(0.5)
        hrp.CFrame = oldPos
        if not isClaim then
            currentQuestMob = quest.mob
            killedCount = 0
            questAmount = quest.amount
            print("เริ่ม Quest: " .. quest.quest .. " - ฆ่า " .. quest.amount .. " " .. quest.mob)
        else
            print("รับรางวัล Quest: " .. quest.quest)
            currentQuestMob = nil
            killedCount = 0
        end
    end
end

-- ESP Functions (unchanged)
local function createESP(target)
    if espConnections[target] then return end
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
    label.Text = target.Name
    label.TextColor3 = Color3.new(1, 0, 0)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSansBold
    label.Parent = billboard
    
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
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj:FindFirstChild("Humanoid") and obj:FindFirstChild("HumanoidRootPart") and obj ~= character then
                createESP(obj)
            end
        end
        for _, plr in pairs(Players:GetPlayers()) do
            if plr.Character and plr.Character ~= character then
                createESP(plr.Character)
            end
        end
    else
        for target, _ in pairs(espConnections) do
            removeESP(target)
        end
    end
end

-- Get Nearest Enemy (filter by quest mob)
local function getNearestEnemy()
    local nearest, dist = nil, math.huge
    local rayOrigin = hrp.Position
    local targetMob = autoQuestEnabled and currentQuestMob or nil
    
    for _, folder in pairs({Workspace.Enemies, Workspace.Boss}) do
        if folder then
            for _, enemy in pairs(folder:GetChildren()) do
                if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart") and enemy.Humanoid.Health > 0 then
                    if targetMob and not string.find(enemy.Name, targetMob) then continue end
                    local enemyHrp = enemy.HumanoidRootPart
                    local direction = (enemyHrp.Position - rayOrigin)
                    local d = direction.Magnitude
                    if d <= attackRange then
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

-- Toggle Auto Farm (integrates quest progress)
local function toggleAutoFarm()
    autoFarmEnabled = not autoFarmEnabled
    if autoFarmEnabled then
        farmConnection = RunService.Heartbeat:Connect(function()
            if not autoFarmEnabled then return end
            local enemy = getNearestEnemy()
            if enemy and tick() - lastAttack > attackCooldown then
                lastAttack = tick()
                local oldPos = hrp.CFrame
                hrp.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                if tool then
                    tool:Activate()
                else
                    enemy.Humanoid:TakeDamage(999999)
                end
                wait(0.001)
                hrp.CFrame = oldPos
                print("ตี " .. enemy.Name)
                
                -- Quest progress
                if autoQuestEnabled and currentQuestMob then
                    killedCount = killedCount + 1
                    print("ฆ่าแล้ว: " .. killedCount .. "/" .. questAmount .. " " .. currentQuestMob)
                    if killedCount >= questAmount then
                        local level = player.leaderstats.Level.Value
                        local quest = getCurrentQuest(level)
                        handleQuest(quest, true) -- Claim
                        wait(2)
                        quest = getCurrentQuest(level)
                        if quest then
                            handleQuest(quest, false) -- Start next
                        end
                    end
                end
            end
        end)
    else
        if farmConnection then farmConnection:Disconnect() end
    end
end

-- Toggle Auto Quest
local function toggleAutoQuest()
    if not autoFarmEnabled then
        print("เปิด Auto Farm ก่อน!")
        return
    end
    autoQuestEnabled = not autoQuestEnabled
    if autoQuestEnabled then
        local level = player.leaderstats.Level.Value
        local quest = getCurrentQuest(level)
        if quest then
            handleQuest(quest, false)
        else
            print("ไม่มี Quest สำหรับเลเวล " .. level)
            autoQuestEnabled = false
        end
    else
        currentQuestMob = nil
        killedCount = 0
        print("Auto Quest ปิด")
    end
end

-- Toggle Fly (unchanged)
local function toggleFly()
    flying = not flying
    if flying then
        local noClipConnection = RunService.Stepped:Connect(function()
            if not flying then noClipConnection:Disconnect() return end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
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
                hrp.CFrame = hrp.CFrame + (moveCFrame.LookVector * flySpeed * delta)
            end
        end)
    else
        if flyConnection then flyConnection:Disconnect() end
    end
end

-- GUI Creation (unchanged, size for buttons)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoFarmGUI"
ScreenGui.Parent = player.PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 250)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Position = UDim2.new(0, 0, 0, 0)
TitleLabel.BackgroundColor3 = Color3.new(0, 0.5, 1)
TitleLabel.Text = "Blox Fruits Auto Farm & Quest GUI (Third Sea Added)"
TitleLabel.TextColor3 = Color3.new(1, 1, 1)
TitleLabel.TextScaled = true
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = MainFrame

local FarmButton = Instance.new("TextButton")
FarmButton.Size = UDim2.new(1, -20, 0, 40)
FarmButton.Position = UDim2.new(0, 10, 0, 50)
FarmButton.BackgroundColor3 = Color3.new(0.8, 0.2, 0.2)
FarmButton.Text = "Auto Farm Level: OFF"
FarmButton.TextColor3 = Color3.new(1, 1, 1)
FarmButton.TextScaled = true
FarmButton.Font = Enum.Font.SourceSans
FarmButton.Parent = MainFrame

local QuestButton = Instance.new("TextButton")
QuestButton.Size = UDim2.new(1, -20, 0, 40)
QuestButton.Position = UDim2.new(0, 10, 0, 100)
QuestButton.BackgroundColor3 = Color3.new(0.8, 0.8, 0.2)
QuestButton.Text = "Auto Quest: OFF (Need Farm ON)"
QuestButton.TextColor3 = Color3.new(1, 1, 1)
QuestButton.TextScaled = true
QuestButton.Font = Enum.Font.SourceSans
QuestButton.Parent = MainFrame

local FlyButton = Instance.new("TextButton")
FlyButton.Size = UDim2.new(1, -20, 0, 40)
FlyButton.Position = UDim2.new(0, 10, 0, 150)
FlyButton.BackgroundColor3 = Color3.new(0.2, 0.8, 0.2)
FlyButton.Text = "Fly: OFF"
FlyButton.TextColor3 = Color3.new(1, 1, 1)
FlyButton.TextScaled = true
FlyButton.Font = Enum.Font.SourceSans
FlyButton.Parent = MainFrame

local ESPButton = Instance.new("TextButton")
ESPButton.Size = UDim2.new(1, -20, 0, 40)
ESPButton.Position = UDim2.new(0, 10, 0, 200)
ESPButton.BackgroundColor3 = Color3.new(0.2, 0.2, 0.8)
ESPButton.Text = "ESP Names: OFF"
ESPButton.TextColor3 = Color3.new(1, 1, 1)
ESPButton.TextScaled = true
ESPButton.Font = Enum.Font.SourceSans
ESPButton.Parent = MainFrame

-- Button Connections
FarmButton.MouseButton1Click:Connect(function()
    toggleAutoFarm()
    FarmButton.Text = "Auto Farm Level: " .. (autoFarmEnabled and "ON" or "OFF")
    FarmButton.BackgroundColor3 = autoFarmEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.2, 0.2)
end)

QuestButton.MouseButton1Click:Connect(function()
    toggleAutoQuest()
    QuestButton.Text = "Auto Quest: " .. (autoQuestEnabled and "ON" or "OFF")
    QuestButton.BackgroundColor3 = autoQuestEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.8, 0.8, 0.2)
end)

FlyButton.MouseButton1Click:Connect(function()
    toggleFly()
    FlyButton.Text = "Fly: " .. (flying and "ON" or "OFF")
    FlyButton.BackgroundColor3 = flying and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.2, 0.8, 0.2)
end)

ESPButton.MouseButton1Click:Connect(function()
    toggleESP()
    ESPButton.Text = "ESP Names: " .. (espEnabled and "ON" or "OFF")
    ESPButton.BackgroundColor3 = espEnabled and Color3.new(0.2, 0.8, 0.2) or Color3.new(0.2, 0.2, 0.8)
end)

-- Keybinds
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F then toggleFly() FlyButton.Text = "Fly: " .. (flying and "ON" or "OFF") end
    if input.KeyCode == Enum.KeyCode.G then toggleAutoFarm() FarmButton.Text = "Auto Farm Level: " .. (autoFarmEnabled and "ON" or "OFF") end
    if input.KeyCode == Enum.KeyCode.Q then toggleAutoQuest() QuestButton.Text = "Auto Quest: " .. (autoQuestEnabled and "ON" or "OFF") end
    if input.KeyCode == Enum.KeyCode.H then toggleESP() ESPButton.Text = "ESP Names: " .. (espEnabled and "ON" or "OFF") end
end)

-- Respawn Handler
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    hrp = character:WaitForChild("HumanoidRootPart")
    tool = character:FindFirstChildOfClass("Tool")
    if not tool then
        for _, t in pairs(character:GetChildren()) do
            if t:IsA("Tool") then tool = t; humanoid:EquipTool(t); break end
        end
    end
    currentQuestMob = nil
    killedCount = 0
end)

print("GUI โหลดเสร็จ! Third Sea Quests เพิ่มแล้ว (Lv1500+). เปิด Farm แล้ว Quest สำหรับฟาร์มอัตโนมัติ. กด G=Farm, Q=Quest, F=Fly, H=ESP")
print("CFrame จาก sources 2025 - ถ้าผิด tele ลองปรับใน ThirdSeaQuests. เพิ่ม Second Sea ได้ถ้าต้องการ!")
