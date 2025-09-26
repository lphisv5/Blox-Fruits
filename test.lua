-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

-- Local Player
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

-- Configuration
local Config = {
    Quests = {
        {Level = {0, 10}, Mob = "Bandit [Lv. 5]", MobName = "Bandit", QuestName = "BanditQuest1", QuestLevel = 1, CFrame = CFrame.new(1062.64697265625, 16.516624450683594, 1546.55224609375)},
        {Level = {11, 20}, Mob = "Monkey [Lv. 14]", MobName = "Monkey", QuestName = "JungleQuest", QuestLevel = 1, CFrame = CFrame.new(-1615.1883544921875, 36.85209655761719, 150.80490112304688)},
    },
    TeleportLocations = {
        {Name = "Pirate Island", CFrame = CFrame.new(1041.8861083984375, 16.273563385009766, 1424.93701171875)},
        {Name = "Marine Island", CFrame = CFrame.new(-2896.6865234375, 41.488861083984375, 2009.27490234375)},
        {Name = "Colosseum", CFrame = CFrame.new(-1541.0882568359375, 7.389348983764648, -2987.40576171875)},
        {Name = "Desert", CFrame = CFrame.new(1094.3209228515625, 6.569626808166504, 4231.6357421875)},
        {Name = "Fountain City", CFrame = CFrame.new(5529.7236328125, 429.35748291015625, 4245.5498046875)},
        {Name = "Jungle", CFrame = CFrame.new(-1615.1883544921875, 36.85209655761719, 150.80490112304688)},
        {Name = "Marine Fort", CFrame = CFrame.new(-4846.14990234375, 20.652048110961914, 4393.65087890625)},
        {Name = "Middle Town", CFrame = CFrame.new(-705.99755859375, 7.852255344390869, 1547.5216064453125)},
        {Name = "Prison", CFrame = CFrame.new(4841.84423828125, 5.651970863342285, 741.329833984375)},
        {Name = "Pirate Village", CFrame = CFrame.new(-1146.42919921875, 4.752060890197754, 3818.503173828125)},
        {Name = "Sky Island 1", CFrame = CFrame.new(-4967.8369140625, 717.6719970703125, -2623.84326171875)},
        {Name = "Sky Island 2", CFrame = CFrame.new(-7876.0771484375, 5545.58154296875, -381.19927978515625)},
        {Name = "Snow Island", CFrame = CFrame.new(1100.361328125, 5.290674209594727, -1151.5418701171875)},
        {Name = "Underwater City", CFrame = CFrame.new(61135.29296875, 18.47164535522461, 1597.6827392578125)},
        {Name = "Magma Village", CFrame = CFrame.new(-5248.27197265625, 8.699088096618652, 8452.890625)},
    },
    StatTypes = {"Melee", "Defense", "Sword", "Gun", "Demon Fruit"},
}

-- Global Settings (จาก Silver Hub)
_G.Settings = {
    Main = {["Auto Farm Level"] = false, ["Fast Auto Farm Level"] = false, ["Distance Mob Aura"] = 1000, ["Mob Aura"] = false},
    Configs = {["Fast Attack"] = true, ["Fast Attack Type"] = {"Fast"}, ["Select Weapon"] = {}, ["Auto Haki"] = true, ["Distance Auto Farm"] = 20},
}
local SelectWeapon = "Melee"
local PosMon = nil
local BringMobFarm = false
local SetCFarme = 1
local FastAttack = false
local cooldownfastattack = tick()

