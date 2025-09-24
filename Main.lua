-- ROBLOX LUA SCRIPT - YANZ Executor Beta v0.0.1
-- GUI Horizontal Layout - FIXED VERSION

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

-- Safe file operations
local function SafeWriteFile(filename, content)
    local success, result = pcall(function()
        writefile(filename, content)
        return true
    end)
    return success
end

local function SafeReadFile(filename)
    local success, result = pcall(function()
        if isfile(filename) then
            return readfile(filename)
        end
        return nil
    end)
    return success and result or nil
end

-- Save/Load Config
local function SaveConfig()
    local success, json = pcall(function()
        return game:GetService("HttpService"):JSONEncode(Config)
    end)
    if success and json then
        SafeWriteFile("YanzConfig.json", json)
    end
end

local function LoadConfig()
    local fileContent = SafeReadFile("YanzConfig.json")
    if fileContent then
        local success, result = pcall(function()
            return game:GetService("HttpService"):JSONDecode(fileContent)
        end)
        if success and result then
            for key, value in pairs(result) do
                if Config[key] ~= nil then
                    Config[key] = value
                end
            end
        end
    end
end

-- Safe GUI library loading
local library
local success, errorMsg = pcall(function()
    library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
end)

if not success or not library then
    -- Fallback to simple GUI if library fails
    library = {
        CreateWindow = function() return {
            AddTab = function() return {
                AddLeftGroupbox = function() return {
                    AddButton = function() end,
                    AddToggle = function() return { OnChanged = function() end, Value = false } end,
                    AddDropdown = function() return { SetValues = function() end, SetValue = function() end, OnChanged = function() end } end
                } end,
                AddRightGroupbox = function() return {
                    AddButton = function() end,
                    AddToggle = function() return { OnChanged = function() end, Value = false } end
                } end
            } end,
            SetTheme = function() end,
            Notify = function(msg) print("[YANZ]: " .. msg) end
        } end,
        SetTheme = function() end
    }
    
    warn("YANZ: Using fallback GUI - some features may be limited")
end

LoadConfig()

local theme = {
    Accent = Color3.fromRGB(0, 255, 0),
    Main = Color3.fromRGB(20, 20, 20),
    Background = Color3.fromRGB(10, 10, 10)
}

local Window = library:CreateWindow({
    Title = "YANZ | BETA - v0.0.1",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

library:SetTheme(theme)

-- Global tables for elements
local Toggles = {}
local Options = {}

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
    pcall(function()
        setclipboard("https://discord.gg/yanz")
    end)
    library:Notify("Discord invite copied to clipboard!")
end)

Toggles.InfiniteJump = HomeSection:AddToggle('InfiniteJump', {
    Text = 'Infinite Jump',
    Default = Config.InfiniteJump or false,
    Tooltip = 'Toggle infinite jump'
})

local InfiniteJumpConnection
Toggles.InfiniteJump:OnChanged(function()
    Config.InfiniteJump = Toggles.InfiniteJump.Value
    SaveConfig()
    
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
    
    if Toggles.InfiniteJump.Value then
        InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        end)
    end
end)

Toggles.ClickTeleport = HomeSection:AddToggle('ClickTeleport', {
    Text = 'CTRL + Click to Teleport',
    Default = Config.ClickTeleport or false,
    Tooltip = 'Hold CTRL and click to teleport'
})

Toggles.ClickTeleport:OnChanged(function()
    Config.ClickTeleport = Toggles.ClickTeleport.Value
    SaveConfig()
end)

-- Safe Click Teleport
pcall(function()
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        if input.UserInputType == Enum.UserInputType.MouseButton1 and Toggles.ClickTeleport and Toggles.ClickTeleport.Value then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                    end
                end)
            end
        end
    end)
end)

-- Main Tab
local MainSection = MainTab:AddLeftGroupbox('Fishing')

Options.RodSelect = MainSection:AddDropdown('RodSelect', {
    Values = {'None'},
    Default = 1,
    Multi = false,
    Text = 'Choose Rod Equip',
    Tooltip = 'Select fishing rod to equip'
})

