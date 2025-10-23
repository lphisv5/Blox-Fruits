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

local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

local ok_vu, VirtualUser = pcall(function() return game:GetService("VirtualUser") end)
if not ok_vu then VirtualUser = nil end

-- Local state แทน _G เพื่อป้องกัน collision
local state = {
    clickDelay = 0.1,
    autoClickPos = {X = nil, Y = nil},
    isLoopRunning = false
}

-- เปลี่ยนไปใช้ OrionLib ที่โหลดได้แน่นอน
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

local Window = OrionLib:MakeWindow({
    Name = "YANZ HUB | V0.1.9",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "YANZHUB",
    IntroEnabled = false
})

OrionLib:MakeNotification({
    Name = "YANZ HUB Loaded",
    Content = "สคริปต์โหลดสำเร็จ! กด RightShift เพื่อเปิด/ปิด UI",
    Image = "rbxassetid://4483345998",
    Time = 5
})

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

-- Unique attribute name
local ORIGINAL_ATTR = "__yanz_orig_InputTransparent"

local function setUIInputTransparent(root, flag)
    if not root then return end
    pcall(function()
        for _, obj in ipairs(root:GetDescendants()) do
            if obj:IsA("GuiObject") then
                if obj:GetAttribute(ORIGINAL_ATTR) == nil then
                    obj:SetAttribute(ORIGINAL_ATTR, obj.InputTransparent)
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
                local v = obj:GetAttribute(ORIGINAL_ATTR)
                if v ~= nil then
                    obj.InputTransparent = v
                    obj:SetAttribute(ORIGINAL_ATTR, nil)
                end
            end
        end
    end)
end

local function tryFireRemote(hit)
    local containers = {game:GetService("ReplicatedStorage"), workspace}
    local names = {"RemoteEvent", "InteractEvent", "ClickRemote", "PickupEvent"}
    for _, container in ipairs(containers) do
        for _, name in ipairs(names) do
            local remote = container:FindFirstChild(name, true)
            if remote then
                if remote:IsA("RemoteEvent") then
                    local ok = pcall(remote.FireServer, remote, hit)
                    if ok then return true end
                elseif remote:IsA("RemoteFunction") then
                    local ok2, _ = pcall(function() remote:InvokeServer(hit) end)
                    if ok2 then return true end
                end
            end
        end
    end
    return false
end

local function getSafeRaycastParams()
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    local filter = {}
    if LocalPlayer and LocalPlayer.Character then table.insert(filter, LocalPlayer.Character) end
    rp.FilterDescendantsInstances = filter
    return rp
end

local function SimulateInGameClick(screenPos)
    if not screenPos or not screenPos.X or not screenPos.Y then return false end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    local ray = cam:ScreenPointToRay(screenPos.X, screenPos.Y)
    local rp = getSafeRaycastParams()
    local ok, res = pcall(function() return workspace:Raycast(ray.Origin, ray.Direction * 2000, rp) end)

    if ok and res and res.Instance then
        local hit = res.Instance

        local cd = (hit.FindFirstAncestorWhichIsA and hit:FindFirstAncestorWhichIsA("ClickDetector")) or hit:FindFirstChildOfClass("ClickDetector")
        if cd and cd:IsA("ClickDetector") then
            local s = pcall(function()
                if cd.FireClick then
                    pcall(function() cd:FireClick(LocalPlayer) end)
                    pcall(function() cd:FireClick() end)
                end
            end)
            if s then return true end
        end

        local prompt = (hit.FindFirstAncestorWhichIsA and hit:FindFirstAncestorWhichIsA("ProximityPrompt")) or hit:FindFirstChildOfClass("ProximityPrompt")
        if prompt and prompt:IsA("ProximityPrompt") then
            local s2 = pcall(function()
                if prompt.Triggered then
                    prompt:InputHoldBegin()
                    prompt:InputHoldEnd()
                else
                    if prompt.Trigger then pcall(function() prompt:Trigger() end) end
                    if prompt.InputHoldBegin then pcall(function() prompt:InputHoldBegin() end) end
                    if prompt.InputHoldEnd then pcall(function() prompt:InputHoldEnd() end) end
                end
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

    if VirtualUser then
        local okvu = pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(screenPos.X, screenPos.Y))
        end)
        if okvu then return true end
    elseif VirtualInputManager then
        local okvm = pcall(function()
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, workspace)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, workspace)
        end)
        if okvm then return true end
    end

    return false
end