-- Initialize UI Library (ใช้ YANZ UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()
local Window = Library:Window({
    Title = "YANZ-Silver Hub",
    Desc = "Blox Fruits AutoFarm & More (Updated: 2025-09-27 06:26 AM +07)",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {Keybind = Enum.KeyCode.LeftControl, Size = UDim2.new(0, 500, 0, 400)},
    CloseUIButton = {Enabled = true, Text = "YANZ"}
})
local SidebarLine = Instance.new("Frame")
SidebarLine.Size = UDim2.new(0, 1, 1, 0)
SidebarLine.Position = UDim2.new(0, 140, 0, 0)
SidebarLine.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SidebarLine.BorderSizePixel = 0
SidebarLine.ZIndex = 5
SidebarLine.Name = "SidebarLine"
SidebarLine.Parent = CoreGui

-- Utility Functions
local function Notify(Title, Desc, Time)
    local timestamp = os.date("%Y-%m-%d %I:%M %p +07")
    Window:Notify({Title = Title, Desc = string.format("%s\n[Time: %s]", Desc, timestamp), Time = Time or 3})
end

local function StopTweens()
    for _, tween in pairs(ActiveTweens or {}) do tween:Cancel() end
    ActiveTweens = {}
end

local function TP(TargetCFrame)
    if not Character or not HumanoidRootPart then
        Notify("Error", "Character or HumanoidRootPart not found.")
        return
    end
    StopTweens()
    local Distance = (TargetCFrame.Position - HumanoidRootPart.Position).Magnitude
    local Speed = Distance < 10 and 1000 or Distance < 170 and 350 or Distance < 1000 and 350 or 300
    if Distance < 170 then
        HumanoidRootPart.CFrame = TargetCFrame
        return
    end
    local Tween = TweenService:Create(HumanoidRootPart, TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear), {CFrame = TargetCFrame})
    table.insert(ActiveTweens or {}, Tween)
    Tween:Play()
end

local function EquipTool(ToolName)
    for _, tool in pairs(LocalPlayer.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name == ToolName then
            HumanoidRootPart.Parent.Humanoid:EquipTool(tool)
            break
        end
    end
end

local function QuestCheck()
    local Lvl = LocalPlayer.Data.Level.Value
    if Lvl >= 1 and Lvl <= 9 then
        if tostring(LocalPlayer.Team) == "Marines" then
            return {1, CFrame.new(-2709.67944, 24.5206585, 2104.24585), "Trainee [Lv. 5]", "MarineQuest", 1, "Trainee"}
        elseif tostring(LocalPlayer.Team) == "Pirates" then
            return {1, CFrame.new(1059.99731, 16.9222069, 1549.28162), "Bandit [Lv. 5]", "BanditQuest1", 1, "Bandit"}
        end
    end
    -- เพิ่มการตรวจสอบเลเวลอื่น ๆ ตาม Silver Hub
    local GuideModule = require(game:GetService("ReplicatedStorage").GuideModule)
    local Quests = require(game:GetService("ReplicatedStorage").Quests)
    local NPCPosition, QuestLevel, LevelRequire = nil, 1, 0
    for i, v in pairs(GuideModule["Data"]["NPCList"]) do
        for i1, v1 in pairs(v["Levels"]) do
            if Lvl >= v1 and v1 > LevelRequire then
                NPCPosition = i["CFrame"]
                QuestLevel = i1
                LevelRequire = v1
            end
        end
    end
    for i, v in pairs(Quests) do
        for i1, v1 in pairs(v) do
            if v1["LevelReq"] == LevelRequire and i ~= "CitizenQuest" then
                local MobName = next(v1["Task"])
                return {QuestLevel, NPCPosition, MobName, i, LevelRequire, string.split(MobName, " [Lv. " .. LevelRequire .. "]")[1]}
            end
        end
    end
    return nil
end

local function toTarget(TargetCFrame)
    local Distance = (TargetCFrame.Position - HumanoidRootPart.Position).Magnitude
    local Speed = Distance < 1000 and 315 or 300
    local tween_s = game:service"TweenService"
    local info = TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear)
    local tween = tween_s:Create(HumanoidRootPart, info, {CFrame = TargetCFrame})
    tween:Play()
    return {Stop = function() tween:Cancel() end, Wait = function() tween.Completed:Wait() end}
end

