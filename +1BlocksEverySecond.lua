
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- VirtualInput
local VirtualInputManager
local ok_vim, vim = pcall(game.GetService, game, "VirtualInputManager")
if ok_vim then VirtualInputManager = vim end

-- Library Loader
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local NothingLibrary
local ok_lib, lib = pcall(function()
    local code = game:HttpGetAsync(libURL)
    if code then
        local func, err = loadstring(code)
        if not func then warn("Loadstring error:", err) return nil end
        return func()
    end
end)
if not ok_lib or not lib then
    warn("YANZ HUB: Failed to load Nothing UI Library")
    return
end
NothingLibrary = lib

-- ================== Theme Presets ==================
local Themes = {
    ["Default"] = "Default",
    ["Amber Glow"] = "AmberGlow",
    ["Amethyst"] = "Amethyst",
    ["Bloom"] = "Bloom",
    ["Dark Blue"] = "DarkBlue",
    ["Green"] = "Green",
    ["Light"] = "Light",
    ["Ocean"] = "Ocean",
    ["Serenity"] = "Serenity"
}
local currentTheme = "Default"

-- ================== Save System ==================
local SaveFolder = "YANZ_HUB"
local SaveFile = SaveFolder .. "/settings.json"

local function saveSettings(data)
    if not writefile or not isfolder or not makefolder then return end
    if not isfolder(SaveFolder) then makefolder(SaveFolder) end
    pcall(function() writefile(SaveFile, HttpService:JSONEncode(data)) end)
end

local function loadSettings()
    if not isfile or not readfile or not isfile(SaveFile) then return {} end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(SaveFile))
    end)
    return ok and decoded or {}
end

local Saved = loadSettings()
local ClickX = Saved.ClickX or 10
local ClickY = Saved.ClickY or 10
local GUIKey = Saved.GUIKey or "RightShift"
local AutoSave = Saved.AutoSave or true
local UseHitbox = Saved.UseHitbox or false
currentTheme = Saved.Theme or "Default"

-- ================== Window ==================
local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.4.1", -- Updated version
    Description = "By lphisv5 | Game: +1 Blocks Every Second",
    Keybind = Enum.KeyCode[GUIKey] or Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282',
    Theme = currentTheme
})

-- HOME
local HomeTab = Window:NewTab({ Title = "HOME", Description = "Home Features", Icon = "rbxassetid://7733960981" })
local HomeSection = HomeTab:NewSection({ Title = "Home", Position = "Left" })
HomeSection:NewButton({
    Title = "Join Discord",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/DfVuhsZb")
            NothingLibrary:Notify({ Title = "Copied!", Content = "Link copied to clipboard", Duration = 5 })
        end)
    end
})

-- MAIN Tab
local MainTab = Window:NewTab({ Title = "MAIN", Description = "Auto Farm Features" })
local MainControlsSection = MainTab:NewSection({ Title = "Controls", Position = "Left" })
local StatusLabel = MainControlsSection:NewTitle("Status: Sleeping")

-- Globals
local isLoopRunning, lastRun, loopThread = false, false, nil
local connections = {}
local hitbox = nil
local antiAFKThread = nil

local function addConn(conn)
    if conn then table.insert(connections, conn) end
    return conn
end

local function updateLabel(lbl, text)
    if not lbl then return end
    pcall(function()
        if lbl.Set then
            lbl:Set(tostring(text))
        elseif lbl.SetText then
            lbl:SetText(tostring(text))
        end
    end)
end

local function updateStatus()
    if isLoopRunning then
        lastRun = true
        updateLabel(StatusLabel, "Status: Working")
    elseif not isLoopRunning and lastRun then
        updateLabel(StatusLabel, "Status: Not Working")
    else
        updateLabel(StatusLabel, "Status: Sleeping")
    end
end

-- Create Transparent Hitbox
local function createHitbox()
    if hitbox then return end
    hitbox = Instance.new("Part")
    hitbox.Name = "YANZHitbox"
    hitbox.Transparency = 1
    hitbox.Size = Vector3.new(5, 5, 5) -- Adjustable size
    hitbox.Anchored = true
    hitbox.CanCollide = false
    hitbox.Parent = workspace
    Instance.new("ClickDetector", hitbox)
    addConn(RunService.Heartbeat:Connect(function()
        if LocalPlayer.Character and LocalPlayer.Character.PrimaryPart then
            hitbox.CFrame = LocalPlayer.Character.PrimaryPart.CFrame * CFrame.new(0, 0, -5) -- In front of player
        end
    end))
