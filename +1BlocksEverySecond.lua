-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Player
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Virtual Input (pcall เพราะบาง client อาจไม่มี)
local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

-- Load Nothing Library (แก้ URL ได้แล้ว)
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

-- Window + Tabs
local Window = NothingLibrary.new({
    Title = "YANZ HUB | V0.2.1",
    Description = "By lphisv5 | Game : +1 Blocks Every Second",
    Keybind = Enum.KeyCode.RightShift,
    Logo = 'http://www.roblox.com/asset/?id=125456335927282'
})

-- HOME Tab (Discord)
local HomeTab = Window:NewTab({Title = "HOME", Description = "Home Features", Icon = "rbxassetid://7733960981"})
local HomeSection = HomeTab:NewSection({Title = "Home", Icon = "rbxassetid://7733916988", Position = "Left"})
HomeSection:NewButton({
    Title = "Join Discord",
    Icon = "rbxassetid://7733960981",
    Callback = function()
        pcall(function()
            setclipboard("https://discord.gg/DfVuhsZb")
            NothingLibrary:Notify({Title = "Copied!", Content = "Successfully copied the link", Duration = 5})
        end)
    end
})

-- MAIN Tab (Auto Farm Block)
local MainTab = Window:NewTab({Title = "MAIN", Description = "Auto Farm Features", Icon = "rbxassetid://7733960981"})
local MainControlsSection = MainTab:NewSection({Title = "Controls", Icon = "rbxassetid://7733916988", Position = "Left"})
local StatusLabel = MainControlsSection:NewTitle("Status: Sleeping")

-- Globals
local isLoopRunning = false
local lastRun = false
local loopThread = nil
local connections = {}
local cachedClickRemote = nil -- เก็บ remote ที่หาเจอเพื่อเรียกซ้ำได้เร็วขึ้น

local function addConn(conn) if conn then table.insert(connections, conn) end return conn end
local function updateLabel(lbl, text) if not lbl then return end pcall(function()
    if typeof(lbl) == "Instance" and lbl.Text ~= nil then lbl.Text = tostring(text) end
    if lbl.Set then lbl:Set(tostring(text)) end
    if lbl.SetText then lbl:SetText(tostring(text)) end
    if lbl.SetTitle then lbl:SetTitle(tostring(text)) end
end) end

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

-- Utility: พยายามหา RemoteEvent/RemoteFunction ที่น่าจะเป็น "click/attack"
local commonNames = {
    "Click", "click", "Fire", "fire", "Attack", "attack", "Swing", "swing",
    "Hit", "hit", "Remote", "remote", "Use", "use", "HitEvent", "ClickEvent",
    "FireServer", "Activate", "Punch", "tap", "Touch"
}

