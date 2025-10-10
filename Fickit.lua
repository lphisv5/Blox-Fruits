local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local ok_lib, NothingLibrary = pcall(function()
    local code = game:HttpGetAsync(libURL)
    if code then
        print("first 1000 chars:", code:sub(1, 1000))
        local func, err = loadstring(code)
        if not func then
            warn("Loadstring error:", err)
            return nil
        end
        return func()
    else
        warn("Failed to fetch Nothing Library from URL:", libURL)
        return nil
    end
end)
if not ok_lib or not NothingLibrary then
    warn("Failed to load Nothing UI Library. Error or code issue:", NothingLibrary)
    return
end

local function findHubGui()
    local function scan(container)
        for _, v in ipairs(container:GetDescendants()) do
            if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
                local ok, txt = pcall(function() return v.Text end)
                if ok and type(txt) == "string" and txt:match("YANZ HUB") then
                    local top = v
                    while top.Parent and not top:IsA("ScreenGui") do
                        top = top.Parent
                    end
                    if top and top:IsA("ScreenGui") then return top end
                    return v
                end
            end
        end
    end

    local ok, res = pcall(function()
        local plrGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if plrGui then
            local found = scan(plrGui)
            if found then return found end
        end
        if game:GetService("CoreGui") then
            local found2 = scan(game:GetService("CoreGui"))
            if found2 then return found2 end
        end
        return nil
    end)
    if ok then return res end
    return nil
end

local HubGuiRoot = findHubGui()

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
                local v = obj:GetAttribute("__origInputTransparent")
                if v ~= nil then
                    obj.InputTransparent = v
                    obj:SetAttribute("__origInputTransparent", nil)
                end
            end
        end
    end)
end

local function tryFireRemote(hit)
    local names = {"RemoteEvent", "InteractEvent", "ClickRemote", "PickupEvent"}
    local paths = {game:GetService("ReplicatedStorage"), workspace}
    for _, container in ipairs(paths) do
        for _, name in ipairs(names) do
            local remote = container:FindFirstChild(name, true)
            if remote and remote:IsA("RemoteEvent") then
                local ok = pcall(function() remote:FireServer(hit) end)
                if ok then return true end
            end
        end
    end
    return false
end

local function SimulateInGameClick(screenPos)
    if not screenPos or not screenPos.X or not screenPos.Y then return false end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local ray = cam:ScreenPointToRay(screenPos.X, screenPos.Y)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = {LocalPlayer.Character or {}}

    local ok, res = pcall(function()
        return workspace:Raycast(ray.Origin, ray.Direction * 2000, rp)
    end)

    if ok and res and res.Instance then
        local hit = res.Instance

        local cd = (hit.FindFirstAncestorWhichIsA and hit:FindFirstAncestorWhichIsA("ClickDetector")) or hit:FindFirstChildOfClass("ClickDetector")
        if cd then
            local s = pcall(function()
                if cd.FireClick then
                    pcall(function() cd:FireClick(LocalPlayer) end)
                    pcall(function() cd:FireClick() end)
                end
            end)
            if s then return true end
        end

        local prompt = (hit.FindFirstAncestorWhichIsA and hit:FindFirstAncestorWhichIsA("ProximityPrompt")) or hit:FindFirstChildOfClass("ProximityPrompt")
        if prompt then
            local s2 = pcall(function()
                if prompt.Trigger then pcall(function() prompt:Trigger() end) end
                if prompt.InputHoldBegin then pcall(function() prompt:InputHoldBegin() end) end
                if prompt.InputHoldEnd then pcall(function() prompt:InputHoldEnd() end) end
            end)
            if s2 then return true end
        end

        if tryFireRemote(hit) then return true end

        local methods = {"Activate", "Click", "Fire", "FireServer", "OnClick"}
        for _, m in ipairs(methods) do
            local succ = pcall(function()
                if hit[m] and type(hit[m]) == "function" then hit[m](hit) end
            end)
            if succ then return true end
        end
    end

    if VirtualInputManager then
        local okvm = pcall(function()
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, workspace, 1)
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, workspace, 1)
        end)
        if okvm then return true end
    end

    return false