end

local function destroyHitbox()
    if hitbox then
        hitbox:Destroy()
        hitbox = nil
    end
end

if UseHitbox then createHitbox() end

-- FastAttack (Click only, custom position or hitbox)
local function FastAttack()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local posX, posY
    if UseHitbox and hitbox then
        local vec, onScreen = cam:WorldToViewportPoint(hitbox.Position)
        if not onScreen then return end
        posX = vec.X
        posY = vec.Y
    else
        local viewport = cam.ViewportSize
        posX = math.floor(viewport.X * (ClickX / 100))
        posY = math.floor(viewport.Y * (ClickY / 100))
    end
    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(posX, posY, 0, true, cam, 1)
            task.wait(0.01) -- Small delay to simulate click
            VirtualInputManager:SendMouseButtonEvent(posX, posY, 0, false, cam, 1)
        end)
    end
end

-- Auto Farm Loop
local function startAutoFarm()
    if loopThread then return end
    loopThread = task.spawn(function()
        while isLoopRunning do
            pcall(FastAttack)
            task.wait(0.5 + math.random() * 1.5) -- Random delay for anti-detection
        end
        loopThread = nil
    end)
end

MainControlsSection:NewToggle({
    Title = "Auto Farm Block",
    Default = false,
    Callback = function(value)
        isLoopRunning = value
        updateStatus()
        if isLoopRunning then startAutoFarm() end
    end
})

-- Fast Block Section
local FastBlockSection = MainTab:NewSection({ Title = "Auto Fast Block", Position = "Right" })
local isFastBlockRunning, fastBlockThread = false, nil
local FastStatusLabel = FastBlockSection:NewTitle("Status: Sleeping")
FastBlockSection:NewTitle("(Press F6)")

local function startAutoFastBlock()
    if fastBlockThread then return end
    fastBlockThread = task.spawn(function()
        while isFastBlockRunning do
            pcall(FastAttack)
            task.wait(0.01) -- Faster interval for fast block
        end
        fastBlockThread = nil
    end)
end

local function updateFastStatus()
    FastStatusLabel:Set(isFastBlockRunning and "Status: Working" or "Status: Sleeping")
end

FastBlockSection:NewToggle({
    Title = "Enable Auto Fast Block",
    Default = false,
    Callback = function(v)
        isFastBlockRunning = v
        updateFastStatus()
        if v then startAutoFastBlock() end
    end
})

addConn(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        isFastBlockRunning = not isFastBlockRunning
        updateFastStatus()
        if isFastBlockRunning then startAutoFastBlock() end
    end
end))

-- Settings Tab
local SettingsTab = Window:NewTab({ Title = "Settings", Description = "Configuration" })
local AntiAFKSection = SettingsTab:NewSection({ Title = "Anti-AFK", Position = "Left" })
local isAntiAFKEnabled = false

local function startAntiAFK()
    if antiAFKThread then return end
    antiAFKThread = task.spawn(function()
        while isAntiAFKEnabled do
            if not (isLoopRunning or isFastBlockRunning) then
                local cam = workspace.CurrentCamera
                if cam and VirtualInputManager then
                    local viewport = cam.ViewportSize
                    local randX = math.random(0, viewport.X)
                    local randY = math.random(0, viewport.Y)
                    pcall(function()
                        VirtualInputManager:SendMouseButtonEvent(randX, randY, 0, true, cam, 1)
                        task.wait(0.01)
                        VirtualInputManager:SendMouseButtonEvent(randX, randY, 0, false, cam, 1)
                    end)
                end
            end
            task.wait(19 * 60) -- Every 19 minutes
        end
        antiAFKThread = nil
    end)
end

local function stopAntiAFK()
    isAntiAFKEnabled = false
    -- Thread will stop naturally
end

AntiAFKSection:NewToggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(v)
        isAntiAFKEnabled = v
        if v then startAntiAFK() else stopAntiAFK() end
    end
})