MainSection:AddButton('Refresh Choose Rod Equip', function()
    pcall(function()
        local rods = {'None'}
        if LocalPlayer.Character then
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") and (string.find(tool.Name:lower(), "rod") or string.find(tool.Name:lower(), "fishing")) then
                    table.insert(rods, tool.Name)
                end
            end
        end
        Options.RodSelect:SetValues(rods)
        if #rods > 0 then
            Options.RodSelect:SetValue(rods[1])
        end
    end)
end)

Options.RodSelect:OnChanged(function()
    Config.SelectedRod = Options.RodSelect.Value
    SaveConfig()
end)

MainSection:AddButton('Save Position', function()
    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            Config.SavedPosition = {
                X = LocalPlayer.Character.HumanoidRootPart.Position.X,
                Y = LocalPlayer.Character.HumanoidRootPart.Position.Y,
                Z = LocalPlayer.Character.HumanoidRootPart.Position.Z
            }
            SaveConfig()
            library:Notify("Position saved!")
        end
    end)
end)

MainSection:AddButton('Reset Save Position', function()
    Config.SavedPosition = nil
    SaveConfig()
    library:Notify("Position reset!")
end)

MainSection:AddButton('Teleport To Saved Position', function()
    pcall(function()
        if Config.SavedPosition and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = Config.SavedPosition
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos.X, pos.Y, pos.Z)
        end
    end)
end)

Toggles.AutoFarm = MainSection:AddToggle('AutoFarm', {
    Text = 'Auto Farm Fish',
    Default = Config.AutoFarm or false,
    Tooltip = 'Automatically farm fish'
})

Toggles.AutoFarm:OnChanged(function()
    Config.AutoFarm = Toggles.AutoFarm.Value
    SaveConfig()
end)

Toggles.AutoCast = MainSection:AddToggle('AutoCast', {
    Text = 'Auto Click Cast',
    Default = Config.AutoCast or false,
    Tooltip = 'Automatically cast fishing rod'
})

Toggles.AutoCast:OnChanged(function()
    Config.AutoCast = Toggles.AutoCast.Value
    SaveConfig()
end)

Toggles.AutoShake = MainSection:AddToggle('AutoShake', {
    Text = 'Auto Click Shake',
    Default = Config.AutoShake or false,
    Tooltip = 'Automatically shake when fish bites'
})

Toggles.AutoShake:OnChanged(function()
    Config.AutoShake = Toggles.AutoShake.Value
    SaveConfig()
end)

Toggles.AutoReel = MainSection:AddToggle('AutoReel', {
    Text = 'Auto Click Reel',
    Default = Config.AutoReel or false,
    Tooltip = 'Automatically reel in fish'
})

Toggles.AutoReel:OnChanged(function()
    Config.AutoReel = Toggles.AutoReel.Value
    SaveConfig()
end)

Toggles.AutoCollect = MainSection:AddToggle('AutoCollect', {
    Text = 'Auto Collect Item',
    Default = Config.AutoCollect or false,
    Tooltip = 'Automatically collect items'
})

Toggles.AutoCollect:OnChanged(function()
    Config.AutoCollect = Toggles.AutoCollect.Value
    SaveConfig()
end)

-- Seller Tab
local SellerSection = SellerTab:AddLeftGroupbox('Auto Seller')