end

local function ClickLoop_InGame()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    local pos = (_G.autoClickPos and _G.autoClickPos.X and _G.autoClickPos.Y) and _G.autoClickPos or {X = viewport.X / 2, Y = viewport.Y / 2}

    if HubGuiRoot then setUIInputTransparent(HubGuiRoot, true) end
    pcall(function() SimulateInGameClick(pos) end)
end

local function SafeTeleport(position)
    if not humanoidRootPart or not humanoidRootPart.Parent then
        updateLabel(StatusLabel, "❌ Error: Character not found")
        return
    end
    pcall(function()
        local tweenInfo = TweenInfo.new(
            1,
            Enum.EasingStyle.Linear,
            Enum.EasingDirection.InOut
        )
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
    local nextPageCursor

    repeat
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s"):format(placeId, nextPageCursor and "&cursor="..nextPageCursor or "")
        local success, response = pcall(function() return HttpService:GetAsync(url) end)
        if success then
            local ok, data = pcall(function() return HttpService:JSONDecode(response) end)
            if ok and data then
                for _, v in ipairs(data.data or {}) do
                    if v.playing < v.maxPlayers and v.id ~= game.JobId then
                        table.insert(servers, v.id)
                    end
                end
                nextPageCursor = data.nextPageCursor
            else
                warn("ServerHop: JSON decode failed")
                break
            end
        else
            warn("ServerHop: Failed to fetch server list")
            break
        end
    until not nextPageCursor

    if #servers > 0 then
        local selected = servers[math.random(1,#servers)]
        pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, selected, LocalPlayer)
        end)
    else
        warn("ServerHop: No available server found")
    end
end

local function RandomServer()
    local placeId = game.PlaceId
    local allServers = {}
    local cursor

    repeat
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s"):format(placeId, cursor and "&cursor="..cursor or "")
        local success, response = pcall(function() return HttpService:GetAsync(url) end)
        if not success then break end

        local ok, data = pcall(function() return HttpService:JSONDecode(response) end)
        if not ok or not data then break end

        for _, v in ipairs(data.data or {}) do
            if v.playing < v.maxPlayers then
                table.insert(allServers, v.id)
            end
        end
        cursor = data.nextPageCursor
    until not cursor

    if #allServers > 0 then
        local pick = allServers[math.random(1,#allServers)]
        pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, pick, LocalPlayer)
        end)
    else
        warn("RandomServer: No server available")
    end
end

local function SecureServer()
    local placeId = game.PlaceId
    local cursor

    repeat
        local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s"):format(placeId, cursor and "&cursor="..cursor or "")
        local success, response = pcall(function() return HttpService:GetAsync(url) end)
        if not success then break end

        local ok, data = pcall(function() return HttpService:JSONDecode(response) end)
        if not ok or not data then break end

        for _, v in ipairs(data.data or {}) do
            if v.playing < v.maxPlayers and not visitedServers[v.id] and v.id ~= game.JobId then
                visitedServers[v.id] = true
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, v.id, LocalPlayer)
                end)
                return
            end
        end

        cursor = data.nextPageCursor
    until not cursor

    warn("SecureServer: No new server available")
end

-- Create Window
local Window
local ok_window, res_window = pcall(function()
    return NothingLibrary.new({
        Title = "YANZ HUB | V0.1.9",
        Description = "By lphisv5 | Game : Fich IT",
        Keybind = Enum.KeyCode.RightShift,
        Logo = 'http://www.roblox.com/asset/?id=125456335927282'
    })
end)
if ok_window then Window = res_window else
    warn("Cannot create window from NothingLibrary. Error:", res_window)
    return
end

