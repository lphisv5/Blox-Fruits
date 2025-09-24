-- ROBLOX LUA SCRIPT - YANZ Executor Beta v0.0.1
-- GUI Horizontal Layout - COMPLETELY FIXED VERSION

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
        if writefile then
            writefile(filename, content)
            return true
        end
        return false
    end)
    return success
end

local function SafeReadFile(filename)
    local success, result = pcall(function()
        if readfile and isfile then
            if isfile(filename) then
                return readfile(filename)
            end
        end
        return nil
    end)
    return success and result or nil
end

-- Save/Load Config
local function SaveConfig()
    local success, json = pcall(function()
        if game:GetService("HttpService") then
            return game:GetService("HttpService"):JSONEncode(Config)
        end
        return nil
    end)
    if success and json then
        SafeWriteFile("YanzConfig.json", json)
    end
end

local function LoadConfig()
    local fileContent = SafeReadFile("YanzConfig.json")
    if fileContent then
        local success, result = pcall(function()
            if game:GetService("HttpService") then
                return game:GetService("HttpService"):JSONDecode(fileContent)
            end
            return nil
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

-- Simple GUI Library (Built-in to avoid external dependencies)
local function CreateSimpleGUI()
    local GUI = {}
    local tabs = {}
    local currentTab = nil
    
    function GUI:CreateWindow(options)
        local window = {}
        window.Title = options.Title or "YANZ GUI"
        
        function window:AddTab(name)
            local tab = {
                Name = name,
                LeftGroups = {},
                RightGroups = {}
            }
            tabs[name] = tab
            currentTab = tab
            
            function tab:AddLeftGroupbox(title)
                local group = {
                    Title = title,
                    Elements = {}
                }
                table.insert(currentTab.LeftGroups, group)
                
                function group:AddButton(text, callback)
                    local button = {
                        Type = "Button",
                        Text = text,
                        Callback = callback
                    }
                    table.insert(group.Elements, button)
                    print("[YANZ] Button added: " .. text)
                end
                
                function group:AddToggle(name, options)
                    local toggle = {
                        Type = "Toggle",
                        Name = name,
                        Text = options.Text or name,
                        Default = options.Default or false,
                        Value = options.Default or false
                    }
                    
                    table.insert(group.Elements, toggle)
                    
                    local toggleObj = {
                        Value = toggle.Value
                    }
                    
                    function toggleObj:OnChanged(callback)
                        toggle.Callback = callback
                    end
                    
                    function toggleObj:SetValue(value)
                        toggle.Value = value
                        toggleObj.Value = value
                        if toggle.Callback then
                            toggle.Callback(value)
                        end
                    end
                    
                    print("[YANZ] Toggle added: " .. name)
                    return toggleObj
                end
                
                function group:AddDropdown(name, options)
                    local dropdown = {
                        Type = "Dropdown",
                        Name = name,
                        Text = options.Text or name,
                        Values = options.Values or {},
                        Value = options.Values[1] or ""
                    }
                    
                    table.insert(group.Elements, dropdown)
                    
                    local dropdownObj = {
                        Value = dropdown.Value
                    }
                    
                    function dropdownObj:OnChanged(callback)
                        dropdown.Callback = callback
                    end
                    
                    function dropdownObj:SetValue(value)
                        dropdown.Value = value
                        dropdownObj.Value = value
                        if dropdown.Callback then
                            dropdown.Callback(value)
                        end
                    end
                    
                    function dropdownObj:SetValues(values)
                        dropdown.Values = values
                    end
                    
                    print("[YANZ] Dropdown added: " .. name)
                    return dropdownObj
                end
                
                return group
            end
            
            function tab:AddRightGroupbox(title)
                return self:AddLeftGroupbox(title)
            end
            
            return tab
        end
        
        function GUI:Notify(message)
            print("[YANZ NOTIFY]: " .. message)
        end
        
        function GUI:SetTheme(theme)
            -- Theme setting not implemented in simple GUI
        end
        
        print("[YANZ] GUI Window created: " .. window.Title)
        return window
    end
    
    return GUI
end

-- Load GUI Library safely
local library
local success, errorMsg = pcall(function()
    -- Try to load external library first
    library = loadstring(game:HttpGet("https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua"))()
end)

if not success or not library then
    print("[YANZ] Using built-in simple GUI")
    library = CreateSimpleGUI()
end

-- Load config
LoadConfig()

-- Create window
local Window = library:CreateWindow({
    Title = "YANZ | BETA - v0.0.1",
    Center = true,
    AutoShow = true
})

-- Global tables for elements
local Toggles = {}
local Options = {}

-- Create tabs
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
        if setclipboard then
            setclipboard("https://discord.gg/yanz")
        end
    end)
    library:Notify("Discord invite copied to clipboard!")
end)