-- Auto-Save Toggle
AntiAFKSection:NewToggle({
    Title = "Auto-Save Settings",
    Default = AutoSave,
    Callback = function(v)
        AutoSave = v
        if AutoSave then
            saveSettings({ ClickX = ClickX, ClickY = ClickY, GUIKey = GUIKey, Theme = currentTheme, AutoSave = AutoSave, UseHitbox = UseHitbox })
        end
    end
})

-- Click Position Sliders
local ClickSection = SettingsTab:NewSection({ Title = "Click Position" })
ClickSection:NewSlider({
    Title = "Click X (%)",
    Min = 0,
    Max = 100,
    Default = ClickX,
    Callback = function(v)
        ClickX = v
        if AutoSave then
            saveSettings({ ClickX = ClickX, ClickY = ClickY, GUIKey = GUIKey, Theme = currentTheme, AutoSave = AutoSave, UseHitbox = UseHitbox })
        end
    end
})
ClickSection:NewSlider({
    Title = "Click Y (%)",
    Min = 0,
    Max = 100,
    Default = ClickY,
    Callback = function(v)
        ClickY = v
        if AutoSave then
            saveSettings({ ClickX = ClickX, ClickY = ClickY, GUIKey = GUIKey, Theme = currentTheme, AutoSave = AutoSave, UseHitbox = UseHitbox })
        end
    end
})

-- Hitbox Toggle
local HitboxSection = SettingsTab:NewSection({ Title = "Hitbox" })
HitboxSection:NewToggle({
    Title = "Enable Transparent Hitbox",
    Default = UseHitbox,
    Callback = function(v)
        UseHitbox = v
        if v then
            createHitbox()
        else
            destroyHitbox()
        end
        if AutoSave then
            saveSettings({ ClickX = ClickX, ClickY = ClickY, GUIKey = GUIKey, Theme = currentTheme, AutoSave = AutoSave, UseHitbox = UseHitbox })
        end
    end
})
HitboxSection:NewTitle("Uses a transparent hitbox in front of player for clicks")

-- GUI Key Input
local KeySection = SettingsTab:NewSection({ Title = "GUI Key" })
KeySection:NewInput({
    Title = "Press Key",
    Placeholder = GUIKey,
    Callback = function(txt)
        if Enum.KeyCode[txt] then
            GUIKey = txt
            Window:SetKeybind(Enum.KeyCode[txt])
            if AutoSave then
                saveSettings({ ClickX = ClickX, ClickY = ClickY, GUIKey = GUIKey, Theme = currentTheme, AutoSave = AutoSave, UseHitbox = UseHitbox })
            end
        end
    end
})

-- Theme Section
local ThemeSection = SettingsTab:NewSection({ Title = "Themes" })
ThemeSection:NewDropdown({
    Title = "Select Theme",
    Items = Themes,
    Default = currentTheme,
    Callback = function(choice)
        currentTheme = choice
        Window:SetTheme(choice)
        if AutoSave then
            saveSettings({ ClickX = ClickX, ClickY = ClickY, GUIKey = GUIKey, Theme = currentTheme, AutoSave = AutoSave, UseHitbox = UseHitbox })
        end
    end
})

-- Utility Section
local UtilitySection = SettingsTab:NewSection({ Title = "Utilities", Position = "Right" })
UtilitySection:NewButton({
    Title = "Rejoin",
    Callback = function()
        pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
})

UtilitySection:NewButton({
    Title = "Server Hop",
    Callback = function()
        pcall(function()
            local servers = {}
            local cursor = ""
            repeat
                local req = game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or ""))
                local data = HttpService:JSONDecode(req)
                for _, s in ipairs(data.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        table.insert(servers, s.id)
                    end
                end
                cursor = data.nextPageCursor
            until not cursor
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
            else
                NothingLibrary:Notify({ Title = "Server Hop", Content = "No available servers found. Rejoining current server.", Duration = 5 })
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end)
    end
})

-- Cleanup
local function cleanup()
    isLoopRunning, isFastBlockRunning, isAntiAFKEnabled = false, false, false
    destroyHitbox()
    for _, c in ipairs(connections) do
        pcall(function() if c.Disconnect then c:Disconnect() end end)
    end
    connections = {}
    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
end

addConn(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then cleanup() end
end))

-- Initialize
updateStatus()
updateFastStatus()