-- Tabs & Sections
local HomeTab = Window:NewTab({
    Title = "Home",
    Description = "Main Features",
    Icon = "rbxassetid://7733960981"
})
local AutoClickTab = Window:NewTab({
    Title = "Main",
    Description = "Auto Click Features",
    Icon = "rbxassetid://7733960981"
})
local TeleportTab = Window:NewTab({
    Title = "Teleport",
    Description = "Teleport to Locations",
    Icon = "rbxassetid://7733960981"
})
local HomeSection = HomeTab:NewSection({Title = "Main Controls", Icon = "rbxassetid://7733916988", Position = "Left"})
local AutoClickSection = AutoClickTab:NewSection({Title = "Controls", Icon = "rbxassetid://7733916988", Position = "Left"})
local SettingsSection = AutoClickTab:NewSection({Title = "Speed Settings", Icon = "rbxassetid://7743869054", Position = "Right"})
local TeleportSection = TeleportTab:NewSection({Title = "Locations", Icon = "rbxassetid://7733916988", Position = "Left"})

-- New Server Tab
local ServerTab = Window:NewTab({
    Title = "Server",
    Description = "Server Management Tools",
    Icon = "rbxassetid://7733960981"
})
local ServerSection = ServerTab:NewSection({Title = "Server Controls", Icon = "rbxassetid://7733916988", Position = "Left"})

-- Position Label in UI
local posLabel = AutoClickSection:NewTitle("Player Pos: Waiting...")

-- Globals
_G.clickDelay = _G.clickDelay or 0.1
_G.autoClickPos = _G.autoClickPos or {X = nil, Y = nil}
_G.isLoopRunning = _G.isLoopRunning or false

-- Helper: updateLabel
local function updateLabel(lbl, text)
    if not lbl then return end
    pcall(function()
        if typeof(lbl) == "Instance" and lbl.Text ~= nil then lbl.Text = tostring(text) end
        if lbl.Set then lbl:Set(tostring(text)) end
        if lbl.SetText then lbl:SetText(tostring(text)) end
        if lbl.SetTitle then lbl:SetTitle(tostring(text)) end
    end)
end

-- Status Label
local StatusLabel = AutoClickSection:NewTitle("Status: Ready")

-- Connections manager
local connections = {}
local function addConn(conn) if conn then table.insert(connections, conn) end return conn end

-- Home: Join Discord
HomeSection:NewButton({
    Title = "Join Discord",
    Icon = "rbxassetid://7733960981",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/DfVuhsZb")
            pcall(function()
                if NothingLibrary.Notify then
                    NothingLibrary:Notify({
                        Title = "Join Our Discord!",
                        Content = "Discord link has been copied to your clipboard! - https://discord.gg/DfVuhsZb",
                        Duration = 5
                    })
                end
            end)
        end)
    end
})

-- Auto Click Toggle
AutoClickSection:NewToggle({
    Title = "Auto Click",
    Default = _G.isLoopRunning or false,
    Callback = function(value)
        _G.isLoopRunning = value
        if value then
            updateLabel(StatusLabel, "Auto Clicking Active")
            task.spawn(function()
                while _G.isLoopRunning do
                    ClickLoop_InGame()
                    task.wait(_G.clickDelay or 0.1)
                end
            end)
            if HubGuiRoot then restoreUIInputTransparent(HubGuiRoot) end
        else
            updateLabel(StatusLabel, "Status: Ready")
        end
    end
})

-- Set Click Position Button
AutoClickSection:NewButton({
    Title = "SET CLICK POSITION",
    Callback = function()
        local settingPosition = true
        updateLabel(StatusLabel, "🖱️ Click anywhere to set position...")
        local conn
        conn = addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not settingPosition then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                _G.autoClickPos = {X = mousePos.X, Y = mousePos.Y}
                updateLabel(StatusLabel, "✅ Position set: " .. math.floor(mousePos.X) .. ", " .. math.floor(mousePos.Y))
                settingPosition = false
                if conn then conn:Disconnect() end
            end
        end))
        task.delay(10, function()
            if settingPosition then
                settingPosition = false
                if conn then conn:Disconnect() end
                updateLabel(StatusLabel, "❌ Position set cancelled")
                task.wait(2)
                if not _G.isLoopRunning then
                    updateLabel(StatusLabel, "Status: Ready")
                end
            end
        end)
    end
})