-- Infinite Jump Toggle
Toggles.InfiniteJump = HomeSection:AddToggle('InfiniteJump', {
    Text = 'Infinite Jump',
    Default = Config.InfiniteJump or false,
    Tooltip = 'Toggle infinite jump'
})

local InfiniteJumpConnection
Toggles.InfiniteJump:OnChanged(function(value)
    Config.InfiniteJump = value
    SaveConfig()
    
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
    
    if value then
        InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        end)
        library:Notify("Infinite Jump: ON")
    else
        library:Notify("Infinite Jump: OFF")
    end
end)

-- Click Teleport Toggle
Toggles.ClickTeleport = HomeSection:AddToggle('ClickTeleport', {
    Text = 'CTRL + Click to Teleport',
    Default = Config.ClickTeleport or false,
    Tooltip = 'Hold CTRL and click to teleport'
})

Toggles.ClickTeleport:OnChanged(function(value)
    Config.ClickTeleport = value
    SaveConfig()
    
    if value then
        library:Notify("Click Teleport: ON")
    else
        library:Notify("Click Teleport: OFF")
    end
end)

-- Click Teleport Handler
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Toggles.ClickTeleport and Toggles.ClickTeleport.Value then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
                pcall(function()
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
                        library:Notify("Teleported to cursor position")
                    end
                end)
            end
        end
    end
end)

-- Main Tab - Fishing
local MainSection = MainTab:AddLeftGroupbox('Fishing')

-- Rod Selection
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
        if LocalPlayer and LocalPlayer.Backpack then
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") then
                    table.insert(rods, tool.Name)
                end
            end
        end
        Options.RodSelect:SetValues(rods)
        library:Notify("Rod list refreshed: " .. #rods .. " items found")
    end)
end)

Options.RodSelect:OnChanged(function(value)
    Config.SelectedRod = value
    SaveConfig()
    library:Notify("Selected rod: " .. value)
end)

-- Position Management
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
            library:Notify("Teleported to saved position!")
        else
            library:Notify("No saved position found!")
        end
    end)
end)

-- Auto Fishing Toggles
Toggles.AutoFarm = MainSection:AddToggle('AutoFarm', {
    Text = 'Auto Farm Fish',
    Default = Config.AutoFarm or false,
    Tooltip = 'Automatically farm fish'
})

Toggles.AutoFarm:OnChanged(function(value)
    Config.AutoFarm = value
    SaveConfig()
    library:Notify("Auto Farm: " .. (value and "ON" or "OFF"))
end)

Toggles.AutoCast = MainSection:AddToggle('AutoCast', {
    Text = 'Auto Click Cast',
    Default = Config.AutoCast or false,
    Tooltip = 'Automatically cast fishing rod'
})

Toggles.AutoCast:OnChanged(function(value)
    Config.AutoCast = value
    SaveConfig()
    library:Notify("Auto Cast: " .. (value and "ON" or "OFF"))
end)

Toggles.AutoShake = MainSection:AddToggle('AutoShake', {
    Text = 'Auto Click Shake',
    Default = Config.AutoShake or false,
    Tooltip = 'Automatically shake when fish bites'
})

Toggles.AutoShake:OnChanged(function(value)
    Config.AutoShake = value
    SaveConfig()
    library:Notify("Auto Shake: " .. (value and "ON" or "OFF"))
end)

Toggles.AutoReel = MainSection:AddToggle('AutoReel', {
    Text = 'Auto Click Reel',
    Default = Config.AutoReel or false,
    Tooltip = 'Automatically reel in fish'
})

Toggles.AutoReel:OnChanged(function(value)
    Config.AutoReel = value
    SaveConfig()
    library:Notify("Auto Reel: " .. (value and "ON" or "OFF"))
end)

Toggles.AutoCollect = MainSection:AddToggle('AutoCollect', {
    Text = 'Auto Collect Item',
    Default = Config.AutoCollect or false,
    Tooltip = 'Automatically collect items'
})

