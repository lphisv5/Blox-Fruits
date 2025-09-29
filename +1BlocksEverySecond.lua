-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- VirtualInput
local VirtualInputManager
local ok_vim, vim = pcall(game.GetService, game, "VirtualInputManager")
if ok_vim then VirtualInputManager = vim end

-- Library Loader
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local NothingLibrary
local ok_lib, lib = pcall(function()
    local code = game:HttpGet(libURL)
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

-- ================== Window ==================
local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.5.8",
    Description = "By lphisv5 | Game: +1 Blocks Every Second",
    Keybind = Enum.KeyCode[GUIKey] or Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282'
})

-- ================== Locations and Eggs ==================
local locationsWorld1 = {
    ["Lobby"] = Vector3.new(-41.00,9.48,-31.43),
    ["Gem Shop"] = Vector3.new(-90.08, 3.52, -51.50),
    ["Dark Matter Machine"] = Vector3.new(90.48, 3.48, -96.46),
    ["Toxic Machine"] = Vector3.new(90.61, 3.48, -65.11),
    ["Golden Machine"] = Vector3.new(86.33, 3.48, -32.67)
}

local locationsWorld2 = {
    ["World 2"] = Vector3.new(8190.00, 19.11, -38.60),
    ["World 1"] = Vector3.new(-41.00,9.48,-31.43)
}

local eggsWorld1 = {
    ["Grass Egg 500 Blocks"] = Vector3.new(-52.90, 9.48, -42.95),
    ["Stone Egg 3.5K Blocks"] = Vector3.new(-52.10, 9.48, -52.75), 
    ["Christmas Egg 10K Blocks"] = Vector3.new(-25.77, 9.48, -27.70),
    ["Void Egg 25K Blocks"] = Vector3.new(-53.70, 9.48, -47.62),
    ["Atlantis Egg 100K Blocks"] = Vector3.new(-30.55, 9.48, -42.60),
    ["Lava Egg 500K Blocks"] = Vector3.new(-30.80, 9.48, -52.55),
    ["Limited Egg 399R$"] = Vector3.new(-34.25, 9.48, -27.45)
}

local eggsWorld2 = {
    ["Celestial Egg 10M Blocks"] = Vector3.new(8165.75, 18.68, -77.00),
    ["Battlemech Egg 22.5M Blocks"] = Vector3.new(8161.00, 18.68, -93.00),
    ["Crown Egg 50M Blocks"] = Vector3.new(8161.00, 18.68, -109.00),
    ["Space Clover Egg 699R$"] = Vector3.new(8161.00, 18.68, -125.50)
}

-- ================== Helper Functions ==================
local function getCurrentWorld()
    local playerPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position
    if not playerPos then return 1 end
    return playerPos.X > 8000 and 2 or 1
end

-- Advanced Teleport
local function teleportTo(position)
    pcall(function()
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character:FindFirstChild("Humanoid") or LocalPlayer.Character.Humanoid.Health <= 0 then
            NothingLibrary:Notify({ Title = "Error", Content = "Character not loaded or dead.", Duration = 5 })
            return
        end

        local hrp = LocalPlayer.Character.HumanoidRootPart
        local targetCFrame = CFrame.new(position + Vector3.new(0, 3, 0))

        local currentY = hrp.Position.Y
        if position.Y < currentY - 2 then
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
            local rayResult = Workspace:Raycast(position + Vector3.new(0, 5, 0), Vector3.new(0, -50, 0), raycastParams)
            if rayResult then
                targetCFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
            end
        end

        -- Tween TP
        local tween = TweenService:Create(hrp, TweenInfo.new(0.35, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait()
        task.wait(0.05)

        -- Lock final position
        hrp.CFrame = targetCFrame

        NothingLibrary:Notify({ Title = "Teleport", Content = "Teleported successfully!", Duration = 5 })
    end)
end

-- ================== Auto Hatch ==================
local isAutoHatchEnabled = false
local autoHatchConnection = nil

local function startAutoHatch(eggName, eggPos, targetWorld)
    if getCurrentWorld() ~= targetWorld then
        teleportTo(targetWorld == 2 and Vector3.new(65.00, 4.30, 97.97) or locationsWorld2["World 1"])
        task.wait(2)
    end
    teleportTo(eggPos)
    if autoHatchConnection then autoHatchConnection:Disconnect() end

    autoHatchConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            local args = { eggName:match("^(.+) %d+.*$") or eggName }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("HatchEgg"):FireServer(unpack(args))
        end)
    end)
    isAutoHatchEnabled = true
end

local function stopAutoHatch()
    if autoHatchConnection then autoHatchConnection:Disconnect() end
    autoHatchConnection = nil
    isAutoHatchEnabled = false
end

-- ================== Auto Fame ==================
local isAutoFameEnabled = false
local autoFameConnection = nil
local vu = game:GetService("VirtualUser")

local function startAutoFameAndAntiAFK()
    if autoFameConnection then autoFameConnection:Disconnect() end
    autoFameConnection = RunService.Heartbeat:Connect(function()
        local cam = workspace.CurrentCamera
        if not cam then return end
        local viewport = cam.ViewportSize

        pcall(function() vu:CaptureController() vu:ClickButton1(Vector2.new(0,0)) end)
        task.wait(1)
        pcall(function() vu:CaptureController() vu:ClickButton1(Vector2.new(0,viewport.Y-1)) end)
    end)