-- Speed Buttons
local speeds = {
    {label = "ULTRA FAST", value = 0.01},
    {label = "FAST", value = 0.3},
    {label = "NORMAL", value = 1},
    {label = "SLOW", value = 1.5}
}
for _, speedData in ipairs(speeds) do
    SettingsSection:NewButton({
        Title = speedData.label .. " (" .. speedData.value .. "s)",
        Callback = function()
            _G.clickDelay = speedData.value
            updateLabel(StatusLabel, "Delay: " .. speedData.value .. "s")
            pcall(function()
                if NothingLibrary.Notify then
                    NothingLibrary:Notify({
                        Title = "Speed Updated",
                        Content = "Click delay set to " .. speedData.value .. "s",
                        Duration = 2
                    })
                end
            end)
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

for _, location in ipairs(locations) do
    TeleportSection:NewButton({
        Title = "Teleport to " .. location.name,
        Callback = function()
            SafeTeleport(location.pos)
        end
    })
end

-- Server tab buttons (moved to ServerTab)
ServerSection:NewButton({
    Title = "Rejoin Server",
    Callback = function()
        pcall(function()
            if NothingLibrary.Notify then
                NothingLibrary:Notify({Title = "Rejoining...", Content = "Rejoining the current server...", Duration = 3})
            end
        end)
        RejoinServer()
    end
})

ServerSection:NewButton({
    Title = "Server Hop",
    Callback = function()
        pcall(function()
            if NothingLibrary.Notify then
                NothingLibrary:Notify({Title = "Server Hop", Content = "Finding new server to join...", Duration = 3})
            end
        end)
        ServerHop()
    end
})

ServerSection:NewButton({
    Title = "Random Server",
    Callback = function()
        pcall(function()
            if NothingLibrary.Notify then
                NothingLibrary:Notify({Title = "Random Server", Content = "Joining random available server...", Duration = 3})
            end
        end)
        RandomServer()
    end
})

ServerSection:NewButton({
    Title = "Secure Server",
    Callback = function()
        pcall(function()
            if NothingLibrary.Notify then
                NothingLibrary:Notify({Title = "Secure Server", Content = "Searching for safe server (unvisited)...", Duration = 3})
            end
        end)
        SecureServer()
    end
})

local function startPositionUpdater(character)
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    local renderConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            if humanoidRootPart and humanoidRootPart.Parent then
                local pos = humanoidRootPart.Position
                updateLabel(posLabel, string.format("Player Pos: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z))
            else
                updateLabel(posLabel, "Player Pos: Waiting...")
            end
        end)
    end)
    addConn(renderConn)
end

if LocalPlayer.Character then
    startPositionUpdater(LocalPlayer.Character)
end

addConn(LocalPlayer.CharacterAdded:Connect(function(char)
    startPositionUpdater(char)
end))

addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        _G.isLoopRunning = not _G.isLoopRunning
        pcall(function()
            if autoToggle and autoToggle.Set then
                autoToggle:Set(_G.isLoopRunning)
            elseif autoToggle and autoToggle.SetValue then
                autoToggle:SetValue(_G.isLoopRunning)
            end
        end)
        if _G.isLoopRunning then
            updateLabel(StatusLabel, "Auto Clicking Active (F6)")
            task.spawn(function()
                while _G.isLoopRunning do
                    ClickLoop_InGame()
                    task.wait(_G.clickDelay or 0.2)
                end
            end)
        else
            updateLabel(StatusLabel, "Emergency Stopped (F6)")
            task.wait(2)
            if not _G.isLoopRunning then
                updateLabel(StatusLabel, "Status: Ready")
            end
        end
        if HubGuiRoot then restoreUIInputTransparent(HubGuiRoot) end
    end
end))

local function cleanup()
    _G.isLoopRunning = false
    for _, c in ipairs(connections) do
        pcall(function() if c and c.Disconnect then c:Disconnect() end end)
    end
    pcall(function()
        if Window and Window.Destroy then Window:Destroy() end
        if Window and Window.Close then Window:Close() end
    end)
end

addConn(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then cleanup() end
end))