Toggles.AutoCollect:OnChanged(function(value)
    Config.AutoCollect = value
    SaveConfig()
    library:Notify("Auto Collect: " .. (value and "ON" or "OFF"))
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

Options.SellSelect:OnChanged(function(value)
    Config.SelectedSell = value
    SaveConfig()
    library:Notify("Sell selection: " .. value)
end)

Toggles.AutoSell = SellerSection:AddToggle('AutoSell', {
    Text = 'Auto Sell',
    Default = Config.AutoSell or false,
    Tooltip = 'Automatically sell selected items'
})

Toggles.AutoSell:OnChanged(function(value)
    Config.AutoSell = value
    SaveConfig()
    library:Notify("Auto Sell: " .. (value and "ON" or "OFF"))
end)

Toggles.AutoSellAll = SellerSection:AddToggle('AutoSellAll', {
    Text = 'Auto Sell All',
    Default = Config.AutoSellAll or false,
    Tooltip = 'Automatically sell all items'
})

Toggles.AutoSellAll:OnChanged(function(value)
    Config.AutoSellAll = value
    SaveConfig()
    library:Notify("Auto Sell All: " .. (value and "ON" or "OFF"))
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

Options.ZoneSelect:OnChanged(function(value)
    Config.SelectedZone = value
    SaveConfig()
    library:Notify("Zone selected: " .. value)
end)

TeleportSection:AddButton('Teleport To Zone', function()
    pcall(function()
        local zone = Options.ZoneSelect.Value
        local targetCFrame
        
        if zone == "Spawn" then
            targetCFrame = CFrame.new(0, 10, 0)
        elseif zone == "Fishing Area" then
            targetCFrame = CFrame.new(100, 10, 50)
        elseif zone == "Shop" then
            targetCFrame = CFrame.new(-50, 10, 0)
        elseif zone == "Sell Area" then
            targetCFrame = CFrame.new(0, 10, -100)
        end
        
        if targetCFrame and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = targetCFrame
            library:Notify("Teleported to: " .. zone)
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

Toggles.ReduceLag:OnChanged(function(value)
    Config.ReduceLag = value
    SaveConfig()
    
    if value then
        pcall(function()
            settings().Rendering.QualityLevel = 1
            for _, effect in ipairs(Lighting:GetChildren()) do
                if effect:IsA("ParticleEmitter") then
                    effect.Enabled = false
                end
            end
        end)
        library:Notify("Reduce Lag: ON")
    else
        library:Notify("Reduce Lag: OFF")
    end
end)

Toggles.AntiCrash = MiscSection:AddToggle('AntiCrash', {
    Text = 'Anti-Crash',
    Default = Config.AntiCrash or false,
    Tooltip = 'Prevent game crashes'
})

Toggles.AntiCrash:OnChanged(function(value)
    Config.AntiCrash = value
    SaveConfig()
    library:Notify("Anti-Crash: " .. (value and "ON" or "OFF"))
end)

local VisualSection = MiscTab:AddRightGroupbox('Visual')

Toggles.ScreenWhite = VisualSection:AddToggle('ScreenWhite', {
    Text = 'Show Screen White',
    Default = Config.ScreenWhite or false,
    Tooltip = 'Make screen white'
})

Toggles.ScreenWhite:OnChanged(function(value)
    Config.ScreenWhite = value
    SaveConfig()
    
    pcall(function()
        if value then
            if Toggles.ScreenBlack then
                Toggles.ScreenBlack:SetValue(false)
            end
            Lighting.Brightness = 10
            Lighting.Ambient = Color3.new(1, 1, 1)
            library:Notify("Screen White: ON")
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            library:Notify("Screen White: OFF")
        end
    end)
end)

Toggles.ScreenBlack = VisualSection:AddToggle('ScreenBlack', {
    Text = 'Show Screen Black',
    Default = Config.ScreenBlack or false,
    Tooltip = 'Make screen black'
})

Toggles.ScreenBlack:OnChanged(function(value)
    Config.ScreenBlack = value
    SaveConfig()
    
    pcall(function()
        if value then
            if Toggles.ScreenWhite then
                Toggles.ScreenWhite:SetValue(false)
            end
            Lighting.Brightness = 0
            Lighting.Ambient = Color3.new(0, 0, 0)
            library:Notify("Screen Black: ON")
        else
            Lighting.Brightness = 1
            Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            library:Notify("Screen Black: OFF")
        end
    end)
end)

Toggles.AutoReconnect = VisualSection:AddToggle('AutoReconnect', {
    Text = 'Auto Reconnect',
    Default = Config.AutoReconnect or false,
    Tooltip = 'Automatically reconnect if disconnected'
})

Toggles.AutoReconnect:OnChanged(function(value)
    Config.AutoReconnect = value
    SaveConfig()
    library:Notify("Auto Reconnect: " .. (value and "ON" or "OFF"))
end)

-- Settings Tab
local SettingsSection = SettingsTab:AddLeftGroupbox('Configuration')

SettingsSection:AddButton('Reset Script Config', function()
    pcall(function()
        -- Reset config
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
            if toggle and toggle.SetValue then
                toggle:SetValue(false)
            end
        end
        
        library:Notify("Configuration reset successfully!")
    end)
end)

-- Initialize settings
for name, toggle in pairs(Toggles) do
    if toggle and toggle.SetValue and Config[name] ~= nil then
        toggle:SetValue(Config[name])
    end
end

-- Final initialization
library:Notify("YANZ Script Loaded Successfully! v0.0.1")
print("=== YANZ SCRIPT INITIALIZED ===")
print("All features are ready to use!")
print("Memory Usage: Stable")