-- Combat Framework (จาก Silver Hub)
local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
local CombatFrameworkR = getupvalues(CombatFramework)[2]
function getAllBladeHits(Sizes)
    local Hits = {}
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        local Human = v:FindFirstChildOfClass("Humanoid")
        if Human and Human.RootPart and Human.Health > 0 and (Human.RootPart.Position - HumanoidRootPart.Position).Magnitude < Sizes + 5 then
            table.insert(Hits, Human.RootPart)
        end
    end
    return Hits
end
function AttackFunction()
    local ac = CombatFrameworkR.activeController
    if ac and ac.equipped then
        local bladehit = getAllBladeHits(60)
        if #bladehit > 0 then
            ac:attack()
        end
    end
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    MainTab:Section({Title = "Autofarm Controls"})
    MainTab:Toggle({
        Title = "Auto Farm Level",
        Desc = "Enable/Disable Auto Farm Level",
        Value = _G.Settings.Main["Auto Farm Level"],
        Callback = function(state)
            _G.Settings.Main["Auto Farm Level"] = state
            _G.AutoFarmLevelReal = state
            Notify("AutoFarm", "Auto Farm Level " .. (state and "enabled" or "disabled"))
            if not state then StopTweens() end
            SaveSettings()
        end
    })
    MainTab:Toggle({
        Title = "Fast Attack",
        Desc = "Enable Fast Attack",
        Value = _G.Settings.Configs["Fast Attack"],
        Callback = function(state)
            _G.Settings.Configs["Fast Attack"] = state
            Notify("Combat", "Fast Attack " .. (state and "enabled" or "disabled"))
            SaveSettings()
        end
    })
    MainTab:Dropdown({
        Title = "Fast Attack Type",
        List = {"Fast", "Normal", "Slow"},
        Value = _G.Settings.Configs["Fast Attack Type"][1],
        Callback = function(value)
            _G.Settings.Configs["Fast Attack Type"] = {value}
            Notify("Combat", "Fast Attack Type set to " .. value)
            SaveSettings()
        end
    })
    MainTab:Dropdown({
        Title = "Select Weapon",
        List = {"Melee", "Sword", "Fruit"},
        Value = SelectWeapon,
        Callback = function(value)
            SelectWeapon = value
            Notify("Weapon", "Selected weapon type: " .. value)
        end
    })
    MainTab:Toggle({
        Title = "Auto Equip Weapon",
        Desc = "Automatically equip selected weapon",
        Value = false,
        Callback = function(state)
            _G.Settings.Configs["AutoEquip"] = state
            Notify("Auto Equip", "Auto Equip " .. (state and "enabled" or "disabled"))
        end
    })
end

-- Teleport Tab
local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map"}) do
    TeleportTab:Section({Title = "Teleport Locations"})
    for _, location in pairs(Config.TeleportLocations) do
        TeleportTab:Button({
            Title = location.Name,
            Desc = "Teleport to " .. location.Name,
            Callback = function()
                TP(location.CFrame)
                Notify("Teleport", "Teleporting to " .. location.Name)
            end
        })
    end
end

-- Settings Tab
local SettingsTab = Window:Tab({Title = "Settings", Icon = "wrench"}) do
    SettingsTab:Section({Title = "Configuration"})
    SettingsTab:Button({
        Title = "Destroy UI",
        Desc = "Close the UI and clean up",
        Callback = function()
            StopTweens()
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do v:Enable() end
            Window:Destroy()
            SidebarLine:Destroy()
            Notify("UI", "YANZ-Silver Hub UI destroyed and cleaned up.")
        end
    })
end

