-- YANZ HUB | Race Clicker - PROFESSIONAL FIXED VERSION
-- By: assistant (adapted to user's template)
-- Notes: robust load, safe checks, status labels, cleanup, multi-fallback click and speed

--===[ Services ]===--
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- Wait for character a bit
local function WaitCharacter()
    if not LocalPlayer.Character then
        LocalPlayer.CharacterAdded:Wait()
    end
    return LocalPlayer.Character
end

-- VirtualInputManager safe-get
local ok_vim, VirtualInputManager = pcall(function() return game:GetService("VirtualInputManager") end)
if not ok_vim then VirtualInputManager = nil end

--===[ Load NothingLibrary robustly ]===--
local libURL = 'https://raw.githubusercontent.com/3345-c-a-t-s-u-s/NOTHING/main/source.lua'
local NothingLibrary = nil
do
    local ok, result = pcall(function()
        local code = game:HttpGetAsync(libURL)
        if not code then error("Empty code from URL") end
        local func, err = loadstring(code)
        if not func then error("loadstring failed: "..tostring(err)) end
        local ret = func()
        return ret
    end)
    if not ok then
        warn("YANZ HUB: Failed to load Nothing UI Library:", result)
        return
    end
    NothingLibrary = result
end

-- Validate library shape (support both NothingLibrary.new or just .NewWindow style)
if type(NothingLibrary) ~= "table" then
    warn("YANZ HUB: Library returned unexpected type:", typeof(NothingLibrary))
    return
end

-- Try to create Window safely
local Window
local ok_window, res_window = pcall(function()
    -- If library has "new" function use it. Otherwise try "New" or constructor fallback
    if type(NothingLibrary.new) == "function" then
        return NothingLibrary.new({
            Title = "YANZ HUB | Race Clicker",
            Description = "By lphisv5 | Game : 🏆 Race Clicker",
            Keybind = Enum.KeyCode.RightShift,
            Logo = 'http://www.roblox.com/asset/?id=125456335927282'
        })
    elseif type(NothingLibrary.NewWindow) == "function" then
        return NothingLibrary.NewWindow({
            Title = "YANZ HUB | Race Clicker",
            Description = "By lphisv5 | Game : 🏆 Race Clicker",
            Keybind = Enum.KeyCode.RightShift,
            Logo = 'http://www.roblox.com/asset/?id=125456335927282'
        })
    else
        -- try calling library as function (rare)
        if type(NothingLibrary) == "function" then
            return NothingLibrary({Title="YANZ HUB | Race Clicker"})
        end
        error("No known constructor in library")
    end
end)
if not ok_window then
    warn("YANZ HUB: Cannot create window from NothingLibrary. Error:", res_window)
    return
end
Window = res_window

--===[ Tabs & Sections ]===--
local HomeTab = Window:NewTab({
    Title = "Home",
    Description = "Main Features",
    Icon = "rbxassetid://7733960981"
})
local MainTab = Window:NewTab({
    Title = "Main",
    Description = "Auto Click Features",
    Icon = "rbxassetid://7733960981"
})
local SpeedTab = Window:NewTab({
    Title = "Speed Booster",
    Description = "Speed Settings",
    Icon = "rbxassetid://7743869054"
})

local HomeSection = HomeTab:NewSection({Title = "Main Controls", Icon = "rbxassetid://7733916988", Position = "Left"})
local AutoClickSection = MainTab:NewSection({Title = "Auto Click", Icon = "rbxassetid://7733916988", Position = "Left"})
local AutoWinsSection = MainTab:NewSection({Title = "Auto Wins", Icon = "rbxassetid://7733916988", Position = "Right"})
local SpeedSection = SpeedTab:NewSection({Title = "Speed Control", Icon = "rbxassetid://7733916988", Position = "Left"})

--===[ Status Labels ]===--
local posLabel = AutoClickSection:NewTitle("Player Pos: Waiting...")
local statusLabel = AutoClickSection:NewTitle("Status: Ready")

--===[ Globals & Conns ]===--
local connections = {}
local function addConn(c) if c then table.insert(connections, c) end return c end

local state = {
    autoClick = false,
    clickDelay = 0.1,
    autoClickPos = nil,
    autoWins = false,
    autoSpeed = false
}

--===[ Helper: updateLabel (safe) ]===
local function updateLabel(lbl, text)
    if not lbl then return end
    pcall(function()
        if typeof(lbl) == "Instance" and lbl.Text ~= nil then lbl.Text = tostring(text) end
        if lbl.Set then lbl:Set(tostring(text)) end
        if lbl.SetText then lbl:SetText(tostring(text)) end
        if lbl.SetTitle then lbl:SetTitle(tostring(text)) end
    end)
end

--===[ Safe Click implementation ]===
local function SafeClick(pos)
    if not pos or not pos.X or not pos.Y then return false end
    if VirtualInputManager then
        local success, err = pcall(function()
            -- try camera target
            local cam = workspace.CurrentCamera
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, cam, 1)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, cam, 1)
        end)
        if success then return true end
    end
    -- fallback: try to FireServer on common remotes (if present)
    local ok, ev = pcall(function() return ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("Click3") end)
    if ok and ev and ev.FireServer then
        pcall(function() ev:FireServer() end)
        return true
    end
    -- last resort: warn and return false
    return false