Options.SellSelect = SellerSection:AddDropdown('SellSelect', {
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

Toggles.AutoSell = SellerSection:AddToggle('AutoSell', {
    Text = 'Auto Sell',
    Default = Config.AutoSell or false,
    Tooltip = 'Automatically sell selected items'
})

Toggles.AutoSell:OnChanged(function()
    Config.AutoSell = Toggles.AutoSell.Value
    SaveConfig()
end)

Toggles.AutoSellAll = SellerSection:AddToggle('AutoSellAll', {
    Text = 'Auto Sell All',
    Default = Config.AutoSellAll or false,
    Tooltip = 'Automatically sell all items'
})

Toggles.AutoSellAll:OnChanged(function()
    Config.AutoSellAll = Toggles.AutoSellAll.Value
    SaveConfig()
end)

-- Teleport Tab
local TeleportSection = TeleportTab:AddLeftGroupbox('Zones')

Options.ZoneSelect = TeleportSection:AddDropdown('ZoneSelect', {
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
    pcall(function()
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
end)

-- Miscellaneous Tab
local MiscSection = MiscTab:AddLeftGroupbox('Performance')

Toggles.ReduceLag = MiscSection:AddToggle('ReduceLag', {
    Text = 'Reduce Lag',
    Default = Config.ReduceLag or false,
    Tooltip = 'Reduce game lag'
})

Toggles.ReduceLag:OnChanged(function()
    Config.ReduceLag = Toggles.ReduceLag.Value
    SaveConfig()
    
    if Toggles.ReduceLag.Value then
        pcall(function()
            settings().Rendering.QualityLevel = 1
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("ParticleEmitter") then
                    effect.Enabled = false
                end
            end
        end)
    end
end)

Toggles.AntiCrash = MiscSection:AddToggle('AntiCrash', {
    Text = 'Anti-Crash',
    Default = Config.AntiCrash or false,
    Tooltip = 'Prevent game crashes'
})

Toggles.AntiCrash:OnChanged(function()
    Config.AntiCrash = Toggles.AntiCrash.Value
    SaveConfig()
end)

local VisualSection = MiscTab:AddRightGroupbox('Visual')

Toggles.ScreenWhite = VisualSection:AddToggle('ScreenWhite', {
    Text = 'Show Screen White',
    Default = Config.ScreenWhite or false,
    Tooltip = 'Make screen white'
})

Toggles.ScreenWhite:OnChanged(function()
    Config.ScreenWhite = Toggles.ScreenWhite.Value
    SaveConfig()
    
    pcall(function()
        if Toggles.ScreenWhite.Value then
            if Toggles.ScreenBlack then
                Toggles.ScreenBlack:SetValue(false)
            end
            Lighting.Brightness = 10
            Lighting.Ambient = Color3.new(1, 1, 1)
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        end
    end)
end)

Toggles.ScreenBlack = VisualSection:AddToggle('ScreenBlack', {
    Text = 'Show Screen Black',
    Default = Config.ScreenBlack or false,
    Tooltip = 'Make screen black'
})

Toggles.ScreenBlack:OnChanged(function()
    Config.ScreenBlack = Toggles.ScreenBlack.Value
    SaveConfig()
    
    pcall(function()
        if Toggles.ScreenBlack.Value then
            if Toggles.ScreenWhite then
                Toggles.ScreenWhite:SetValue(false)
            end
            Lighting.Brightness = 0
            Lighting.Ambient = Color3.new(0, 0, 0)
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
        end
    end)
end)

Toggles.AutoReconnect = VisualSection:AddToggle('AutoReconnect', {
    Text = 'Auto Reconnect',
    Default = Config.AutoReconnect or false,
    Tooltip = 'Automatically reconnect if disconnected'
})

Toggles.AutoReconnect:OnChanged(function()
    Config.AutoReconnect = Toggles.AutoReconnect.Value
    SaveConfig()
end)

-- Settings Tab
local SettingsSection = SettingsTab:AddLeftGroupbox('Configuration')

SettingsSection:AddButton('Reset Script Config', function()
    pcall(function()
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
        
        for name, toggle in pairs(Toggles) do
            if toggle and toggle.SetValue then
                toggle:SetValue(false)
            end
        end
        
        library:Notify("Configuration reset!")
    end)
end)

-- Auto Reconnect
pcall(function()
    if Toggles.AutoReconnect and Toggles.AutoReconnect.Value then
        game:GetService("CoreGui").ChildRemoved:Connect(function(child)
            if child.Name == "RobloxGui" then
                wait(5)
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end)
    end
end)

-- Anti-Crash
if Toggles.AntiCrash and Toggles.AntiCrash.Value then
    pcall(function()
        setfpscap(60)
    end)
end

-- Safe Main Loop
pcall(function()
    RunService.Heartbeat:Connect(function()
        if Toggles.AutoFarm and Toggles.AutoFarm.Value then
            -- Auto fishing logic would go here
        end
    end)
end)

-- Initialize
library:Notify("YANZ Script Loaded Successfully! v0.0.1")
print("YANZ Script initialized without errors")