local function ClickLoop_InGame()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    local pos = (state.autoClickPos and state.autoClickPos.X and state.autoClickPos.Y) and state.autoClickPos or {X = viewport.X / 2, Y = viewport.Y / 2}

    if HubGuiRoot then setUIInputTransparent(HubGuiRoot, true) end
    pcall(function() SimulateInGameClick(pos) end)
end

local clickLoopThread
local function startAutoClick()
    if clickLoopThread then return end
    state.isLoopRunning = true
    clickLoopThread = task.spawn(function()
        while state.isLoopRunning do
            ClickLoop_InGame()
            task.wait(state.clickDelay or 0.1)
        end
        clickLoopThread = nil
    end)
end

local function stopAutoClick()
    state.isLoopRunning = false
end

local humanoidRootPart
local positionRenderConn

local function SafeTeleport(position)
    if not LocalPlayer.Character or not LocalPlayer.Character.PrimaryPart then
        OrionLib:MakeNotification({
            Name = "Teleport Error",
            Content = "❌ Error: Character or PrimaryPart not found",
            Time = 3
        })
        return
    end
    pcall(function()
        LocalPlayer.Character:PivotTo(CFrame.new(position))
        OrionLib:MakeNotification({
            Name = "Teleport Success",
            Content = "Teleported to: " .. tostring(position),
            Time = 3
        })
        task.delay(2, function()
            if not state.isLoopRunning then
                -- Update status if needed
            end
        end)
    end)
end

local visitedServers = {}

local function fetchServersPage(placeId, cursor)
    local url = ("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100%s"):format(placeId, cursor and "&cursor="..cursor or "")
    local ok, res = pcall(function() return HttpService:GetAsync(url, true) end)
    if not ok or not res then return nil, "http_error" end
    local ok2, data = pcall(function() return HttpService:JSONDecode(res) end)
    if not ok2 or type(data) ~= "table" then return nil, "json_error" end
    return data
end

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
        local data, err = fetchServersPage(placeId, nextPageCursor)
        if not data then
            warn("ServerHop:", err)
            break
        end
        for _, v in ipairs(data.data or {}) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id)
            end
        end
        nextPageCursor = data.nextPageCursor
        task.wait(0.2) -- backoff
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
        local data, err = fetchServersPage(placeId, cursor)
        if not data then
            warn("RandomServer:", err)
            break
        end
        for _, v in ipairs(data.data or {}) do
            if v.playing < v.maxPlayers then
                table.insert(allServers, v.id)
            end
        end
        cursor = data.nextPageCursor
        task.wait(0.2)
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
        local data, err = fetchServersPage(placeId, cursor)
        if not data then
            warn("SecureServer:", err)
            break
        end
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
        task.wait(0.2)
    until not cursor

    warn("SecureServer: No new server available")
end

