-- ROBLOX LUA SCRIPT - YANZ Executor Beta v0.0.1
-- GUI Horizontal Layout

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Config
local Config = {
    InfiniteJump = false,
    ClickTeleport = false,
    AutoFarm = false,
    AutoCast = false,
    AutoShake = false,
    AutoReel = false,
    AutoCollect = false,
    AutoSell = false,
    AutoSellAll = false,
    ReduceLag = false,
    AntiCrash = false,
    ScreenWhite = false,
    ScreenBlack = false,
    AutoReconnect = false,
    SavedPosition = nil,
    SelectedRod = "",
    SelectedSell = "",
    SelectedZone = ""
}

-- Save/Load Config
local function SaveConfig()
    local json = game:GetService("HttpService"):JSONEncode(Config)
    writefile("YanzConfig.json", json)
end

local function LoadConfig()
    if isfile("YanzConfig.json") then
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile("YanzConfig.json"))
        end)
        if success then
            Config = result
        end
    end
end

LoadConfig()

-- GUI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
local theme = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Themes/Dark.lua"))()

local Window = library:CreateWindow({
    Title = "YANZ | BETA - v0.0.1",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

library:SetTheme(theme)

-- Tabs
local HomeTab = Window:AddTab('Home')
local MainTab = Window:AddTab('Main')
local SellerTab = Window:AddTab('Seller')
local TeleportTab = Window:AddTab('Teleport')
local MiscTab = Window:AddTab('Miscellaneous')
local SettingsTab = Window:AddTab('Settings')

-- Home Tab
local HomeSection = HomeTab:AddLeftGroupbox('Home')

HomeSection:AddButton('Discord Invite', function()
    setclipboard("https://discord.gg/yanz")
    library:Notify("Discord invite copied to clipboard!")
end)

HomeSection:AddToggle('InfiniteJump', {
    Text = 'Infinite Jump',
    Default = Config.InfiniteJump,
    Tooltip = 'Toggle infinite jump'
})

local InfiniteJumpConnection
Toggles.InfiniteJump:OnChanged(function()
    Config.InfiniteJump = Toggles.InfiniteJump.Value
    SaveConfig()
    
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
    end
    
    if Toggles.InfiniteJump.Value then
        InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end)

HomeSection:AddToggle('ClickTeleport', {
    Text = 'CTRL + Click to Teleport',
    Default = Config.ClickTeleport,
    Tooltip = 'Hold CTRL and click to teleport'
})

Toggles.ClickTeleport:OnChanged(function()
    Config.ClickTeleport = Toggles.ClickTeleport.Value
    SaveConfig()
end)

local ClickTeleportConnection
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Toggles.ClickTeleport.Value then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

-- Main Tab
local MainSection = MainTab:AddLeftGroupbox('Fishing')

local RodDropdown = MainSection:AddDropdown('RodSelect', {
    Values = {'None'},
    Default = 1,
    Multi = false,
    Text = 'Choose Rod Equip',
    Tooltip = 'Select fishing rod to equip'
})

MainSection:AddButton('Refresh Choose Rod Equip', function()
    local rods = {}
    if LocalPlayer.Character then
        for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(tool.Name:lower(), "rod") then
                table.insert(rods, tool.Name)
            end
        end
    end
    RodDropdown:SetValues(rods)
    if #rods > 0 then
        RodDropdown:SetValue(rods[1])
    end
end)

Options.RodSelect:OnChanged(function()
    Config.SelectedRod = Options.RodSelect.Value
    SaveConfig()
end)

MainSection:AddButton('Save Position', function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        Config.SavedPosition = LocalPlayer.Character.HumanoidRootPart.Position
        SaveConfig()
        library:Notify("Position saved!")
    end
end)

MainSection:AddButton('Reset Save Position', function()
    Config.SavedPosition = nil
    SaveConfig()
    library:Notify("Position reset!")
end)

MainSection:AddButton('Teleport To Saved Position', function()
    if Config.SavedPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Config.SavedPosition)
    end
end)

MainSection:AddToggle('AutoFarm', {
    Text = 'Auto Farm Fish',
    Default = Config.AutoFarm,
    Tooltip = 'Automatically farm fish'
})

Toggles.AutoFarm:OnChanged(function()
    Config.AutoFarm = Toggles.AutoFarm.Value
    SaveConfig()
end)

MainSection:AddToggle('AutoCast', {
    Text = 'Auto Click Cast',
    Default = Config.AutoCast,
    Tooltip = 'Automatically cast fishing rod'
})

Toggles.AutoCast:OnChanged(function()
    Config.AutoCast = Toggles.AutoCast.Value
    SaveConfig()
end)

MainSection:AddToggle('AutoShake', {
    Text = 'Auto Click Shake',
    Default = Config.AutoShake,
    Tooltip = 'Automatically shake when fish bites'
})

Toggles.AutoShake:OnChanged(function()
    Config.AutoShake = Toggles.AutoShake.Value
    SaveConfig()
end)

MainSection:AddToggle('AutoReel', {
    Text = 'Auto Click Reel',
    Default = Config.AutoReel,
    Tooltip = 'Automatically reel in fish'
})

Toggles.AutoReel:OnChanged(function()
    Config.AutoReel = Toggles.AutoReel.Value
    SaveConfig()
end)

MainSection:AddToggle('AutoCollect', {
    Text = 'Auto Collect Item',
    Default = Config.AutoCollect,
    Tooltip = 'Automatically collect items'
})

Toggles.AutoCollect:OnChanged(function()
    Config.AutoCollect = Toggles.AutoCollect.Value
    SaveConfig()
end)

-- Auto Fishing Function
local function AutoFish()
    if not Toggles.AutoFarm.Value then return end
    
    -- Equip selected rod
    if Config.SelectedRod ~= "" then
        local rod = LocalPlayer.Backpack:FindFirstChild(Config.SelectedRod)
        if rod then
            LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):EquipTool(rod)
        end
    end
    
    -- Auto cast
    if Toggles.AutoCast.Value then
        -- Simulate cast action
        game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.5)
        game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end
    
    -- Auto shake and reel would be implemented based on game-specific detection
