-- LocalScript: Full Third Sea Auto Farm (Study)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ===== CONFIG =====
local flyHeight = 10          -- ความสูงลอยตัว
local attackSpeed = 0.001      -- ระยะเวลาระหว่างตี (ตัวอย่างศึกษา)
local autoFarm = false
local targetName = nil

-- ===== รายชื่อมอนสเตอร์ Third Sea (รวมทุกเกาะ) =====
local monsters = {
    -- Port Town
    "Stone Pirate", "Millionaire Pistol", "Billionaire",
    -- Hydra Island
    "Dragon Crew Warrior", "Dragon Crew Archer", "Hydra Enforcer", "Kilo Admiral",
    -- Great Tree
    "Marine Commodore", "Marine Rear Admiral", "Fishman Raider", "Fishman Captain",
    -- Floating Turtle
    "Forest Pirate", "Jungle Pirate", "Musketeer Pirate", "Mythological Pirate Captain", "Elephant",
    -- Haunted Castle
    "Beautiful Pirate", "Death King", "Uzoth", "Soul Reaper", "Cursed Skeleton",
    "Crypt Master", "Dark Blade", "Dark Dagger", "Deandre", "Diablo",
    -- Sea of Treats
    "Urban Cake Prince", "Dough King", "Cocoa Warrior", "Scout", "Chef", "Guard",
    -- Tiki Outpost
    "Tiki Warrior", "Tiki Shaman", "Barista", "Cousin Banana (Hungry Man quest spawn)",
    "Temple of Time (NPC variant)", "Ghost (various haunted spawns)"
}

-- ===== GUI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")

-- Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,300,0,150)
frame.Position = UDim2.new(0,10,0,10)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = ScreenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,25)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Third Sea Auto Farm"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.Parent = frame

-- Dropdown (Selection)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0.8,0,0,30)
dropdown.Position = UDim2.new(0.1,0,0,35)
dropdown.Text = "Select Monster"
dropdown.BackgroundColor3 = Color3.fromRGB(70,70,70)
dropdown.TextColor3 = Color3.fromRGB(255,255,255)
dropdown.Parent = frame

local listFrame = Instance.new("Frame")
listFrame.Size = UDim2.new(0.8,0,0,100)
listFrame.Position = UDim2.new(0.1,0,0,70)
listFrame.BackgroundColor3 = Color3.fromRGB(50,50,50)
listFrame.Visible = false
listFrame.Parent = frame

-- เพิ่มรายการลง Dropdown
for i, name in ipairs(monsters) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1,0,0,20)
    btn.Position = UDim2.new(0,0,0,(i-1)*20)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(80,80,80)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = listFrame
    btn.MouseButton1Click:Connect(function()
        targetName = name
        dropdown.Text = "Target: " .. name
        listFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    listFrame.Visible = not listFrame.Visible
end)

-- Toggle Auto Farm
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8,0,0,30)
toggleButton.Position = UDim2.new(0.1,0,0,120)
toggleButton.Text = "Auto Farm: OFF"
toggleButton.BackgroundColor3 = Color3.fromRGB(70,70,70)
toggleButton.TextColor3 = Color3.fromRGB(255,255,255)
toggleButton.Parent = frame

toggleButton.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    toggleButton.Text = "Auto Farm: " .. (autoFarm and "ON" or "OFF")
end)

-- ===== FUNCTIONS =====
local function findMonster(name)
    for _, npc in pairs(workspace:GetChildren()) do
        if npc:IsA("Model") and npc.Name == name then
            local humanoid = npc:FindFirstChild("Humanoid")
            if humanoid then
                return npc
            end
        end
    end
end

local function tpToMonster(monster)
    if monster and monster:FindFirstChild("HumanoidRootPart") then
        humanoidRootPart.CFrame = monster.HumanoidRootPart.CFrame + Vector3.new(0, flyHeight, 0)
    end
end

local function getMonsterInfo(monster)
    if monster and monster:FindFirstChild("Humanoid") then
        local humanoid = monster.Humanoid
        local level = monster:FindFirstChild("Level") and monster.Level.Value or "Unknown"
        local armor = monster:FindFirstChild("Armor") and monster.Armor.Value or "Unknown"
        local hp = humanoid.Health
        local pos = monster:FindFirstChild("HumanoidRootPart") and monster.HumanoidRootPart.Position or Vector3.new(0,0,0)
        return level, armor, hp, pos
    end
    return nil,nil,nil,nil
end

local function attackMonster(monster)
    if monster and monster:FindFirstChild("Humanoid") then
        monster.Humanoid:TakeDamage(1) -- ตัวอย่างศึกษา
    end
end

-- ===== AUTO FARM LOOP =====
RunService.RenderStepped:Connect(function()
    if autoFarm and targetName then
        local target = findMonster(targetName)
        if target then
            tpToMonster(target)
            local level, armor, hp, pos = getMonsterInfo(target)
            print(string.format("Target: %s | Level: %s | Armor: %s | HP: %.1f | Pos: %.1f, %.1f, %.1f",
                target.Name, level, armor, hp, pos.X, pos.Y, pos.Z))
            attackMonster(target)
            wait(attackSpeed)
        end
    end
end)

print("Third Sea Auto Farm Loaded. Use GUI to select monster and toggle Auto Farm.")