end

--===[ Click Loop function ]===
local function ClickLoopOnce()
    if state.autoClickPos then
        SafeClick(state.autoClickPos)
    else
        local cam = workspace.CurrentCamera
        if cam then
            local vp = cam.ViewportSize
            SafeClick({X = vp.X/2, Y = vp.Y/2})
        end
    end
end

--===[ Auto Click Toggle UI ]===
local autoToggleWidget
autoToggleWidget = AutoClickSection:NewToggle({
    Title = "Auto Click (0.1s)",
    Default = false,
    Callback = function(v)
        state.autoClick = v
        if v then
            updateLabel(statusLabel, "Auto Clicking Active")
            task.spawn(function()
                while state.autoClick do
                    pcall(ClickLoopOnce)
                    task.wait(state.clickDelay or 0.1)
                end
                updateLabel(statusLabel, "Status: Ready")
            end)
        else
            updateLabel(statusLabel, "Status: Ready")
        end
    end
})

--===[ Set Click Position Button ]===
AutoClickSection:NewButton({
    Title = "SET CLICK POSITION",
    Callback = function()
        updateLabel(statusLabel, "🖱️ Click anywhere to set position (10s)...")
        local got = false
        local conn
        conn = addConn(UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mpos = UserInputService:GetMouseLocation()
                state.autoClickPos = {X = mpos.X, Y = mpos.Y}
                updateLabel(statusLabel, "✅ Position set: "..math.floor(mpos.X) ..",".. math.floor(mpos.Y))
                got = true
                if conn then conn:Disconnect() end
            end
        end))
        task.delay(10, function()
            if not got then
                if conn then conn:Disconnect() end
                updateLabel(statusLabel, "❌ Position set cancelled")
                task.wait(1.5)
                updateLabel(statusLabel, state.autoClick and "Auto Clicking Active" or "Status: Ready")
            end
        end)
    end
})

--===[ Click Speed Buttons ]===
local speeds = {
    {label = "ULTRA FAST", value = 0.01},
    {label = "FAST", value = 0.3},
    {label = "NORMAL", value = 0.1},
    {label = "SLOW", value = 1.5}
}
for _, s in ipairs(speeds) do
    SpeedSection:NewButton({
        Title = s.label.." ("..s.value.."s)",
        Callback = function()
            state.clickDelay = s.value
            updateLabel(statusLabel, "Delay: "..s.value.."s")
            pcall(function()
                if NothingLibrary.Notify then
                    NothingLibrary:Notify({Title="YANZ HUB", Content="Click delay set to "..s.value.."s", Duration=2})
                end
            end)
        end
    })
end

--===[ Position updater ]===
local function startPositionUpdater(char)
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then
        hrp = char:WaitForChild("HumanoidRootPart", 5)
    end
    if not hrp then
        updateLabel(posLabel, "Player Pos: Unknown")
        return
    end
    local conn = RunService.RenderStepped:Connect(function()
        pcall(function()
            if hrp and hrp.Parent then
                local p = hrp.Position
                updateLabel(posLabel, string.format("Player Pos: X=%.1f Y=%.1f Z=%.1f", p.X, p.Y, p.Z))
            else
                updateLabel(posLabel, "Player Pos: Waiting...")
            end
        end)
    end)
    addConn(conn)
end

-- init pos updater
if LocalPlayer.Character then
    startPositionUpdater(LocalPlayer.Character)
end
addConn(LocalPlayer.CharacterAdded:Connect(function(c) startPositionUpdater(c) end))

--===[ Auto Wins Implementation ]===
-- checkpoint mapping (ordered list)
local checkpointOrder = {
    {name="ส้มอ่อน", id = "1"},
    {name="แดงอ่อน", id = "3"},
    {name="ฟ้าอ่อน", id = "4"},
    {name="ม่วง", id = "5"},
    {name="เขียว", id = "10"},
    {name="ฟ้าใส", id = "25"},
    {name="ชมพู่อ่อน", id = "50"},
    {name="ดำ", id = "100"},
    {name="ส้ม", id = "500"},
    {name="เขียวเข้ม", id = "1000"},
    {name="ชมพู่เข้ม", id = "5000"},
    {name="เหลือง", id = "10000"},
    {name="น้ำเงิน", id = "25000"},
    {name="แดงเข้ม", id = "50000"},
    {name="ม่วงออกชมพู", id = "100000"},
}