end

-- Seller Tab
local SellerSection = SellerTab:AddLeftGroupbox('Auto Seller')

local SellDropdown = SellerSection:AddDropdown('SellSelect', {
    Values = {'All', 'Common', 'Rare', 'Legendary'},
    Default = 1,
    Multi = false,
    Text = 'Choose Sell',
    Tooltip = 'Select what to sell'
})

Options.SellSelect:OnChanged(function()
    Config.SelectedSell = Options.SellSelect.Value
    SaveConfig()
end)

SellerSection:AddToggle('AutoSell', {
    Text = 'Auto Sell',
    Default = Config.AutoSell,
    Tooltip = 'Automatically sell selected items'
})

Toggles.AutoSell:OnChanged(function()
    Config.AutoSell = Toggles.AutoSell.Value
    SaveConfig()
end)

SellerSection:AddToggle('AutoSellAll', {
    Text = 'Auto Sell All',
    Default = Config.AutoSellAll,
    Tooltip = 'Automatically sell all items'
})

Toggles.AutoSellAll:OnChanged(function()
    Config.AutoSellAll = Toggles.AutoSellAll.Value
    SaveConfig()
end)

-- Teleport Tab
local TeleportSection = TeleportTab:AddLeftGroupbox('Zones')

local ZoneDropdown = TeleportSection:AddDropdown('ZoneSelect', {
    Values = {'Spawn', 'Fishing Area', 'Shop', 'Sell Area'},
    Default = 1,
    Multi = false,
    Text = 'Choose Zone',
    Tooltip = 'Select zone to teleport to'
})

Options.ZoneSelect:OnChanged(function()
    Config.SelectedZone = Options.ZoneSelect.Value
    SaveConfig()
end)

TeleportSection:AddButton('Teleport To Zone', function()
    local zone = Options.ZoneSelect.Value
    local targetCFrame
    
    if zone == "Spawn" then
        targetCFrame = CFrame.new(0, 10, 0)
    elseif zone == "Fishing Area" then
        targetCFrame = CFrame.new(100, 10, 0)
    elseif zone == "Shop" then
        targetCFrame = CFrame.new(-100, 10, 0)
    elseif zone == "Sell Area" then
        targetCFrame = CFrame.new(0, 10, 100)
    end
    
    if targetCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
    end
end)

