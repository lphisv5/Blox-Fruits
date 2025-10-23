local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)

-- Library URL for Nothing UI Library
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'

-- Load Nothing UI Library
local NothingLibrary
local success, result = pcall(function()
    local code = game:HttpGetAsync(libURL)
    if code then
        print("Library first 1000 chars:", code:sub(1, 1000))
        local func, err = loadstring(code)
        if func then
            return func()
        else
            warn("Loadstring error:", err)
        end
    else
        warn("Failed to fetch library from:", libURL)
    end
end)
if success and result then
    NothingLibrary = result
else
    warn("Failed to load Nothing UI Library:", result)
    return
end

-- Find YANZ HUB GUI in PlayerGui or CoreGui
local function findHubGui()
    local function scan(container)
        for _, obj in ipairs(container:GetDescendants()) do
            if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
                local success, text = pcall(function() return obj.Text end)
                if success and text and text:match("YANZ HUB") then
                    local top = obj
                    while top.Parent and not top:IsA("ScreenGui") do
                        top = top.Parent
                    end
                    return top:IsA("ScreenGui") and top or nil
                end
            end
        end
    end
    return pcall(function()
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        return scan(playerGui) or scan(game:GetService("CoreGui"))
    end) and select(2, pcall(function() return scan(LocalPlayer.PlayerGui) or scan(game:GetService("CoreGui")) end)) or nil
end
local HubGuiRoot = findHubGui()

-- Toggle UI input transparency
local function setUIInputTransparent(root, flag)
    if not root then return end
    pcall(function()
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("GuiObject") then
                if obj:GetAttribute("__origInputTransparent") == nil then
                    obj:SetAttribute("__origInputTransparent", obj.InputTransparent)
                end
                obj.InputTransparent = flag
            end
        end
    end)
end

local function restoreUIInputTransparent(root)
    if not root then return end
    pcall(function()
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("GuiObject") then
                local orig = obj:GetAttribute("__origInputTransparent")
                if orig ~= nil then
                    obj.InputTransparent = orig
                    obj:SetAttribute("__origInputTransparent", nil)
                end
            end
        end
    end)
end

-- Fire remote events for interaction
local function tryFireRemote(hit)
    local names = {"RemoteEvent", "InteractEvent", "ClickRemote", "PickupEvent"}
    local containers = {game:GetService("ReplicatedStorage"), workspace}
    for _, container in ipairs(containers) do
        for _, name in ipairs(names) do
            local remote = container:FindFirstChild(name, true)
            if remote and remote:IsA("RemoteEvent") then
                local success = pcall(function() remote:FireServer(hit) end)
                if success then return true end
            end
        end
    end
    return false
end

-- Simulate in-game click using VirtualUser
local function SimulateInGameClick(screenPos)
    if not screenPos or not screenPos.X or not screenPos.Y then return false end
    local camera = workspace.CurrentCamera
    if not camera then return false end

    local ray = camera:ScreenPointToRay(screenPos.X, screenPos.Y)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character or {}}

    local success, result = pcall(function()
        return workspace:Raycast(ray.Origin, ray.Direction * 2000, raycastParams)
    end)

    if success and result and result.Instance then
        local hit = result.Instance
        local clickDetector = hit:FindFirstAncestorOfClass("ClickDetector") or hit:FindFirstChildOfClass("ClickDetector")
        if clickDetector then
            local success = pcall(function() fireclickdetector(clickDetector) end)
            if success then return true end
        end

        local proximityPrompt = hit:FindFirstAncestorOfClass("ProximityPrompt") or hit:FindFirstChildOfClass("ProximityPrompt")
        if proximityPrompt then
            local success = pcall(function() fireproximityprompt(proximityPrompt) end)
            if success then return true end
        end

        if tryFireRemote(hit) then return true end

        local methods = {"Activate", "Click", "Fire", "FireServer", "OnClick"}
        for _, method in ipairs(methods) do
            local success = pcall(function()
                if hit[method] and type(hit[method]) == "function" then hit[method](hit) end
            end)
            if success then return true end
        end
    end

    -- Use VirtualUser to simulate mouse click
    local success = pcall(function()
        VirtualUser:ClickButton1(Vector2.new(screenPos.X, screenPos.Y))
    end)
    return success