local function findTimerText()
    -- try to find any TextLabel/TextBox in PlayerGui that contains the timer words
    local gui = LocalPlayer:FindFirstChild("PlayerGui")
    if not gui then return nil end
    for _, child in ipairs(gui:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            local txt = tostring(child.Text or "")
            if txt:match("%d%d:%d%d%.%d%d") or txt:match("Waiting to start") or txt:match("Click to build up Speed") then
                return txt, child
            end
        end
    end
    return nil
end

local function tryTeleportToCheckpoint(partNameOrId)
    -- try to find by numeric name
    local part = workspace:FindFirstChild(partNameOrId) or workspace:FindFirstChild(tostring(partNameOrId))
    if part and part:IsA("BasePart") then
        pcall(function() 
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0,3,0)
            end
        end)
        return true
    end
    -- try find by folder "Checkpoints" or by NameContains
    for _,desc in ipairs(workspace:GetDescendants()) do
        if desc:IsA("BasePart") and (desc.Name == partNameOrId or tostring(desc.Name):lower():find(tostring(partNameOrId):lower())) then
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = desc.CFrame + Vector3.new(0,3,0)
                end
            end)
            return true
        end
    end
    return false
end

AutoWinsSection:NewToggle({
    Title = "Auto Wins",
    Default = false,
    Callback = function(v)
        state.autoWins = v
        if v then
            updateLabel(statusLabel, "Auto Wins: Running")
            task.spawn(function()
                while state.autoWins do
                    task.wait(0.8)
                    local txt, lbl = findTimerText()
                    txt = txt or ""
                    -- Phase detection
                    if txt:match("Waiting to start") then
                        -- do nothing, wait
                        updateLabel(statusLabel, "Waiting to start...")
                    elseif txt:match("Click to build up Speed") then
                        -- if in build phase -> auto click rapidly
                        updateLabel(statusLabel, "Build phase: auto clicking...")
                        for i=1,10 do
                            pcall(ClickLoopOnce)
                            task.wait(0.05)
                        end
                    elseif txt:match("%d%d:%d%d%.%d%d") then
                        -- main race - teleport through checkpoints
                        updateLabel(statusLabel, "Racing: teleporting checkpoints...")
                        for _, cp in ipairs(checkpointOrder) do
                            if not state.autoWins then break end
                            -- try by id first
                            local ok = tryTeleportToCheckpoint(cp.id) or tryTeleportToCheckpoint(cp.name)
                            task.wait(0.4)
                        end
                    else
                        -- if looks like 00:00 then stop
                        if txt:match("00:00") then
                            state.autoWins = false
                            updateLabel(statusLabel, "Auto Wins: Finished (00:00)")
                            break
                        else
                            updateLabel(statusLabel, "Auto Wins: idle")
                        end
                    end
                end
                updateLabel(statusLabel, "Status: Ready")
            end)
        else
            updateLabel(statusLabel, "Auto Wins: Stopped")
        end
    end
})

--===[ Speed Booster ]===
SpeedSection:NewToggle({
    Title = "Enable Speed Booster",
    Default = false,
    Callback = function(v)
        state.autoSpeed = v
        if v then
            updateLabel(statusLabel, "Speed Booster: Active")
            task.spawn(function()
                while state.autoSpeed do
                    task.wait(0.2)
                    pcall(function()
                        -- 1) try leaderstats Speed
                        local ls = LocalPlayer:FindFirstChild("leaderstats")
                        if ls and ls:FindFirstChild("Speed") and typeof(ls.Speed.Value) == "number" then
                            -- add smaller increments to avoid server spam
                            ls.Speed.Value = ls.Speed.Value + 100
                        else
                            -- 2) try humanoid WalkSpeed local (instant visual effect)
                            local char = LocalPlayer.Character
                            if char then
                                local hum = char:FindFirstChildOfClass("Humanoid")
                                if hum and hum.Health > 0 then
                                    -- only set up to a high value to avoid physics break; you can change limit
                                    local cur = hum.WalkSpeed or 16
                                    hum.WalkSpeed = math.min(cur + 5, 500)
                                end
                            end
                        end
                    end)
                end
                updateLabel(statusLabel, "Speed Booster: Stopped")
            end)
        else
            updateLabel(statusLabel, "Speed Booster: Disabled")
        end
    end
})

--===[ Home actions ]===
HomeSection:NewButton({
    Title = "Join Discord",
    Callback = function()
        pcall(function() setclipboard("https://discord.gg/DfVuhsZb") end)
        pcall(function()
            if NothingLibrary.Notify then
                NothingLibrary:Notify({Title="YANZ HUB", Content="Discord link copied!", Duration=4})
            end
        end)
    end
})

-- Emergency Stop via F6 (stops all toggles)
addConn(UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        state.autoClick = false
        state.autoWins = false
        state.autoSpeed = false
        updateLabel(statusLabel, "Emergency Stop (F6)")
        -- update UI widgets if possible:
        pcall(function()
            if autoToggleWidget and autoToggleWidget.Set then autoToggleWidget:Set(false) end
        end)
    end
end))

-- Cleanup on player leaving
addConn(Players.PlayerRemoving:Connect(function(plr)
    if plr == LocalPlayer then
        -- disconnect all
        for _,c in ipairs(connections) do
            pcall(function() if c and c.Disconnect then c:Disconnect() end end)
        end
        -- close window if available
        pcall(function() if Window and Window.Destroy then Window:Destroy() end end)
    end
end))

print("✅ YANZ HUB Race Clicker Loaded Successfully (fixed)")