-- Miscellaneous Tab
local MiscSection = MiscTab:AddLeftGroupbox('Performance')

MiscSection:AddToggle('ReduceLag', {
    Text = 'Reduce Lag',
    Default = Config.ReduceLag,
    Tooltip = 'Reduce game lag'
})

Toggles.ReduceLag:OnChanged(function()
    Config.ReduceLag = Toggles.ReduceLag.Value
    SaveConfig()
    
    if Toggles.ReduceLag.Value then
        -- Reduce graphics quality
        settings().Rendering.QualityLevel = 1
        -- Reduce particle effects
        for _, effect in ipairs(Lighting:GetChildren()) do
            if effect:IsA("ParticleEmitter") then
                effect.Enabled = false
            end
        end
    end
end)

MiscSection:AddToggle('AntiCrash', {
    Text = 'Anti-Crash',
    Default = Config.AntiCrash,
    Tooltip = 'Prevent game crashes'
})

Toggles.AntiCrash:OnChanged(function()
    Config.AntiCrash = Toggles.AntiCrash.Value
    SaveConfig()
end)

local VisualSection = MiscTab:AddRightGroupbox('Visual')

VisualSection:AddToggle('ScreenWhite', {
    Text = 'Show Screen White',
    Default = Config.ScreenWhite,
    Tooltip = 'Make screen white'
})

Toggles.ScreenWhite:OnChanged(function()
    Config.ScreenWhite = Toggles.ScreenWhite.Value
    SaveConfig()
    
    if Toggles.ScreenWhite.Value then
        Toggles.ScreenBlack:SetValue(false)
        Lighting.Brightness = 10
        Lighting.Ambient = Color3.new(1, 1, 1)
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    end
end)

VisualSection:AddToggle('ScreenBlack', {
    Text = 'Show Screen Black',
    Default = Config.ScreenBlack,
    Tooltip = 'Make screen black'
})

Toggles.ScreenBlack:OnChanged(function()
    Config.ScreenBlack = Toggles.ScreenBlack.Value
    SaveConfig()
    
    if Toggles.ScreenBlack.Value then
        Toggles.ScreenWhite:SetValue(false)
        Lighting.Brightness = 0
        Lighting.Ambient = Color3.new(0, 0, 0)
    else
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
    end
end)

VisualSection:AddToggle('AutoReconnect', {
    Text = 'Auto Reconnect',
    Default = Config.AutoReconnect,
    Tooltip = 'Automatically reconnect if disconnected'
})

Toggles.AutoReconnect:OnChanged(function()
    Config.AutoReconnect = Toggles.AutoReconnect.Value
    SaveConfig()
end)

-- Settings Tab
local SettingsSection = SettingsTab:AddLeftGroupbox('Configuration')

SettingsSection:AddButton('Reset Script Config', function()
    Config = {
        InfiniteJump = false,
        ClickTeleport = false,
        AutoFarm = false,
        AutoCast = false,
        AutoShake = false,
        AutoReel = false,
        AutoCollect = false,
        AutoSell = false,
        AutoSellAll = false,
        ReduceLag = false,
        AntiCrash = false,
        ScreenWhite = false,
        ScreenBlack = false,
        AutoReconnect = false,
        SavedPosition = nil,
        SelectedRod = "",
        SelectedSell = "",
        SelectedZone = ""
    }
    SaveConfig()
    
    -- Reset all toggles
    for name, toggle in pairs(Toggles) do
        toggle:SetValue(false)
    end
    
    library:Notify("Configuration reset!")
end)

-- Auto Reconnect
local function AutoReconnect()
    if not Toggles.AutoReconnect.Value then return end
    
    game:GetService("CoreGui").ChildRemoved:Connect(function(child)
        if child.Name == "RobloxGui" then
            wait(5)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end

-- Anti-Crash
if Toggles.AntiCrash.Value then
    local function safeCall(func)
        return pcall(func)
    end
    
    setfpscap(60)
end

-- Main Loop
RunService.Heartbeat:Connect(function()
    if Toggles.AutoFarm.Value then
        AutoFish()
    end
end)

-- Initialize
library:Notify("YANZ Script Loaded! v0.0.1")