local function isRemote(obj)
    return obj and (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction"))
end

local function scanForClickRemote()
    -- ถ้ามี cache อยู่ ให้ลองใช้อีกครั้งก่อน
    if cachedClickRemote and isRemote(cachedClickRemote) then
        return cachedClickRemote
    end

    -- แหล่งข้อมูลที่น่าจะมี remote
    local searchPlaces = {
        ReplicatedStorage,
        workspace,
        game:GetService("ServerScriptService") or nil, -- บางกรณี
        LocalPlayer.Backpack,
        LocalPlayer.Character
    }

    -- search โดยชื่อ common
    for _, parent in ipairs(searchPlaces) do
        if parent then
            for _, name in ipairs(commonNames) do
                local found = parent:FindFirstChild(name, true) -- true เพื่อค้นหาแบบ deep (บาง API อาจไม่รองรับ FindFirstChild(name, true) ในบางสโคป — แต่พยายามใช้)
                if found and isRemote(found) then
                    cachedClickRemote = found
                    return found
                end
            end
            -- ถ้ายังไม่เจอ ลองไล่ทุก Remote ใน parent
            for _, child in ipairs(parent:GetDescendants()) do
                if isRemote(child) then
                    -- heuristic: ถ้าชื่อสั้นหรือมีคำที่คาดว่าเกี่ยวกับคลิก ก็เก็บ
                    local lname = tostring(child.Name):lower()
                    for _, nm in ipairs(commonNames) do
                        if lname:find(nm:lower()) then
                            cachedClickRemote = child
                            return child
                        end
                    end
                end
            end
        end
    end

    -- ไม่พบเลย
    return nil
end

-- FastAttack: พยายามเรียก tool, ถ้าไม่มีจะใช้ Remote ถ้าไม่มีอีกจะ fallback เป็น VirtualInput click top-left (10%,10%)
local function FastAttack()
    -- 1) ถ้ามี Tool ให้ Activate / Fire Remote ใน Tool
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                -- พยายาม Activate tool
                if tool.Activate then
                    tool:Activate()
                end
                -- ถ้ามี Remote อยู่ใน Tool ให้ FireServer / InvokeServer
                for _, child in ipairs(tool:GetDescendants()) do
                    if isRemote(child) then
                        pcall(function()
                            if child:IsA("RemoteEvent") then child:FireServer() end
                            if child:IsA("RemoteFunction") then child:InvokeServer() end
                        end)
                        return true
                    end
                end
                return true
            end)
            return
        end
    end

    -- 2) พยายามหา Remote ทั่วเกม (cachedClickRemote จะช่วยให้เร็วขึ้น)
    local remote = scanForClickRemote()
    if remote then
        pcall(function()
            if remote:IsA("RemoteEvent") then
                -- พยายาม FireServer แบบปลอดภัย (บาง remote ต้องการ arguments — เราส่งเปล่าเป็นค่าเริ่มต้น)
                remote:FireServer()
            elseif remote:IsA("RemoteFunction") then
                remote:InvokeServer()
            end
        end)
        return
    end

    -- 3) Fallback: ส่ง VirtualInput click ที่มุมบนซ้ายเล็กน้อย (10%,10%)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local viewport = cam.ViewportSize
    local posX = math.floor(viewport.X * 0.1)
    local posY = math.floor(viewport.Y * 0.1)
    if VirtualInputManager then
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(posX, posY, 0, true, cam, 1)
            VirtualInputManager:SendMouseButtonEvent(posX, posY, 0, false, cam, 1)
        end)
    end
end

-- Auto Farm Loop (delay 0.5 - 2s แบบสุ่ม)
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

-- Toggle UI
MainControlsSection:NewToggle({
    Title = "Auto Farm Block",
    Default = false,
    Callback = function(value)
        isLoopRunning = value
        updateStatus()
        if isLoopRunning then startAutoFarm() end
    end
})

-- Hotkeys F6 / F7
addConn(UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        isLoopRunning = not isLoopRunning
        updateStatus()
        if isLoopRunning then startAutoFarm() end
    elseif input.KeyCode == Enum.KeyCode.F7 then
        isLoopRunning = false
        updateStatus()
    end
end))

-- ============= NEW: Settings Tab =============

local SettingsTab = Window:NewTab({Title = "Settings", Description = "Configuration", Icon = "rbxassetid://7733960981"})
local AntiAFKSection = SettingsTab:NewSection({Title = "Anti-AFK", Icon = "rbxassetid://7733916988", Position = "Left"})

-- Anti-AFK Variables
local isAntiAFKEnabled = false
local antiAFKConnection = nil

local function startAntiAFK()
    if antiAFKConnection then antiAFKConnection:Disconnect() end
    local vu = game:GetService("VirtualUser")
    antiAFKConnection = RunService.Stepped:Connect(function()
        vu:CaptureController()
        vu:ClickButton1(Vector2.new(0, 0)) -- คลิกที่จุดเริ่มต้น (ด้านบนซ้าย)
    end)
end

local function stopAntiAFK()
    if antiAFKConnection then
        antiAFKConnection:Disconnect()
        antiAFKConnection = nil
    end
end

AntiAFKSection:NewToggle({
    Title = "Anti-AFK",
    Default = false,
    Callback = function(value)
        isAntiAFKEnabled = value
        if isAntiAFKEnabled then
            startAntiAFK()
        else
            stopAntiAFK()
        end
    end
})

-- =============================================

-- Cleanup
local function cleanup()
    isLoopRunning = false
    stopAntiAFK()
    for _, c in ipairs(connections) do
        pcall(function() if c and c.Disconnect then c:Disconnect() end end)
    end
    connections = {}
    pcall(function()
        if Window and Window.Destroy then Window:Destroy() end
        if Window and Window.Close then Window:Close() end
    end)
end
addConn(Players.PlayerRemoving:Connect(function(player)
    if player == LocalPlayer then cleanup() end
end))

updateStatus()