-- Auto Farm Loop
spawn(function()
    while wait() do
        pcall(function()
            if _G.AutoFarmLevelReal then
                local quest = QuestCheck()
                if not quest then
                    Notify("AutoFarm", "No quest found for your level!")
                    return
                end
                Notify("AutoFarm", "Quest: " .. quest[3] .. ", Level: " .. LocalPlayer.Data.Level.Value)
                if _G.Settings.Configs["AutoEquip"] and _G.Settings.Configs["Select Weapon"] then
                    EquipTool(_G.Settings.Configs["Select Weapon"])
                end
                local QuestC = LocalPlayer.PlayerGui.Main.Quest
                if QuestC.Visible then
                    if (quest[2].Position - HumanoidRootPart.Position).Magnitude >= 3000 then
                        TP(quest[2])
                        Notify("AutoFarm", "Teleporting to NPC...")
                    end
                    local enemy = Workspace.Enemies:FindFirstChild(quest[3])
                    if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                        repeat task.wait()
                            if not string.find(QuestC.Container.QuestTitle.Title.Text, quest[6]) then
                                ReplicatedStorage.Remotes.CommF_:InvokeServer("AbandonQuest")
                                Notify("AutoFarm", "Abandoning quest...")
                            else
                                PosMon = enemy.HumanoidRootPart.CFrame
                                enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                                enemy.HumanoidRootPart.CanCollide = false
                                toTarget(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 30, 5))
                                if _G.Settings.Configs["Fast Attack"] then AttackFunction() end
                            end
                        until not _G.AutoFarmLevelReal or not enemy.Parent or enemy.Humanoid.Health <= 0 or not QuestC.Visible
                    else
                        toTarget(quest[2])
                    end
                else
                    if (quest[2].Position - HumanoidRootPart.Position).Magnitude >= 3000 then
                        TP(quest[2])
                    else
                        toTarget(quest[2])
                        if (quest[2].Position - HumanoidRootPart.Position).Magnitude <= 20 then
                            ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", quest[4], quest[1])
                            Notify("AutoFarm", "Started quest: " .. quest[4])
                        end
                    end
                end
            end
        end)
    end
end)

-- Fast Attack Loop
spawn(function()
    while task.wait(0.1) do
        if _G.Settings.Configs["Fast Attack"] and _G.AutoFarmLevelReal then
            AttackFunction()
            if _G.Settings.Configs["Fast Attack Type"][1] == "Normal" then
                if tick() - cooldownfastattack > 0.9 then wait(0.1) cooldownfastattack = tick() end
            elseif _G.Settings.Configs["Fast Attack Type"][1] == "Fast" then
                if tick() - cooldownfastattack > 0.1 then wait(0.01) cooldownfastattack = tick() end
            elseif _G.Settings.Configs["Fast Attack Type"][1] == "Slow" then
                if tick() - cooldownfastattack > 0.3 then wait(0.7) cooldownfastattack = tick() end
            end
        end
    end
end)

-- Auto Haki
spawn(function()
    while wait() do
        if _G.Settings.Configs["Auto Haki"] then
            if not LocalPlayer.Character:FindFirstChild("HasBuso") then
                ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
            end
        end
    end
end)

-- Weapon Selection
task.spawn(function()
    while wait() do
        pcall(function()
            if SelectWeapon == "Melee" then
                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Melee" then _G.Settings.Configs["Select Weapon"] = v.Name end
                end
            elseif SelectWeapon == "Sword" then
                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Sword" then _G.Settings.Configs["Select Weapon"] = v.Name end
                end
            elseif SelectWeapon == "Fruit" then
                for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                    if v.ToolTip == "Blox Fruit" then _G.Settings.Configs["Select Weapon"] = v.Name end
                end
            end
        end)
    end
end)

-- Initial Notification
Notify("YANZ-Silver Hub", "Script loaded successfully! (Updated: 2025-09-27 06:26 AM +07)", 4)

-- Save Settings Function (จาก Silver Hub)
function SaveSettings()
    if readfile and writefile and isfile and isfolder then
        if not isfolder("YANZ-Silver Hub") then makefolder("YANZ-Silver Hub") end
        if not isfile("YANZ-Silver Hub/" .. LocalPlayer.Name .. ".json") then
            writefile("YANZ-Silver Hub/" .. LocalPlayer.Name .. ".json", game:GetService("HttpService"):JSONEncode(_G.Settings))
        else
            writefile("YANZ-Silver Hub/" .. LocalPlayer.Name .. ".json", game:GetService("HttpService"):JSONEncode(_G.Settings))
        end
    end
end
