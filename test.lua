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

-- Configuration (Updated 2025-09-27)
local Config = {
    Quests = {
        {Level = {0, 10}, Mob = "Bandit [Lv. 5]", MobName = "Bandit", QuestName = "BanditQuest1", QuestLevel = 1, CFrame = CFrame.new(1062.64697265625, 16.516624450683594, 1546.55224609375)},
        {Level = {11, 20}, Mob = "Monkey [Lv. 14]", MobName = "Monkey", QuestName = "JungleQuest", QuestLevel = 1, CFrame = CFrame.new(-1615.1883544921875, 36.85209655761719, 150.80490112304688)},
        -- Placeholder for future levels (e.g., 21-30, etc.)
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

-- Global Variables
local Tools = {}
local SelectedWeapon = nil
local AutoFarm = false
local AutoStat = {}
local CurrentQuest = nil
local ActiveTweens = {}
local AutoEquip = false

-- Initialize UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Main Window
local Window = Library:Window({
    Title = "YANZ HUB",
    Desc = "YANZ HUB - Blox Fruits Autofarm & More",
    Icon = 105059922903197,
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.LeftControl,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "YANZ"
    }
})

-- Sidebar Vertical Separator
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
    Window:Notify({
        Title = Title,
        Desc = string.format("%s\n[Time: %s]", Desc, timestamp),
        Time = Time or 3
    })
end

local function StopTweens()
    for _, tween in pairs(ActiveTweens) do
        tween:Cancel()
    end
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
    local Tween = TweenService:Create(
        HumanoidRootPart,
        TweenInfo.new(Distance / Speed, Enum.EasingStyle.Linear),
        {CFrame = TargetCFrame}
    )
    table.insert(ActiveTweens, Tween)
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

local function CheckQuest()
    local Level = LocalPlayer.Data.Level.Value
    for _, quest in pairs(Config.Quests) do
        if Level >= quest.Level[1] and Level <= quest.Level[2] then
            CurrentQuest = quest
            return
        end
    end
    CurrentQuest = nil
    Notify("Error", "No suitable quest found for your level.")
end

local function AllocateStat(StatType)
    local args = {
        [1] = "AddPoint",
        [2] = StatType,
        [3] = 1
    }
    ReplicatedStorage.Remotes.CommF_:InvokeServer(unpack(args))
end

-- Initialize Tools
for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
    if v:IsA("Tool") then
        table.insert(Tools, v.Name)
    end
end

-- Anti-AFK
for _, v in pairs(getconnections(LocalPlayer.Idled)) do
    v:Disable()
end

-- Main Tab
local MainTab = Window:Tab({Title = "Main", Icon = "star"}) do
    MainTab:Section({Title = "Autofarm Controls"})

    MainTab:Dropdown({
        Title = "Select Weapon",
        List = Tools,
        Value = Tools[1] or "None",
        Callback = function(choice)
            SelectedWeapon = choice
            Notify("Weapon", "Selected weapon: " .. choice)
        end
    })

    MainTab:Button({
        Title = "Refresh Tools",
        Desc = "Refresh the tool list",
        Callback = function()
            Tools = {}
            for _, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                if v:IsA("Tool") then
                    table.insert(Tools, v.Name)
                end
            end
            MainTab:Dropdown({
                Title = "Select Weapon",
                List = Tools,
                Value = SelectedWeapon or Tools[1] or "None",
                Callback = function(choice)
                    SelectedWeapon = choice
                    Notify("Weapon", "Selected weapon: " .. choice)
                end
            })
            Notify("Tools", "Tool list refreshed.")
        end
    })

    MainTab:Button({
        Title = "Reset Status",
        Desc = "Reset the status display",
        Callback = function()
            local StatusCode = MainTab:Code({
                Title = "Status",
                Code = "1. AutoFarm: Off\n2. Selected Weapon: None"
            })
            Notify("Status", "Status display reset.")
        end
    })

    MainTab:Toggle({
        Title = "AutoFarm",
        Desc = "Enable/Disable AutoFarm",
        Value = false,
        Callback = function(state)
            AutoFarm = state
            Notify("AutoFarm", "AutoFarm " .. (state and "enabled" or "disabled"))
            if not state then
                StopTweens()
            end
        end
    })

    MainTab:Toggle({
        Title = "Auto Equip Weapon",
        Desc = "Automatically equip selected weapon",
        Value = false,
        Callback = function(state)
            AutoEquip = state
            Notify("Auto Equip", "Auto Equip Weapon " .. (state and "enabled" or "disabled"))
        end
    })

    MainTab:Textbox({
        Title = "Set Level",
        Desc = "Set your level (for testing)",
        Placeholder = "Enter level",
        Value = "",
        ClearTextOnFocus = false,
        Callback = function(level)
            pcall(function()
                local num = tonumber(level)
                if num then
                    LocalPlayer.Data.Level.Value = num
                    Notify("Level", "Level set to " .. num)
                else
                    Notify("Error", "Invalid level value.")
                end
            end)
        end
    })

    -- Status Code Block
    local StatusCode = MainTab:Code({
        Title = "Status",
        Code = "1. AutoFarm: Off\n2. Selected Weapon: None"
    })

    -- Update Status Function
    spawn(function()
        while task.wait(1) do
            local statusText = string.format(
                "1. AutoFarm: %s\n2. Selected Weapon: %s",
                AutoFarm and "On" or "Off",
                SelectedWeapon or "None"
            )
            StatusCode:SetCode(statusText)
        end
    end)
end

-- Stats Tab
local StatsTab = Window:Tab({Title = "Stats", Icon = "bar-chart"}) do
    StatsTab:Section({Title = "Auto Stats Allocation"})

    for _, stat in pairs(Config.StatTypes) do
        StatsTab:Toggle({
            Title = "Auto " .. stat,
            Desc = "Auto allocate " .. stat .. " stats",
            Value = false,
            Callback = function(state)
                AutoStat[stat] = state
                Notify("Stats", "Auto " .. stat .. " " .. (state and "enabled" or "disabled"))
            end
        })
    end
end

-- Teleport Tab
local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map"}) do
    TeleportTab:Section({Title = "Teleport Locations"})

    for _, location in pairs(Config.TeleportLocations) do
        TeleportTab:Button({
            Title = location.Name,
            Desc = "Teleport to " .. location.Name,
            Callback = function()
                pcall(function()
                    TP(location.CFrame)
                    Notify("Teleport", "Teleporting to " .. location.Name)
                end)
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
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                v:Enable()
            end
            Window:Destroy()
            SidebarLine:Destroy()
            Notify("UI", "YANZ HUB UI destroyed and cleaned up.")
        end
    })
end

-- Autofarm Loop
spawn(function()
    while task.wait() do
        if AutoFarm then
            pcall(function()
                CheckQuest()
                if not CurrentQuest then
                    Notify("AutoFarm", "No quest available for your level.")
                    return
                end
                Notify("AutoFarm", "Checking quest: " .. CurrentQuest.QuestName)
                if AutoEquip and SelectedWeapon then
                    EquipTool(SelectedWeapon)
                    Notify("AutoFarm", "Equipped weapon: " .. SelectedWeapon)
                end
                if LocalPlayer.PlayerGui.Main.Quest.Visible == false then
                    Notify("AutoFarm", "Teleporting to quest location.")
                    TP(CurrentQuest.CFrame)
                    task.wait(2) -- เพิ่มเวลารอให้แน่ใจว่าถึงจุดหมาย
                    local success, err = pcall(function()
                        ReplicatedStorage.Remotes.CommF_:InvokeServer("StartQuest", CurrentQuest.QuestName, CurrentQuest.QuestLevel)
                    end)
                    if success then
                        Notify("Quest", "Started quest: " .. CurrentQuest.QuestName)
                    else
                        Notify("Error", "Failed to start quest: " .. (err or "Unknown error"))
                    end
                else
                    local enemyFound = false
                    for _, enemy in pairs(Workspace.Enemies:GetChildren()) do
                        if enemy.Name == CurrentQuest.Mob and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                            enemyFound = true
                            Notify("AutoFarm", "Found enemy: " .. enemy.Name)
                            TP(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 20, 0))
                            enemy.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
                            break
                        end
                    end
                    if not enemyFound then
                        Notify("AutoFarm", "No valid enemy found for " .. CurrentQuest.Mob)
                    end
                end
            end)
        end
    end
end)