end

-- Auto-click loop
local function ClickLoop_InGame()
    local camera = workspace.CurrentCamera
    if not camera then return end
    local viewport = camera.ViewportSize
    local pos = _G.autoClickPos or {X = viewport.X / 2, Y = viewport.Y / 2}

    if HubGuiRoot then setUIInputTransparent(HubGuiRoot, true) end
    pcall(SimulateInGameClick, pos)
end

-- Safe teleport with tweening
local function SafeTeleport(position)
    if not humanoidRootPart or not humanoidRootPart.Parent then
        updateLabel(StatusLabel, "❌ Error: Character not found")
        return
    end
    pcall(function()
        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
        tween:Play()
        updateLabel(StatusLabel, "Teleported to: " .. tostring(position))
        task.spawn(function()
            task.wait(2)
            if not _G.isLoopRunning then
                updateLabel(StatusLabel, "Status: Ready")
            end
        end)
    end)
end

-- Server hopping logic
local visitedServers = {}

local function RejoinServer()
    local placeId = game.PlaceId
    local jobId = game.JobId
    pcall(function()
        TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
    end)
end

local function ServerHop()
    local placeId = game.PlaceId
    local servers = {}
    local cursor

    repeat
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s"):format(placeId, cursor and "&cursor=" .. cursor or "")
        local success, response = pcall(HttpService.GetAsync, HttpService, url)
        if success then
            local decoded = HttpService:JSONDecode(response)
            for _, server in ipairs(decoded.data or {}) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    table.insert(servers, server.id)
                end
            end
            cursor = decoded.nextPageCursor
        else
            warn("ServerHop: Failed to fetch server list")
            break
        end
    until not cursor

    if #servers > 0 then
        pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], LocalPlayer)
        end)
    else
        warn("ServerHop: No available servers")
    end
end

local function RandomServer()
    ServerHop() -- Reuses ServerHop logic for simplicity
end

local function SecureServer()
    local placeId = game.PlaceId
    local cursor

    repeat
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s"):format(placeId, cursor and "&cursor=" .. cursor or "")
        local success, response = pcall(HttpService.GetAsync, HttpService, url)
        if success then
            local decoded = HttpService:JSONDecode(response)
            for _, server in ipairs(decoded.data or {}) do
                if server.playing < server.maxPlayers and not visitedServers[server.id] and server.id ~= game.JobId then
                    visitedServers[server.id] = true
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                    end)
                    return
                end
            end
            cursor = decoded.nextPageCursor
        else
            warn("SecureServer: Failed to fetch server list")
            break
        end
    until not cursor
    warn("SecureServer: No unvisited servers available")
end

-- Create UI Window
local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.2.0",
    Description = "By lphisv5 | Game: Fish IT",
    Keybind = Enum.KeyCode.RightShift,
    Logo = "http://www.roblox.com/asset/?id=125456335927282"
}) or (warn("Failed to create UI window") and return)

-- UI Tabs and Sections
local HomeTab = Window:NewTab({Title = "Home", Description = "Main Features", Icon = "rbxassetid://7733960981"})
local AutoClickTab = Window:NewTab({Title = "Main", Description = "Auto Click Features", Icon = "rbxassetid://7733960981"})
local TeleportTab = Window:NewTab({Title = "Teleport", Description = "Teleport to Locations", Icon = "rbxassetid://7733960981"})
local ServerTab = Window:NewTab({Title = "Server", Description = "Server Management Tools", Icon = "rbxassetid://7733960981"})
local HomeSection = HomeTab:NewSection({Title = "Main Controls", Icon = "rbxassetid://7733916988", Position = "Left"})
local AutoClickSection = AutoClickTab:NewSection({Title = "Controls", Icon = "rbxassetid://7733916988", Position = "Left"})
local SettingsSection = AutoClickTab:NewSection({Title = "Speed Settings", Icon = "rbxassetid://7743869054", Position = "Right"})
local TeleportSection = TeleportTab:NewSection({Title = "Locations", Icon = "rbxassetid://7733916988", Position = "Left"})
local ServerSection = ServerTab:NewSection({Title = "Server Controls", Icon = "rbxassetid://7733916988", Position = "Left"})