-- Tabs with Orion
local HomeTab = Window:MakeTab({
    Name = "Home",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AutoClickTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TeleportTab = Window:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ServerTab = Window:MakeTab({
    Name = "Server",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Sections
local HomeSection = HomeTab:AddSection({
    Name = "Main Controls"
})

local AutoClickSection = AutoClickTab:AddSection({
    Name = "Controls"
})

local SettingsSection = AutoClickTab:AddSection({
    Name = "Speed Settings"
})

local TeleportSection = TeleportTab:AddSection({
    Name = "Locations"
})

local ServerSection = ServerTab:AddSection({
    Name = "Server Controls"
})

-- Position Label (เก็บ reference เพื่ออัพเดท)
local posLabelRef = AutoClickTab:AddLabel("Player Pos: Waiting...")

-- Improved updateLabel สำหรับ Orion (ใช้ :Set)
local function updateLabel(ref, text)
    if not ref then return end
    pcall(function()
        if ref.Set and type(ref.Set) == "function" then
            ref:Set(tostring(text))
        end
    end)
end

-- Status Label
local statusLabelRef = AutoClickTab:AddLabel("Status: Ready")

-- Connections manager
local Connections = {}
local function addConn(conn)
    if conn and (typeof(conn) == "RBXScriptConnection" or (type(conn) == "table" and conn.Disconnect)) then
        table.insert(Connections, conn)
    end
    return conn
end

local function DisconnectAll()
    for i = #Connections, 1, -1 do
        local c = Connections[i]
        pcall(function()
            if c and c.Disconnect then c:Disconnect() end
        end)
        Connections[i] = nil
    end
end

-- Home: Join Discord
HomeTab:AddButton({
    Name = "Join Discord",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/DfVuhsZb")
            OrionLib:MakeNotification({
                Name = "Join Our Discord!",
                Content = "Discord link has been copied to your clipboard! - https://discord.gg/DfVuhsZb",
                Time = 5
            })
        end)
    end
})

-- Auto Click Toggle
local autoToggle = AutoClickTab:AddToggle({
    Name = "Auto Click",
    Default = state.isLoopRunning,
    Callback = function(value)
        if value then
            startAutoClick()
            updateLabel(statusLabelRef, "Auto Clicking Active")
            if HubGuiRoot then restoreUIInputTransparent(HubGuiRoot) end
        else
            stopAutoClick()
            updateLabel(statusLabelRef, "Status: Ready")
        end
    end
})

-- Set Click Position Button
AutoClickTab:AddButton({
    Name = "SET CLICK POSITION",
    Callback = function()
        local settingPosition = true
        updateLabel(statusLabelRef, "🖱️ Click anywhere to set position...")
        local conn
        conn = addConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not settingPosition then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mousePos = UserInputService:GetMouseLocation()
                state.autoClickPos = {X = mousePos.X, Y = mousePos.Y}
                updateLabel(statusLabelRef, "✅ Position set: " .. math.floor(mousePos.X) .. ", " .. math.floor(mousePos.Y))
                settingPosition = false
                if conn then conn:Disconnect() end
            end
        end))
        task.delay(10, function()
            if settingPosition then
                settingPosition = false
                if conn then conn:Disconnect() end
                updateLabel(statusLabelRef, "❌ Position set cancelled")
                task.wait(2)
                if not state.isLoopRunning then
                    updateLabel(statusLabelRef, "Status: Ready")
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
    AutoClickTab:AddButton({
        Name = speedData.label .. " (" .. speedData.value .. "s)",
        Callback = function()
            state.clickDelay = speedData.value
            updateLabel(statusLabelRef, "Delay: " .. speedData.value .. "s")
            OrionLib:MakeNotification({
                Name = "Speed Updated",
                Content = "Click delay set to " .. speedData.value .. "s",
                Time = 2
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

for _, location in ipairs(locations) do
    TeleportTab:AddButton({
        Name = "Teleport to " .. location.name,
        Callback = function()
            SafeTeleport(location.pos)
        end
    })
end

-- Server tab buttons
ServerTab:AddButton({
    Name = "Rejoin Server",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Rejoining...",
            Content = "Rejoining the current server...",
            Time = 3
        })
        RejoinServer()
    end
})

ServerTab:AddButton({
    Name = "Server Hop",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Server Hop",
            Content = "Finding new server to join...",
            Time = 3
        })
        ServerHop()
    end
})

ServerTab:AddButton({
    Name = "Random Server",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Random Server",
            Content = "Joining random available server...",
            Time = 3
        })
        RandomServer()
    end
})

ServerTab:AddButton({
    Name = "Secure Server",
    Callback = function()
        OrionLib:MakeNotification({
            Name = "Secure Server",
            Content = "Searching for safe server (unvisited)...",
            Time = 3
        })
        SecureServer()
    end
})

local function startPositionUpdater(character)
    if positionRenderConn then
        pcall(function() positionRenderConn:Disconnect() end)
        positionRenderConn = nil
    end
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    if humanoidRootPart then
        character.PrimaryPart = humanoidRootPart
    end

    positionRenderConn = RunService.RenderStepped:Connect(function()
        pcall(function()
            if humanoidRootPart and humanoidRootPart.Parent then
                local pos = humanoidRootPart.Position
                updateLabel(posLabelRef, string.format("Player Pos: X=%.1f Y=%.1f Z=%.1f", pos.X, pos.Y, pos.Z))
            else
                updateLabel(posLabelRef, "Player Pos: Waiting...")
            end
        end)
    end)
    addConn(positionRenderConn)
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
        if state.isLoopRunning then
            stopAutoClick()
            updateLabel(statusLabelRef, "Emergency Stopped (F6)")
            task.wait(2)
            updateLabel(statusLabelRef, "Status: Ready")
        else
            startAutoClick()
            updateLabel(statusLabelRef, "Auto Clicking Active (F6)")
        end
        pcall(function()
            if autoToggle and autoToggle:Set then
                autoToggle:Set(state.isLoopRunning)
            end
        end)
        if HubGuiRoot then restoreUIInputTransparent(HubGuiRoot) end
    end
end))

local function cleanup()
    stopAutoClick()
    DisconnectAll()
    pcall(function()
        OrionLib:Destroy()
    end)
end

addConn(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then cleanup() end
end))

-- Set keybind for Orion (RightShift)
Window:ToggleKey(Enum.KeyCode.RightShift)