-- Auto Attack
spawn(function()
    RunService.RenderStepped:Connect(function()
        if AutoFarm then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0, 1))
            end)
        end
    end)
end)

-- Auto Stats
spawn(function()
    while task.wait(30) do
        pcall(function()
            for stat, enabled in pairs(AutoStat) do
                if enabled then
                    AllocateStat(stat)
                end
            end
        end)
    end
end)

-- Tool Updates
LocalPlayer.Backpack.DescendantAdded:Connect(function(tool)
    if tool:IsA("Tool") then
        table.insert(Tools, tool.Name)
        MainTab:Dropdown({
            Title = "Select Weapon",
            List = Tools,
            Value = SelectedWeapon or Tools[1] or "None",
            Callback = function(choice)
                SelectedWeapon = choice
                Notify("Weapon", "Selected weapon: " .. choice)
            end
        })
        Notify("Tools", "Added tool: " .. tool.Name)
    end
end)

LocalPlayer.Backpack.DescendantRemoving:Connect(function(tool)
    if tool:IsA("Tool") then
        for i, v in pairs(Tools) do
            if v == tool.Name then
                table.remove(Tools, i)
                break
            end
        end
        MainTab:Dropdown({
            Title = "Select Weapon",
            List = Tools,
            Value = SelectedWeapon or Tools[1] or "None",
            Callback = function(choice)
                SelectedWeapon = choice
                Notify("Weapon", "Selected weapon: " .. choice)
            end
        })
        Notify("Tools", "Removed tool: " .. tool.Name)
    end
end)

-- Initial Notification
Notify("YANZ HUB", "YANZ HUB loaded successfully! (Updated: 2025-09-27 06:30 AM +07)", 4)