end

local function stopAutoFameAndAntiAFK()
    if autoFameConnection then autoFameConnection:Disconnect() end
    autoFameConnection = nil
end

-- ================== GUI Tabs ==================
-- HOME Tab
local HomeTab = Window:NewTab({ Title = "HOME", Description = "Home Features", Icon = "rbxassetid://7733960981" })
local HomeSection = HomeTab:NewSection({ Title = "Home", Position = "Left" })
HomeSection:NewButton({
    Title = "Join Discord",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/DfVuhsZb") end)
        NothingLibrary:Notify({ Title = "Copied!", Content = "Link copied to clipboard", Duration = 5 })
    end
})

-- FAME Tab
local FameTab = Window:NewTab({ Title = "FAME", Description = "Auto Fame Features" })
local FameSection = FameTab:NewSection({ Title = "Auto Fame", Position = "Left" })
FameSection:NewToggle({
    Title = "Auto Fame",
    Default = false,
    Callback = function(value)
        isAutoFameEnabled = value
        if value then startAutoFameAndAntiAFK() else stopAutoFameAndAntiAFK() end
    end
})

-- TELEPORT Tab
local TeleportTab = Window:NewTab({ Title = "TELEPORT", Description = "Teleport Features" })
local World1Section = TeleportTab:NewSection({ Title = "Teleport World", Position = "Left" })
local World2Section = TeleportTab:NewSection({ Title = "Teleport World", Position = "Right" })

for name, pos in pairs(locationsWorld1) do World1Section:NewButton({ Title = name, Callback = function() teleportTo(pos) end }) end
for name, pos in pairs(locationsWorld2) do World2Section:NewButton({ Title = name, Callback = function() teleportTo(pos) end }) end

-- EGGS Tab
local EggsTab = Window:NewTab({ Title = "EGGS", Description = "Egg Locations & Auto Hatch" })
local EggsWorld1Section = EggsTab:NewSection({ Title = "World 1 Eggs", Position = "Left" })
local EggsWorld2Section = EggsTab:NewSection({ Title = "World 2 Eggs", Position = "Right" })

for eggName, eggPos in pairs(eggsWorld1) do
    EggsWorld1Section:NewButton({
        Title = eggName,
        Callback = function()
            if isAutoHatchEnabled then stopAutoHatch() end
            startAutoHatch(eggName, eggPos, 1)
            NothingLibrary:Notify({ Title = "Auto Hatch", Content = "Started Auto Hatch for " .. eggName, Duration = 5 })
        end
    })
end

for eggName, eggPos in pairs(eggsWorld2) do
    EggsWorld2Section:NewButton({
        Title = eggName,
        Callback = function()
            if isAutoHatchEnabled then stopAutoHatch() end
            startAutoHatch(eggName, eggPos, 2)
            NothingLibrary:Notify({ Title = "Auto Hatch", Content = "Started Auto Hatch for " .. eggName, Duration = 5 })
        end
    })
end

EggsTab:NewSection({ Title = "Auto Hatch Control", Position = "Left" }):NewButton({
    Title = "Stop Auto Hatch",
    Callback = function() stopAutoHatch() NothingLibrary:Notify({ Title = "Auto Hatch", Content = "Auto Hatch stopped.", Duration = 5 }) end
})

-- SETTINGS Tab
local SettingsTab = Window:NewTab({ Title = "Settings", Description = "Configuration" })
local ClickSection = SettingsTab:NewSection({ Title = "Click Position" })
ClickSection:NewSlider({ Title = "Click X (%)", Min = 0, Max = 100, Default = ClickX, Callback = function(v) ClickX = v if AutoSave then saveSettings({ClickX=ClickX, ClickY=ClickY, GUIKey=GUIKey, AutoSave=AutoSave}) end end })
ClickSection:NewSlider({ Title = "Click Y (%)", Min = 0, Max = 100, Default = ClickY, Callback = function(v) ClickY = v if AutoSave then saveSettings({ClickX=ClickX, ClickY=ClickY, GUIKey=GUIKey, AutoSave=AutoSave}) end end })

local UtilitySection = SettingsTab:NewSection({ Title = "Utilities", Position = "Right" })
UtilitySection:NewButton({ Title = "Rejoin", Callback = function() pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end) end })
UtilitySection:NewButton({
    Title = "Server Hop",
    Callback = function()
        pcall(function()
            local servers, cursor = {}, ""
            repeat
                local req = game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"..(cursor~="" and "&cursor="..cursor or ""))
                local data = HttpService:JSONDecode(req)
                for _, s in ipairs(data.data) do if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(servers,s.id) end end
                cursor = data.nextPageCursor
            until not cursor
            if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1,#servers)], LocalPlayer)
            else NothingLibrary:Notify({ Title = "Server Hop", Content = "No available servers found. Rejoining current server.", Duration = 5 }) TeleportService:Teleport(game.PlaceId, LocalPlayer) end
        end)
    end
})

-- ================== Cleanup ==================
local connections = {}
local function addConn(conn) table.insert(connections, conn) end
local function cleanup()
    stopAutoHatch()
    stopAutoFameAndAntiAFK()
    for _, c in ipairs(connections) do pcall(function() if c.Disconnect then c:Disconnect() end end) end
    connections = {}
    pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
end
addConn(Players.PlayerRemoving:Connect(function(player) if player == LocalPlayer then cleanup() end end))