-- UI Elements
local posLabel = AutoClickSection:NewTitle("Player Pos: Waiting...")
local StatusLabel = AutoClickSection:NewTitle("Status: Ready")

-- Global Variables
_G.clickDelay = _G.clickDelay or 0.1
_G.autoClickPos = _G.autoClickPos or nil
_G.isLoopRunning = _G.isLoopRunning or false

-- Helper: Update UI Label
local function updateLabel(label, text)
    pcall(function()
        if typeof(label) == "Instance" then
            label.Text = tostring(text)
        elseif label.Set then
            label:Set(tostring(text))
        elseif label.SetText then
            label:SetText(tostring(text))
        elseif label.SetTitle then
            label:SetTitle(tostring(text))
        end
    end)
end

-- Connection Management
local connections = {}
local function addConnection(conn)
    if conn then table.insert(connections, conn) end
    return conn
end

-- Home: Join Discord
HomeSection:NewButton({
    Title = "Join Discord",
    Icon = "rbxassetid://7733960981",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/DfVuhsZb")
            NothingLibrary:Notify({
                Title = "Join Our Discord!",
                Content = "Discord link copied to clipboard!",
                Duration = 5
            })
        end)
    end
})

-- Auto Click Toggle
local autoToggle = AutoClickSection:NewToggle({
    Title = "Auto Click",
    Default = _G.isLoopRunning,
    Callback = function(value)
        _G.isLoopRunning = value
        if value then
            updateLabel(StatusLabel, "Auto Clicking Active")
            task.spawn(function()
                while _G.isLoopRunning do
                    ClickLoop_InGame()
                    task.wait(_G.clickDelay)
                end
            end)
            if HubGuiRoot then restoreUIInputTransparent(HubGuiRoot) end
        else
            updateLabel(StatusLabel, "Status: Ready")
        end
    end
})

-- Set Click Position
AutoClickSection:NewButton({
    Title = "Set Click Position",
    Callback = function()
        local settingPosition = true
        updateLabel(StatusLabel, "🖱️ Click to set position...")
        local conn = addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not settingPosition then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                _G.autoClickPos = {X = mousePos.X, Y = mousePos.Y}
                updateLabel(StatusLabel, "✅ Position set: " .. math.floor(mousePos.X) .. ", " .. math.floor(mousePos.Y))
                settingPosition = false
                conn:Disconnect()
            end
        end))
        task.delay(10, function()
            if settingPosition then
                settingPosition = false
                conn:Disconnect()
                updateLabel(StatusLabel, "❌ Position set cancelled")
                task.wait(2)
                if not _G.isLoopRunning then updateLabel(StatusLabel, "Status: Ready") end
            end
        end)
    end
})

-- Speed Settings
local speeds = {
    {label = "ULTRA FAST", value = 0.01},
    {label = "FAST", value = 0.3},
    {label = "NORMAL", value = 1},
    {label = "SLOW", value = 1.5}
}
for _, speed in ipairs(speeds) do
    SettingsSection:NewButton({
        Title = speed.label .. " (" .. speed.value .. "s)",
        Callback = function()
            _G.clickDelay = speed.value
            updateLabel(StatusLabel, "Delay: " .. speed.value .. "s")
            NothingLibrary:Notify({
                Title = "Speed Updated",
                Content = "Click delay set to " .. speed.value .. "s",
                Duration = 2
            })
        end
    })
