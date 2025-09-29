-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- VirtualInput
local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

-- Library Loader
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local ok_lib, NothingLibrary = pcall(function()
    local code = game:HttpGetAsync(libURL)
    if code then
        local func, err = loadstring(code)
        if not func then warn("Loadstring error:", err) return nil end
        return func()
    end
end)
if not ok_lib or not NothingLibrary then
    warn("YANZ HUB: Failed to load Nothing UI Library")
    return
end

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
local SaveFile = SaveFolder.."/settings.json"
local HttpService = game:GetService("HttpService")

-- executor must support writefile / readfile
local function saveSettings(data)
    if not writefile then return end
    if not isfolder(SaveFolder) then makefolder(SaveFolder) end
    writefile(SaveFile, HttpService:JSONEncode(data))
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
currentTheme = Saved.Theme or "Default"

-- ================== Window ==================
local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.3.0",
    Description = "By lphisv5 | Game : +1 Blocks Every Second",
    Keybind = Enum.KeyCode[GUIKey] or Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282',
    Theme = currentTheme
})

-- HOME
local HomeTab = Window:NewTab({Title = "HOME", Description = "Home Features", Icon = "rbxassetid://7733960981"})
local HomeSection = HomeTab:NewSection({Title = "Home", Position = "Left"})
HomeSection:NewButton({
    Title = "Join Discord",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/DfVuhsZb")
            NothingLibrary:Notify({Title = "Copied!", Content = "Link copied to clipboard", Duration = 5})
        end)
    end
})

-- MAIN Tab
local MainTab = Window:NewTab({Title = "MAIN", Description = "Auto Farm Features"})
local MainControlsSection = MainTab:NewSection({Title = "Controls", Position = "Left"})
local StatusLabel = MainControlsSection:NewTitle("Status: Sleeping")

-- Globals
local isLoopRunning, lastRun, loopThread = false, false, nil
local connections = {}

local function addConn(conn) if conn then table.insert(connections, conn) end return conn end
local function updateLabel(lbl, text) if not lbl then return end pcall(function()
    if lbl.Set then lbl:Set(tostring(text)) elseif lbl.SetText then lbl:SetText(tostring(text)) end
end) end
local function updateStatus()
    if isLoopRunning then lastRun = true; updateLabel(StatusLabel, "Status: Working")
    elseif not isLoopRunning and lastRun then updateLabel(StatusLabel, "Status: Not Working")
    else updateLabel(StatusLabel, "Status: Sleeping") end
end

-- FastAttack (Click only, custom position)
local function FastAttack()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    local posX = math.floor(viewport.X * (ClickX/100))
    local posY = math.floor(viewport.Y * (ClickY/100))
    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(posX, posY, 0, true, cam, 1)
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
            task.wait(0.5 + math.random() * 1.5)
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
local FastBlockSection = MainTab:NewSection({Title = "Auto Fast Block", Position = "Right"})
local isFastBlockRunning, fastBlockThread = false, nil
local FastStatusLabel = FastBlockSection:NewTitle("Status: Sleeping")
FastBlockSection:NewTitle("(Press F6)")

local function startAutoFastBlock()
    if fastBlockThread then return end
    fastBlockThread = task.spawn(function()
        while isFastBlockRunning do
            pcall(FastAttack)
            task.wait(0.01)
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
local SettingsTab = Window:NewTab({Title = "Settings", Description = "Configuration"})
local AntiAFKSection = SettingsTab:NewSection({Title = "Anti-AFK", Position = "Left"})
local isAntiAFKEnabled, antiAFKConnection = false, nil
local function startAntiAFK()
    if antiAFKConnection then antiAFKConnection:Disconnect() end
    local vu = game:GetService("VirtualUser")
    antiAFKConnection = RunService.Stepped:Connect(function()
        vu:CaptureController()
        vu:ClickButton1(Vector2.new(0, 0))
    end)
end
local function stopAntiAFK() if antiAFKConnection then antiAFKConnection:Disconnect() antiAFKConnection=nil end end
AntiAFKSection:NewToggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(v) isAntiAFKEnabled = v if v then startAntiAFK() else stopAntiAFK() end end
})

-- Click position sliders
local ClickSection = SettingsTab:NewSection({Title = "Click Position"})
ClickSection:NewSlider({
    Title = "Click X (%)", Min = 0, Max = 100, Default = ClickX,
    Callback = function(v) ClickX = v; saveSettings({ClickX=ClickX,ClickY=ClickY,GUIKey=GUIKey,Theme=currentTheme}) end
})
ClickSection:NewSlider({
    Title = "Click Y (%)", Min = 0, Max = 100, Default = ClickY,
    Callback = function(v) ClickY = v; saveSettings({ClickX=ClickX,ClickY=ClickY,GUIKey=GUIKey,Theme=currentTheme}) end
})

-- GUI Key Input
local KeySection = SettingsTab:NewSection({Title = "GUI Key"})
KeySection:NewInput({
    Title = "Press Key",
    Placeholder = GUIKey,
    Callback = function(txt)
        if Enum.KeyCode[txt] then
            GUIKey = txt
            Window:SetKeybind(Enum.KeyCode[txt])
            saveSettings({ClickX=ClickX,ClickY=ClickY,GUIKey=GUIKey,Theme=currentTheme})
        end
    end
})

-- Theme Section
local ThemeSection = SettingsTab:NewSection({Title = "Themes"})
ThemeSection:NewDropdown({
    Title = "Select Theme",
    Items = Themes,
    Default = currentTheme,
    Callback = function(choice)
        currentTheme = choice
        Window:SetTheme(choice)
        saveSettings({ClickX=ClickX,ClickY=ClickY,GUIKey=GUIKey,Theme=currentTheme})
    end
})

-- Utility Section
local UtilitySection = SettingsTab:NewSection({Title = "Utilities", Position = "Right"})
UtilitySection:NewButton({
    Title = "Rejoin",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})
UtilitySection:NewButton({
    Title = "Server Hop",
    Callback = function()
        pcall(function()
            local servers = {}
            local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
            local data = HttpService:JSONDecode(req)
            for _,s in ipairs(data.data) do
                if s.playing < s.maxPlayers then table.insert(servers, s.id) end
            end
            if #servers > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], LocalPlayer)
            else
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end
        end)
    end
})

-- Cleanup
local function cleanup()
    isLoopRunning, isFastBlockRunning = false, false
    stopAntiAFK()
    for _, c in ipairs(connections) do pcall(function() if c.Disconnect then c:Disconnect() end end) end
    connections = {}
    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
end
Players.PlayerRemoving:Connect(function(player) if player == LocalPlayer then cleanup() end end)

updateStatus(); updateFastStatus()