end

-- Teleport Locations
local locations = {
    {name = "Fisherman Island", pos = Vector3.new(93.29, 17.00, 2823.20)},
    {name = "Coral Reefs", pos = Vector3.new(-2768.11, 20.11, 2083.68)},
    {name = "Kohana", pos = Vector3.new(-643.90, 35.72, 599.1)},
    {name = "Esoteric Depths", pos = Vector3.new(2035.09, 27.00, 1388.06)},
    {name = "Crystal Island", pos = Vector3.new(895.45, 30.20, 5000.37)},
    {name = "Tropical Grove", pos = Vector3.new(-2066.23, 6.38, 3733.50)},
    {name = "Lost Isle", pos = Vector3.new(-3666.00, 37.50, 983.85)},
    {name = "Weather Machine", pos = Vector3.new(-1515.33, 6.54, 1871.41)}
}
for _, loc in ipairs(locations) do
    TeleportSection:NewButton({
        Title = "Teleport to " .. loc.name,
        Callback = function() SafeTeleport(loc.pos) end
    })
end

-- Server Management Buttons
ServerSection:NewButton({
    Title = "Rejoin Server",
    Callback = function()
        NothingLibrary:Notify({Title = "Rejoining...", Content = "Rejoining current server...", Duration = 3})
        RejoinServer()
    end
})
ServerSection:NewButton({
    Title = "Server Hop",
    Callback = function()
        NothingLibrary:Notify({Title = "Server Hop", Content = "Finding new server...", Duration = 3})
        ServerHop()
    end
})
ServerSection:NewButton({
    Title = "Random Server",
    Callback = function()
        NothingLibrary:Notify({Title = "Random Server", Content = "Joining random server...", Duration = 3})
        RandomServer()
    end
})
ServerSection:NewButton({
    Title = "Secure Server",
    Callback = function()
        NothingLibrary:Notify({Title = "Secure Server", Content = "Searching for unvisited server...", Duration = 3})
        SecureServer()
    end
})

-- Position Updater
local function startPositionUpdater(character)
    humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
    addConnection(RunService.RenderStepped:Connect(function()
        pcall(function()
            if humanoidRootPart and humanoidRootPart.Parent then
                local pos = humanoidRootPart.Position
                updateLabel(posLabel, string.format("Player Pos: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z))
            else
                updateLabel(posLabel, "Player Pos: Waiting...")
            end
        end)
    end))
end

if LocalPlayer.Character then
    startPositionUpdater(LocalPlayer.Character)
end
addConnection(LocalPlayer.CharacterAdded:Connect(startPositionUpdater))

-- Emergency Stop (F6)
addConnection(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or input.KeyCode ~= Enum.KeyCode.F6 then return end
    _G.isLoopRunning = not _G.isLoopRunning
    pcall(function()
        if autoToggle.Set then
            autoToggle:Set(_G.isLoopRunning)
        elseif autoToggle.SetValue then
            autoToggle:SetValue(_G.isLoopRunning)
        end
    end)
    if _G.isLoopRunning then
        updateLabel(StatusLabel, "Auto Clicking Active (F6)")
        task.spawn(function()
            while _G.isLoopRunning do
                ClickLoop_InGame()
                task.wait(_G.clickDelay)
            end
        end)
    else
        updateLabel(StatusLabel, "Emergency Stopped (F6)")
        task.wait(2)
        if not _G.isLoopRunning then updateLabel(StatusLabel, "Status: Ready") end
    end
    if HubGuiRoot then restoreUIInputTransparent(HubGuiRoot) end
end))

-- Cleanup on Player Removal
local function cleanup()
    _G.isLoopRunning = false
    for _, conn in ipairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    pcall(function()
        if Window.Destroy then Window:Destroy() elseif Window.Close then Window:Close() end
    end)
end
addConnection(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then cleanup() end
end))
